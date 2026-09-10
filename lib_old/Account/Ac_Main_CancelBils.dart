import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Beam/webviewPay_beamcheckout.dart';
import '../Constant/Myconstant.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetInvoiceRe_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../Style/downloadImage.dart';
import 'Ac_List/Ac_List_Title.dart';
import 'Ac_Sub/Account_Can_BillPay.dart';
import 'Ac_Sub/Account_Can_Invoce.dart';
import 'Ac_Sub/Account_Can_PayVerifi.dart';

class MainCancelBilsScreen extends StatefulWidget {
  const MainCancelBilsScreen({super.key});

  @override
  State<MainCancelBilsScreen> createState() => _MainCancelBilsScreenState();
}

class _MainCancelBilsScreenState extends State<MainCancelBilsScreen> {
  //-------------------------------------->
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  //-------------------------------------->
  int limit_Invoice = 50;
  int offset_Invoice = 0;
  int endIndex_Invoice = 0;
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0;
  //-------------------------------------->
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  TextEditingController Text_searchBar_main1 = TextEditingController();
  TextEditingController Text_searchBar_main2 = TextEditingController();
  //-------------------------------------->
  TextEditingController Text_searchBar1 = TextEditingController();
  TextEditingController Text_searchBar2 = TextEditingController();

  DateTime datex = DateTime.now();
  int? show_more;
  String tappedIndex_ = '';
  String? ser_payby, pdate, Slip_history;
  int Ser_Tap = 0;
  int Status_ = 1;
  int Date_ser = 0;
  //-------------------------------------->
  List<RenTalModel> renTalModels = [];
  List<TransReBillModel> _TransReBillModels = [];
  List<TransReBillModel> TransReBillModels_ = [];
  List<TransReBillModel> limitedList_TransReBillModels_ = [];

  List<TransReBillModel> _InvoiceBillModels_cancel = [];
  List<TransReBillModel> InvoiceBillModels_cancel_ = [];
  List<InvoiceReModel> _InvoiceModels = <InvoiceReModel>[];
  List<InvoiceReModel> limitedList_InvoiceModels_ = [];
  List<InvoiceReModel> InvoiceModels = [];
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  //-------------------------------------->
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

  String? MONTH_Now, YEAR_Now;
  ///////////--------------------------------------------->
  String? renTal_user, renTal_name, zone_ser, zone_name;
  String? ref_1, ref_2, ref_3;
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
      newValuePDFimg_QR;
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
  int TitleType_Default_Receipt = 0;
  String _ReportValue_type = "ไม่ระบุ";
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'สำเนา',
  ];
  String? base64_Imgmap, tem_page_ser;
  List<Map<String, String>> ac9 = [];
  List<Map<String, String>> ac9_2 = [];
  List<Map<String, String>> ac9_3 = [];

  ///----------------->
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  ScrollController _scrollController3 = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPreferance();
    read_GC_rental();
    addAcListTitle();
  }

////////////----------------------------------->
  void addAcListTitle() {
    setState(() {
      // Add the items from AcListTitle().ac_1 to ac1
      ac9.addAll(AcListTitle().ac9_1);
      ac9_2.addAll(AcListTitle().ac9_2);
      ac9_3.addAll(AcListTitle().ac9_3);
    });
  }

  ////////////----------------------------------->
  where_ac9(String ser) {
    if (ac9
        .where((item) =>
            item["ser"].toString() == ser && item["st"].toString() == '1')
        .isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  ////////////----------------------------------->
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

  ////////////----------------------------------->
  where_ac9_3(String ser) {
    if (ac9_3
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
      // fname_ = preferences.getString('fname');
      // if (preferences.getString('renTalSer') == '65') {
      //   viewTab = 0;
      // }
    });
    red_Trans_billCancel();
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

            tem_page_ser = renTalModel.tem_page!.trim();
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

  Future<Null> red_Trans_billCancel() async {
    if (limitedList_TransReBillModels_.length != 0) {
      setState(() {
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
    var zone = preferences.getString('zonePSer');
    // var qutser = widget.Get_Value_NameShop_index; ***GC_billZone_payCancel_BC
    String url = (zone == null || zone == '0')
        ? '${MyConstant().domain}/GC_bill_payCancel_BC.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&serzone=$zone'
        : '${MyConstant().domain}/GC_billZone_payCancel_BC.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&serzone=$zone';
    // String url =
    //     '${MyConstant().domain}/GC_bill_pay_BC.php?isAdd=true&ren=$ren';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          // if (transReBillModel.pos != '1') {
          setState(() {
            limitedList_TransReBillModels_.add(transReBillModel);

            // _TransBillModels.add(_TransBillModel);
          });
          // }
        }
        setState(() {
          TransReBillModels_ = limitedList_TransReBillModels_;
        });
        // print('result ${_TransReBillModels.length}');
      }
      read_TransReBill_limit();
    } catch (e) {}
  }

  ///----
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

  //////////------------------------------------------------------->(รายงาน ประวัติวางบิล (ยกเลิก))
////////--------------------------------------------------------------->

  Future<Null> red_InvoiceMon_bill() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    setState(() {
      limitedList_InvoiceModels_.clear();
      offset_Invoice = 0;
      endIndex_Invoice = 0;
      // invoice_select.clear();
    });
    String Serdata =
        (zone.toString() == '0' || zone == null) ? 'All' : 'Allzone';
    String url = (zone == null || zone == '0')
        ? '${MyConstant().domain}/GC_bill_CancelinvoiceMon_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=0&_monts=$MONTH_Now&yex=$YEAR_Now'
        : '${MyConstant().domain}/GC_bill_CancelinvoiceMon_historyReport.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
          setState(() {
            limitedList_InvoiceModels_.add(transMeterModel);
          });
        }
      }

      Future.delayed(const Duration(milliseconds: 200), () async {
        setState(() {
          _InvoiceModels = limitedList_InvoiceModels_;
        });
      });
      read_Invoice_limit();
      // print('zone $zone');
      // read_Invoice_limit2();
    } catch (e) {}
  }

  ///----------------------->
  Future<Null> read_Invoice_limit() async {
    setState(() {
      endIndex_Invoice = offset_Invoice + limit_Invoice;
      InvoiceModels = limitedList_InvoiceModels_.sublist(
          offset_Invoice, // Start index
          (endIndex_Invoice <= limitedList_InvoiceModels_.length)
              ? endIndex_Invoice
              : limitedList_InvoiceModels_.length // End index
          );
    });
  }

  ///----------------------->
  Future<Null> red_Trans_bill_Verifi() async {
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
    var zone = preferences.getString('zonePSer');

    String url = (zone == null || zone == '0')
        ? '${MyConstant().domain}/GC_bill_pay_BC_VerifiCancel.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&serzone=$zone'
        : '${MyConstant().domain}/GC_billZone_pay_BC_VerifiCancel.php?isAdd=true&ren=$ren&mont_h=$MONTH_Now&yea_r=$YEAR_Now&serpang=$sertype&serzone=$zone';
    try {
      var response = await http.get(Uri.parse(url));

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
      read_TransReBill_Verifi_limit();
    } catch (e) {}
  }

  Future<Null> read_TransReBill_Verifi_limit() async {
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

  ///----------------------->
  Widget Next_page_billCancel() {
    return Row(
      children: [
        Expanded(child: Text('')),
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
                    Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 20,
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
                                  });
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
                        // '*//$endIndex /${limitedList_TransReBillModels_.length} ///${(endIndex / limit)}/${(limitedList_TransReBillModels_.length / limit).ceil()}',
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
                        onTap: ((endIndex / limit) ==
                                (limitedList_TransReBillModels_.length / limit)
                                    .ceil())
                            ? null
                            : () async {
                                setState(() {
                                  offset = offset + limit;
                                  read_TransReBill_limit();
                                });
                              },
                        child: Icon(
                          Icons.arrow_right,
                          color: ((endIndex / limit) ==
                                  (limitedList_TransReBillModels_.length /
                                          limit)
                                      .ceil())
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

  Widget Next_page_InvoiceCancel() {
    return Row(
      children: [
        Expanded(child: Text('')),
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
                    Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 20,
                    ),
                    InkWell(
                        onTap: (offset_Invoice == 0)
                            ? null
                            : () async {
                                if (offset_Invoice == 0) {
                                } else {
                                  setState(() {
                                    offset_Invoice =
                                        offset_Invoice - limit_Invoice;
                                    read_Invoice_limit();
                                  });
                                }
                              },
                        child: Icon(
                          Icons.arrow_left,
                          color: (offset_Invoice == 0)
                              ? Colors.grey[200]
                              : Colors.black,
                          size: 25,
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Text(
                        // '*//$endIndex /${limitedList_TransReBillModels_.length} ///${(endIndex / limit)}/${(limitedList_TransReBillModels_.length / limit).ceil()}',
                        '${(endIndex_Invoice / limit_Invoice)}/${(limitedList_InvoiceModels_.length / limit_Invoice).ceil()}',

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
                        onTap: ((endIndex_Invoice / limit_Invoice) ==
                                (limitedList_InvoiceModels_.length /
                                        limit_Invoice)
                                    .ceil())
                            ? null
                            : () async {
                                setState(() {
                                  offset_Invoice =
                                      offset_Invoice + limit_Invoice;
                                  read_Invoice_limit();
                                });
                              },
                        child: Icon(
                          Icons.arrow_right,
                          color: ((endIndex_Invoice / limit_Invoice) ==
                                  (limitedList_InvoiceModels_.length /
                                          limit_Invoice)
                                      .ceil())
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

  ///----------------------->
  Widget Next_page_billCancel_Verifi() {
    return Row(
      children: [
        Expanded(child: Text('')),
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
                    Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 20,
                    ),
                    InkWell(
                        onTap: (offset == 0)
                            ? null
                            : () async {
                                if (offset == 0) {
                                } else {
                                  setState(() {
                                    offset = offset - limit;
                                    read_TransReBill_Verifi_limit();
                                  });
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
                        // '*//$endIndex /${limitedList_TransReBillModels_.length} ///${(endIndex / limit)}/${(limitedList_TransReBillModels_.length / limit).ceil()}',
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
                        onTap: ((endIndex / limit) ==
                                (limitedList_TransReBillModels_.length / limit)
                                    .ceil())
                            ? null
                            : () async {
                                setState(() {
                                  offset = offset + limit;
                                  read_TransReBill_Verifi_limit();
                                });
                              },
                        child: Icon(
                          Icons.arrow_right,
                          color: ((endIndex / limit) ==
                                  (limitedList_TransReBillModels_.length /
                                          limit)
                                      .ceil())
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

  ////////--------------------------------------------------------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveUp3() {
    _scrollController3.animateTo(_scrollController3.offset - 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown3() {
    _scrollController3.animateTo(_scrollController3.offset + 250,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
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
          Text_searchBar1.clear();
          _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
            var notTitle1 = TransReBillModels.cid.toString();
            var notTitle2 = TransReBillModels.docno.toString();
            var notTitle3 = TransReBillModels.cname.toString();
            var notTitle4 = TransReBillModels.sname.toString();
            // var notTitle1 = TransReBillModels.cid.toString().toLowerCase();
            // var notTitle2 = TransReBillModels.docno.toString().toLowerCase();
            // var notTitle3 = TransReBillModels.cname.toString().toLowerCase();
            // var notTitle4 = TransReBillModels.sname.toString().toLowerCase();
            return notTitle1.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text) ||
                notTitle4.contains(text);
          }).toList();
        });
        if (text.isEmpty) {
          read_TransReBill_limit();
        } else {}
      },
    );
  }

  _searchBarMain2() {
    return TextField(
      textAlign: TextAlign.start,
      controller: Text_searchBar_main2,
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
          Text_searchBar2.clear();
          InvoiceModels = _InvoiceModels.where((InvoiceModels) {
            var notTitle1 = InvoiceModels.cid.toString();
            var notTitle2 = InvoiceModels.docno.toString();
            var notTitle3 = InvoiceModels.cname.toString();
            var notTitle4 = InvoiceModels.ln.toString();
            var notTitle5 = InvoiceModels.btype.toString();
            var notTitle6 = InvoiceModels.zn.toString();
            // var notTitle1 = InvoiceModels.cid.toString().toLowerCase();
            // var notTitle2 = InvoiceModels.docno.toString().toLowerCase();
            // var notTitle3 = InvoiceModels.cname.toString().toLowerCase();
            // var notTitle4 = InvoiceModels.ln.toString().toLowerCase();
            // var notTitle5 = InvoiceModels.btype.toString().toLowerCase();
            // var notTitle6 = InvoiceModels.zn.toString().toLowerCase();
            return notTitle1.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text) ||
                notTitle4.contains(text) ||
                notTitle5.contains(text) ||
                notTitle6.contains(text);
          }).toList();
        });
        if (text.isEmpty) {
          read_Invoice_limit();
        } else {}
      },
    );
  }

  _searchBar1() {
    return TextField(
      textAlign: TextAlign.center,
      controller: Text_searchBar1,
      autofocus: false,
      cursorHeight: 14,
      keyboardType: TextInputType.text,
      style: const TextStyle(
          color: PeopleChaoScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T),
      decoration: InputDecoration(
        // labelStyle: TextStyle(height: 14),
        filled: false,
        // fillColor: Colors.white,
        hintText: 'Search...',
        hintStyle: const TextStyle(
            // fontSize: 12,
            color: PeopleChaoScreen_Color.Colors_Text2_,
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
        var Text_searchBar2_ = Text_searchBar1.text.toLowerCase();
        //         Widget BodyHome_Web() {
        //   return (Status_ == 1)
        //       ? viewTab == 0
        //           ? PlayColumn()
        //           : BodyStatus2_Web()
        //       : (Status_ == 2)
        //           ? BodyStatus1_Web()
        //           : (Status_ == 3)
        //               ? BodyStatus3_Web()
        //               : BodyStatus4_Web();
        // }

        if (Date_ser == 0) {
          setState(() {
            _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
              var daterec_ =
                  '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.daterec} 00:00:00'))}-${DateTime.parse('${TransReBillModels.daterec} 00:00:00').year + 543}';
              var pdate_ =
                  '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.pdate} 00:00:00'))}-${DateTime.parse('${TransReBillModels.pdate} 00:00:00').year + 543}';
              var date_ =
                  '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.date} 00:00:00'))}-${DateTime.parse('${TransReBillModels.date} 00:00:00').year + 543}';
              var notTitle1 = daterec_.toString().toLowerCase();
              var notTitle2 = pdate_.toString().toLowerCase();
              var notTitle3 = date_.toString().toLowerCase();

              return notTitle1.contains(text) ||
                  notTitle2.contains(text) ||
                  notTitle3.contains(text);
            }).toList();
          });
        } else if (Date_ser == 1) {
          setState(() {
            _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
              var daterec_ =
                  '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.daterec} 00:00:00'))}-${DateTime.parse('${TransReBillModels.daterec} 00:00:00').year + 543}';

              var notTitle1 = daterec_.toString().toLowerCase();

              return notTitle1.contains(text);
            }).toList();
          });
        } else if (Date_ser == 2) {
          setState(() {
            _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
              var pdate_ =
                  '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.pdate} 00:00:00'))}-${DateTime.parse('${TransReBillModels.pdate} 00:00:00').year + 543}';

              var notTitle1 = pdate_.toString().toLowerCase();

              return notTitle1.contains(text);
            }).toList();
          });
        } else if (Date_ser == 3) {
          setState(() {
            _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
              var date_ =
                  '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.date} 00:00:00'))}-${DateTime.parse('${TransReBillModels.date} 00:00:00').year + 543}';

              var notTitle1 = date_.toString().toLowerCase();

              return notTitle1.contains(text);
            }).toList();
          });
        }
        if (text.isEmpty) {
          read_TransReBill_limit();
        } else {}
      },
    );
  }

  // _searchBar2() {
  //   return TextField(
  //     textAlign: TextAlign.center,
  //     controller: Text_searchBar1,
  //     autofocus: false,
  //     cursorHeight: 14,
  //     keyboardType: TextInputType.text,
  //     style: const TextStyle(
  //         color: PeopleChaoScreen_Color.Colors_Text2_,
  //         fontFamily: Font_.Fonts_T),
  //     decoration: InputDecoration(
  //       // labelStyle: TextStyle(height: 14),
  //       filled: false,
  //       // fillColor: Colors.white,
  //       hintText: 'Search...',
  //       hintStyle: const TextStyle(
  //           // fontSize: 12,
  //           color: PeopleChaoScreen_Color.Colors_Text2_,
  //           fontFamily: Font_.Fonts_T),
  //       contentPadding:
  //           const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
  //       // focusedBorder: OutlineInputBorder(
  //       //   borderSide: const BorderSide(color: Colors.white),
  //       //   borderRadius: BorderRadius.circular(10),
  //       // ),
  //       enabledBorder: UnderlineInputBorder(
  //         borderSide: const BorderSide(color: Colors.white),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //     ),
  //     onChanged: (text) {
  //       var Text_searchBar2_ = Text_searchBar1.text.toLowerCase();
  //       //         Widget BodyHome_Web() {
  //       //   return (Status_ == 1)
  //       //       ? viewTab == 0
  //       //           ? PlayColumn()
  //       //           : BodyStatus2_Web()
  //       //       : (Status_ == 2)
  //       //           ? BodyStatus1_Web()
  //       //           : (Status_ == 3)
  //       //               ? BodyStatus3_Web()
  //       //               : BodyStatus4_Web();
  //       // }

  //       if (Date_ser == 0) {
  //         setState(() {
  //           _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
  //             var daterec_ =
  //                 '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.daterec} 00:00:00'))}-${DateTime.parse('${TransReBillModels.daterec} 00:00:00').year + 543}';
  //             var pdate_ =
  //                 '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.pdate} 00:00:00'))}-${DateTime.parse('${TransReBillModels.pdate} 00:00:00').year + 543}';
  //             var date_ =
  //                 '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.date} 00:00:00'))}-${DateTime.parse('${TransReBillModels.date} 00:00:00').year + 543}';
  //             var notTitle1 = daterec_.toString().toLowerCase();
  //             var notTitle2 = pdate_.toString().toLowerCase();
  //             var notTitle3 = date_.toString().toLowerCase();

  //             return notTitle1.contains(text) ||
  //                 notTitle2.contains(text) ||
  //                 notTitle3.contains(text);
  //           }).toList();
  //         });
  //       } else if (Date_ser == 1) {
  //         setState(() {
  //           _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
  //             var daterec_ =
  //                 '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.daterec} 00:00:00'))}-${DateTime.parse('${TransReBillModels.daterec} 00:00:00').year + 543}';

  //             var notTitle1 = daterec_.toString().toLowerCase();

  //             return notTitle1.contains(text);
  //           }).toList();
  //         });
  //       } else if (Date_ser == 2) {
  //         setState(() {
  //           _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
  //             var pdate_ =
  //                 '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.pdate} 00:00:00'))}-${DateTime.parse('${TransReBillModels.pdate} 00:00:00').year + 543}';

  //             var notTitle1 = pdate_.toString().toLowerCase();

  //             return notTitle1.contains(text);
  //           }).toList();
  //         });
  //       } else if (Date_ser == 3) {
  //         setState(() {
  //           _TransReBillModels = TransReBillModels_.where((TransReBillModels) {
  //             var date_ =
  //                 '${DateFormat('dd-MM').format(DateTime.parse('${TransReBillModels.date} 00:00:00'))}-${DateTime.parse('${TransReBillModels.date} 00:00:00').year + 543}';

  //             var notTitle1 = date_.toString().toLowerCase();

  //             return notTitle1.contains(text);
  //           }).toList();
  //         });
  //       }
  //     },
  //   );
  // }

  ////////--------------------------------------------------------------->
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(23, 8, 8, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
              //   child: InkWell(
              //     onTap: () {
              //       setState(() {
              //         Ser_Tap = 0;
              //         tappedIndex_ = '';
              //       });
              //     },
              //     child: Container(
              //       // width: 100, Verifi_Billing_Screen
              //       decoration: BoxDecoration(
              //         color:
              //             (Ser_Tap == 0) ? Colors.pink[600] : Colors.pink[200],
              //         borderRadius: const BorderRadius.only(
              //             topLeft: Radius.circular(10),
              //             topRight: Radius.circular(10),
              //             bottomLeft: Radius.circular(0),
              //             bottomRight: Radius.circular(0)),
              //         border: Border.all(color: Colors.white, width: 1),
              //       ),
              //       padding: const EdgeInsets.all(6.0),
              //       child: Text(
              //         "ประวัติยกเลิกชำระ",
              //         style: TextStyle(
              //           color: (Ser_Tap == 0) ? Colors.white : Colors.black,
              //           fontFamily: FontWeight_.Fonts_T,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      Ser_Tap = 0;
                      tappedIndex_ = '';
                    });
                    red_Trans_billCancel();
                  },
                  child: Container(
                    // width: 130,
                    decoration: BoxDecoration(
                      color:
                          (Ser_Tap == 0) ? Colors.pink[600] : Colors.pink[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
             padding: const EdgeInsets.all(4.0),
                    child: Translate.TranslateAndSetText(
                        "ประวัติยกเลิกชำระ",
                        (Ser_Tap == 0) ? Colors.white : Colors.black,
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
                    red_InvoiceMon_bill();
                  },
                  child: Container(
                    // width: 130,
                    decoration: BoxDecoration(
                      color:
                          (Ser_Tap == 1) ? Colors.pink[600] : Colors.pink[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
          padding: const EdgeInsets.all(4.0),
                    child: Translate.TranslateAndSetText(
                        "ประวัติยกเลิกวางบิล",
                        (Ser_Tap == 1) ? Colors.white : Colors.black,
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
                    red_Trans_bill_Verifi();
                  },
                  child: Container(
                    // width: 130,
                    decoration: BoxDecoration(
                      color:
                          (Ser_Tap == 2) ? Colors.pink[600] : Colors.pink[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
           padding: const EdgeInsets.all(4.0),
                    child: Translate.TranslateAndSetText(
                        "ประวัติยกเลิกรายการชำระ(รอตรวจสอบ)",
                        (Ser_Tap == 2) ? Colors.white : Colors.black,
                        TextAlign.start,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        12,
                        1),
                  ),
                ),
              )
            ],
          ),
        ),
          (Ser_Tap == 0)
            ? Account_Cancel_BillPay()

            ///bill_payCancel_BC()
            : (Ser_Tap == 1)
                ? Account_Cancel_Invoce() //bill_InvoceCancel_BC()
                : Account_Cancel_PayVerifi() // bill_payCancel_BC_Verifi()
        // (Ser_Tap == 0)
        //     ? bill_payCancel_BC()
        //     : (Ser_Tap == 1)
        //         ? bill_InvoceCancel_BC()
        //         : bill_payCancel_BC_Verifi()
      ],
    );
  }

  Widget bill_payCancel_BC() {
    double calculatedWidth =
        (ac9.where((item) => item["st"] == '1').toList().length <= 10)
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.85 +
                ((ac9.where((item) => item["st"] == '1').toList().length - 10) *
                    60);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Container(
            width: (Responsive.isDesktop(context)) ? calculatedWidth : 1200,
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
                        : 1200,
                    child: Column(
                      children: [
                        ScrollConfiguration(
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
                                SizedBox(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: (Responsive.isDesktop(context))
                                            ? calculatedWidth
                                            : 1200,
                                        decoration: BoxDecoration(
                                          color:
                                              AppbackgroundColor.TiTile_Colors,
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
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(2.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ค้นหา :',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.start,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            12,
                                                            1),
                                                  ),
                                                  Expanded(
                                                    // flex: 1,
                                                    child: Container(
                                                      height: 35, //Date_ser
                                                      // width: 150,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(8),
                                                            topRight:
                                                                Radius.circular(
                                                                    0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      child: _searchBarMain1(),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 2, 2, 2),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        // .withOpacity(0.5),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight:
                                                                    Radius
                                                                        .circular(
                                                                            8),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            8)),
                                                        // border: Border.all(
                                                        //     color:
                                                        //         Colors.grey,
                                                        //     width: 1),
                                                      ),
                                                      width: 130,
                                                      // height: 30,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton2<
                                                            String>(
                                                          isExpanded: true,
                                                          hint: Center(
                                                            child: Text(
                                                              'หัวข้อ',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ),

                                                          items: ac9
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index = entry
                                                                .key; // Get the index
                                                            var item =
                                                                entry.value;
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: item[
                                                                  "ser"], // Use "ser" as the value
                                                              enabled:
                                                                  false, // Set to true to allow selection
                                                              child:
                                                                  StatefulBuilder(
                                                                builder: (context,
                                                                    menuSetState) {
                                                                  // final isSelected = selectedItems.contains(item);
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      int selectedIndex = ac9.indexWhere((items) =>
                                                                          items[
                                                                              "ser"] ==
                                                                          item[
                                                                              "ser"]);
                                                                      // print(ac1[selectedIndex]
                                                                      //     [
                                                                      //     "pn"]);
                                                                      // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                                                      //This rebuilds the StatefulWidget to update the button's text
                                                                      setState(
                                                                          () {
                                                                        if (item["st"]! ==
                                                                            '1') {
                                                                          ac9[selectedIndex]["st"] =
                                                                              '0';
                                                                        } else {
                                                                          ac9[selectedIndex]["st"] =
                                                                              '1';
                                                                        }
                                                                      });
                                                                      //This rebuilds the dropdownMenu Widget to update the check mark
                                                                      menuSetState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: double
                                                                          .infinity,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          if (item["st"]! ==
                                                                              '1')
                                                                            Icon(
                                                                              Icons.check_box_outlined,
                                                                              color: Colors.green[400],
                                                                            )
                                                                          else
                                                                            const Icon(Icons.check_box_outline_blank),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              item["pn"]!,
                                                                              maxLines: 2,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: AccountScreen_Color.Colors_Text1_,
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
                                                  Container(
                                                      width: 150,
                                                      child:
                                                          Next_page_billCancel())
                                                  // Expanded(
                                                  //     child:
                                                  //         Next_page_billCancel())
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppbackgroundColor
                                                            .Sub_Abg_Colors
                                                        .withOpacity(0.5),
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
                                                    // border: Border.all(color: Colors.white, width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'เดือน :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            //value: MONTH_Now,
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    MONTH_Now ==
                                                                            null
                                                                        ? 'เลือก'
                                                                        : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),

                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              for (int item = 1;
                                                                  item < 13;
                                                                  item++)
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      '${item}',
                                                                  child: Translate.TranslateAndSetText(
                                                                      '${monthsInThai[item - 1]}',
                                                                      Colors
                                                                          .grey,
                                                                      TextAlign
                                                                          .start,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      12,
                                                                      1),
                                                                )
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              MONTH_Now = value;
                                                              red_Trans_billCancel();
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
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ปี :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
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
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: YE_Th.map(
                                                                (item) =>
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          '${item}',
                                                                      child:
                                                                          Text(
                                                                        '${item}',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                    )).toList(),

                                                            onChanged:
                                                                (value) async {
                                                              YEAR_Now = value;
                                                              red_Trans_billCancel();
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
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ระบบ :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 160,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            // value: YEAR_Now,
                                                            hint: Translate.TranslateAndSetText(
                                                                (ser_payby ==
                                                                            null ||
                                                                        ser_payby ==
                                                                            '0')
                                                                    ? 'ทั้งหมด'
                                                                    : '$ser_payby',
                                                                Colors.grey,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '0',
                                                                child: Translate.TranslateAndSetText(
                                                                    'ทั้งหมด',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '1',
                                                                child: Text(
                                                                  'Web Admin(W)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '2',
                                                                child: Text(
                                                                  'Web User(U)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '3',
                                                                child: Text(
                                                                  'Web Market(LP)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '4',
                                                                child: Text(
                                                                  'Handheld(H)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              )
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              setState(() {
                                                                ser_payby =
                                                                    value;
                                                              });

                                                              // print(value);
                                                              red_Trans_billCancel();
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
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                      height: 20,
                                                      width: 3,
                                                      color: Colors.grey),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppbackgroundColor
                                                            .Sub_Abg_Colors
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.only(
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
                                                    // border: Border.all(color: Colors.white, width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ประเภทวันที่ :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 125,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            // value: YEAR_Now,
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    'ทั้งหมด',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 120,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '0',
                                                                child: Translate.TranslateAndSetText(
                                                                    'ทั้งหมด',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '1',
                                                                child: Translate.TranslateAndSetText(
                                                                    'วันที่ทำรายการ',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '2',
                                                                child: Translate.TranslateAndSetText(
                                                                    'วันที่รับชำระ',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              // DropdownMenuItem<
                                                              //     String>(
                                                              //   value: '3',
                                                              //   child: Text(
                                                              //     'กำหนดชำระ',
                                                              //     textAlign:
                                                              //         TextAlign
                                                              //             .center,
                                                              //     style:
                                                              //         TextStyle(
                                                              //       overflow:
                                                              //           TextOverflow
                                                              //               .ellipsis,
                                                              //       fontSize:
                                                              //           14,
                                                              //       color: Colors
                                                              //           .grey,
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              setState(() {
                                                                Text_searchBar1
                                                                    .clear();
                                                                _TransReBillModels =
                                                                    TransReBillModels_;
                                                                Date_ser =
                                                                    int.parse(
                                                                        value!);
                                                              });
                                                              // print(Date_ser);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ค้นหาวันที่ :',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      // SizedBox(
                                                      //   height: 30, //Date_ser
                                                      //   width: 120,
                                                      //   child: _searchBar2(),
                                                      // )
                                                      Container(
                                                        height: 25, //Date_ser
                                                        width: 120,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                          borderRadius: const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1),
                                                        ),
                                                        child: _searchBar1(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                // Expanded(
                                                //     child:
                                                //         Next_page_billCancel())
                                              ],
                                            ),
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 10,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: ac9
                                                        .where((item) =>
                                                            item["st"] ==
                                                            '1') // Filter items
                                                        .toList() // Convert to a list
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int index = entry
                                                          .key; // Get the index
                                                      var item = entry
                                                          .value; // Get the item

                                                      return Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                            item["pn"] ??
                                                                "", // Use "pn" or an empty string if null
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            (item["ser"] ==
                                                                    '10')
                                                                ? TextAlign
                                                                    .right
                                                                : (item["ser"] == '12' ||
                                                                        item["ser"] ==
                                                                            '14' ||
                                                                        item["ser"] ==
                                                                            '15')
                                                                    ? TextAlign
                                                                        .center
                                                                    : TextAlign
                                                                        .start,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                Container(
                                                  width: 80,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          '...',
                                                          AccountScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child:
                                                // Translate
                                                //         .TranslateAndSetText(
                                                //             'เลขที่สัญญา',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'วันที่ทำรายการ',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'วันที่รับชำระ',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'เลขที่ใบเสร็จ',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'เลขที่ใบวางบิล',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'โซน',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'รหัสพื้นที่',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'ชื่อร้านค้า',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.start,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'จำนวนเงิน',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.end,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // // Expanded(
                                                // //   flex: 1,
                                                // //   child: Padding(
                                                // //     padding:
                                                // //         EdgeInsets.all(8.0),
                                                // //     child: Text(
                                                // //       'กำหนดชำระ',
                                                // //       textAlign: TextAlign.end,
                                                // //       style: TextStyle(
                                                // //         color:
                                                // //             AccountScreen_Color
                                                // //                 .Colors_Text1_,
                                                // //         fontWeight:
                                                // //             FontWeight.bold,
                                                // //         fontFamily:
                                                // //             FontWeight_.Fonts_T,
                                                // //       ),
                                                // //     ),
                                                // //   ),
                                                // // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'ช่องทางชำระ',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.center,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // // Expanded(
                                                // //   flex: 1,
                                                // //   child: Padding(
                                                // //     padding:
                                                // //         EdgeInsets.all(8.0),
                                                // //     child: Text(
                                                // //       'ทำรายการ',
                                                // //       textAlign:
                                                // //           TextAlign.center,
                                                // //       style: TextStyle(
                                                // //         color:
                                                // //             AccountScreen_Color
                                                // //                 .Colors_Text1_,
                                                // //         fontWeight:
                                                // //             FontWeight.bold,
                                                // //         fontFamily:
                                                // //             FontWeight_.Fonts_T,
                                                // //       ),
                                                // //     ),
                                                // //   ),
                                                // // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Padding(
                                                //     padding:
                                                //         EdgeInsets.all(8.0),
                                                //     child: Translate
                                                //         .TranslateAndSetText(
                                                //             'สถานะ ',
                                                //             AccountScreen_Color
                                                //                 .Colors_Text1_,
                                                //             TextAlign.center,
                                                //             FontWeight.bold,
                                                //             FontWeight_.Fonts_T,
                                                //             14,
                                                //             1),
                                                //   ),
                                                // ),
                                                // SizedBox(
                                                //   width: 70,
                                                // )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.63,
                                          width: Responsive.isDesktop(context)
                                              ? calculatedWidth
                                              : 1200,
                                          decoration: const BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(0)),
                                            // border: Border.all(color: Colors.grey, width: 1),
                                          ),
                                          child: _TransReBillModels.isEmpty
                                              ? SizedBox(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const CircularProgressIndicator(),
                                                      StreamBuilder(
                                                        stream: Stream.periodic(
                                                            const Duration(
                                                                milliseconds:
                                                                    25),
                                                            (i) => i),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot.hasData)
                                                            return const Text(
                                                                '');
                                                          double elapsed = double
                                                                  .parse(snapshot
                                                                      .data
                                                                      .toString()) *
                                                              0.05;
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: (elapsed >
                                                                    8.00)
                                                                ? const Text(
                                                                    'ไม่พบข้อมูล',
                                                                    style: TextStyle(
                                                                        color: PeopleChaoScreen_Color
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
                                                                        color: PeopleChaoScreen_Color
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
                                                  controller:
                                                      _scrollController2,
                                                  // itemExtent: 50,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _TransReBillModels.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Column(
                                                      children: [
                                                        Material(
                                                          color: tappedIndex_ ==
                                                                  index
                                                                      .toString()
                                                              ? tappedIndex_Color
                                                                  .tappedIndex_Colors
                                                              : AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                          child: Container(
                                                            // color: tappedIndex_ ==
                                                            //         index.toString()
                                                            //     ? tappedIndex_Color
                                                            //         .tappedIndex_Colors
                                                            //         .withOpacity(0.5)
                                                            //     : null,
                                                            child: ListTile(
                                                                // onTap:
                                                                //     () async {
                                                                //   // setState(() {
                                                                //   //   tappedIndex_ =
                                                                //   //       index
                                                                //   //           .toString();
                                                                //   //   // red_Trans_select(
                                                                //   //   //     index);
                                                                //   //   // red_Invoice(
                                                                //   //   //     index);
                                                                //   // });

                                                                //   setState(() {
                                                                //     tappedIndex_ =
                                                                //         index
                                                                //             .toString();
                                                                //     red_Trans_select2(
                                                                //         index);
                                                                //     red_Pay2(
                                                                //         index);
                                                                //   });
                                                                //   Future.delayed(
                                                                //       const Duration(
                                                                //           milliseconds:
                                                                //               300),
                                                                //       () async {
                                                                //     checkshowDialog2(
                                                                //       index,
                                                                //     );
                                                                //   });
                                                                // },
                                                                title:
                                                                    Container(
                                                              decoration:
                                                                  BoxDecoration(
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
                                                                  if (where_ac9(
                                                                          "0") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Tooltip(
                                                                          richMessage:
                                                                              TextSpan(
                                                                            text:
                                                                                '${_TransReBillModels[index].cid}',
                                                                            style:
                                                                                const TextStyle(
                                                                              color: HomeScreen_Color.Colors_Text1_,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontFamily: FontWeight_.Fonts_T,
                                                                              //fontSize: 10.0
                                                                            ),
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            color:
                                                                                Colors.grey[200],
                                                                          ),
                                                                          child:
                                                                              AutoSizeText(
                                                                            minFontSize:
                                                                                10,
                                                                            maxFontSize:
                                                                                16,
                                                                            maxLines:
                                                                                1,
                                                                            '${_TransReBillModels[index].cid}',
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "1") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Tooltip(
                                                                          richMessage:
                                                                              const TextSpan(
                                                                            text:
                                                                                '',
                                                                            style:
                                                                                TextStyle(
                                                                              color: HomeScreen_Color.Colors_Text1_,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontFamily: FontWeight_.Fonts_T,
                                                                              //fontSize: 10.0
                                                                            ),
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            color:
                                                                                Colors.grey[200],
                                                                          ),
                                                                          child:
                                                                              AutoSizeText(
                                                                            minFontSize:
                                                                                10,
                                                                            maxFontSize:
                                                                                16,
                                                                            maxLines:
                                                                                1,
                                                                            //  '${_TransReBillModels[index].daterec}',
                                                                            (_TransReBillModels[index].daterec == null)
                                                                                ? '-'
                                                                                : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00').year + 543}',
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "2") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          // '${_TransReBillModels[index].pdate}',
                                                                          (_TransReBillModels[index].pdate == null)
                                                                              ? '-'
                                                                              : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 543}',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "3") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Copy_Text(
                                                                              context,
                                                                              '${_TransReBillModels[index].docno}'),
                                                                          Expanded(
                                                                            child:
                                                                                Tooltip(
                                                                              richMessage: TextSpan(
                                                                                text: '${_TransReBillModels[index].docno}',
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
                                                                                minFontSize: 10,
                                                                                maxFontSize: 16,
                                                                                maxLines: 1,
                                                                                '${_TransReBillModels[index].docno}',
                                                                                textAlign: TextAlign.start,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "4") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          if (_TransReBillModels[index].doctax !=
                                                                              '')
                                                                            Copy_Text(context,
                                                                                _TransReBillModels[index].doctax == '' ? '' : '${_TransReBillModels[index].doctax}'),
                                                                          Expanded(
                                                                            child:
                                                                                Tooltip(
                                                                              richMessage: TextSpan(
                                                                                text: _TransReBillModels[index].doctax == '' ? '' : '${_TransReBillModels[index].doctax}',
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
                                                                                minFontSize: 10,
                                                                                maxFontSize: 16,
                                                                                maxLines: 1,
                                                                                _TransReBillModels[index].doctax == '' ? '' : '${_TransReBillModels[index].doctax}',
                                                                                textAlign: TextAlign.start,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "5") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          if (_TransReBillModels[index].inv2 !=
                                                                              '')
                                                                            Copy_Text(context,
                                                                                _TransReBillModels[index].inv2 == '' ? '' : '${_TransReBillModels[index].inv2}'),
                                                                          Expanded(
                                                                            child:
                                                                                Tooltip(
                                                                              richMessage: TextSpan(
                                                                                text: _TransReBillModels[index].inv2 == '' ? '' : '${_TransReBillModels[index].inv2}',
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
                                                                                minFontSize: 10,
                                                                                maxFontSize: 16,
                                                                                maxLines: 1,
                                                                                _TransReBillModels[index].inv2 == '' ? '' : '${_TransReBillModels[index].inv2}',
                                                                                textAlign: TextAlign.start,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  // Expanded(
                                                                  //   flex:
                                                                  //       1,
                                                                  //   child:
                                                                  //       Padding(
                                                                  //     padding:
                                                                  //         const EdgeInsets.all(8.0),
                                                                  //     child:
                                                                  //         Tooltip(
                                                                  //       richMessage: TextSpan(
                                                                  //         text: '${_TransReBillModels[index].inv2}',
                                                                  //         style: const TextStyle(
                                                                  //           color: HomeScreen_Color.Colors_Text1_,
                                                                  //           fontWeight: FontWeight.bold,
                                                                  //           fontFamily: FontWeight_.Fonts_T,
                                                                  //           //fontSize: 10.0
                                                                  //         ),
                                                                  //       ),
                                                                  //       decoration: BoxDecoration(
                                                                  //         borderRadius: BorderRadius.circular(5),
                                                                  //         color: Colors.grey[200],
                                                                  //       ),
                                                                  //       child: AutoSizeText(
                                                                  //         minFontSize: 10,
                                                                  //         maxFontSize: 16,
                                                                  //         maxLines: 1,
                                                                  //         '${_TransReBillModels[index].inv2}',
                                                                  //         textAlign: TextAlign.start,
                                                                  //         overflow: TextOverflow.ellipsis,
                                                                  //         style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                  //       ),
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                  if (where_ac9(
                                                                          "6") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: _TransReBillModels[index].zn == null
                                                                              ? (_TransReBillModels[index].zn == null)
                                                                                  ? '-'
                                                                                  : '${_TransReBillModels[index].znn}'
                                                                              : '${_TransReBillModels[index].zn}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].zn == null
                                                                              ? (_TransReBillModels[index].zn == null)
                                                                                  ? '-'
                                                                                  : '${_TransReBillModels[index].znn}'
                                                                              : '${_TransReBillModels[index].zn}',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "7") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: _TransReBillModels[index].ln == null
                                                                              ? '${_TransReBillModels[index].room_number}'
                                                                              : '${_TransReBillModels[index].ln}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].ln == null
                                                                              ? '${_TransReBillModels[index].room_number}'
                                                                              : '${_TransReBillModels[index].ln}',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "8") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: _TransReBillModels[index].sname == null
                                                                              ? '${_TransReBillModels[index].remark}'
                                                                              : '${_TransReBillModels[index].sname}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].sname == null
                                                                              ? '${_TransReBillModels[index].remark}'
                                                                              : '${_TransReBillModels[index].sname}',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "9") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: _TransReBillModels[index].cname == null
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].cname}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].cname == null
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].cname}',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "10") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].total_dis == null
                                                                              ? (_TransReBillModels[index].total_bill == null)
                                                                                  ? '0.00'
                                                                                  : '${nFormat.format(double.parse(_TransReBillModels[index].total_bill!))}'
                                                                              : '${nFormat.format(double.parse(_TransReBillModels[index].total_dis!))}',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "11") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          (_TransReBillModels[index].date == null)
                                                                              ? '-'
                                                                              : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date} 00:00:00').year + 543}',
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "12") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          (_TransReBillModels[index].type == null)
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].type}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "13") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              8,
                                                                          maxFontSize:
                                                                              12,
                                                                          maxLines:
                                                                              1,
                                                                          (_TransReBillModels[index].pay_by.toString() == 'W')
                                                                              ? 'Web Admin(W)'
                                                                              : (_TransReBillModels[index].pay_by.toString() == 'U')
                                                                                  ? 'Web User(U)'
                                                                                  : (_TransReBillModels[index].pay_by.toString() == 'LP')
                                                                                      ? 'Web Market(LP)'
                                                                                      : (_TransReBillModels[index].pay_by.toString() == 'H')
                                                                                          ? 'Handheld(H)'
                                                                                          : 'UnKnow ??',
                                                                          // (_TransReBillModels[index].pay_by.toString() == 'W')
                                                                          //     ? 'ผ่านเว็บ แอดมิน (${_TransReBillModels[index].pay_by})'
                                                                          //     : (_TransReBillModels[index].pay_by.toString() == 'U')
                                                                          //         ? 'ผ่านเว็บ User (${_TransReBillModels[index].pay_by})'
                                                                          //         : (_TransReBillModels[index].pay_by.toString() == 'LP')
                                                                          //             ? 'ผ่านเว็บ Market (${_TransReBillModels[index].pay_by})'
                                                                          //             : (_TransReBillModels[index].pay_by.toString() == 'H')
                                                                          //                 ? 'ผ่านเครื่อง Handheld (${_TransReBillModels[index].pay_by})'
                                                                          //                 : 'ไม่ทราบ ?? (${_TransReBillModels[index].pay_by})',
                                                                          // _TransReBillModels[index].shopno == '1'
                                                                          //     ? 'ผ่านระบบผู้เช่า'
                                                                          //     : 'ผ่านระบบแอดมิน',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "14") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].doctax == ''
                                                                              ? 'ยกเลิก'
                                                                              : 'ยกเลิก(ใบกำกับภาษี)',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: Colors.red,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9(
                                                                          "15") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: (_TransReBillModels[index].remark == null)
                                                                              ? ''
                                                                              : '${_TransReBillModels[index].remark}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          (_TransReBillModels[index].remark == null)
                                                                              ? ''
                                                                              : '${_TransReBillModels[index].remark}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: Colors.red,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  Center(
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          InkWell(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              80,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(10),
                                                                                bottomRight: Radius.circular(10)),
                                                                          ),
                                                                          padding:
                                                                              const EdgeInsets.all(2.0),
                                                                          child:
                                                                              Center(child: Translate.TranslateAndSet_TextAutoSize('เรียกดู', CustomerScreen_Color.Colors_Text3_, TextAlign.center, null, Font_.Fonts_T, 8, 14, 1)),
                                                                        ),
                                                                        onTap:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            tappedIndex_ =
                                                                                index.toString();
                                                                            red_Trans_select2(index);
                                                                            red_Pay2(index);
                                                                          });
                                                                          Future.delayed(
                                                                              const Duration(milliseconds: 300),
                                                                              () async {
                                                                            checkshowDialog2(
                                                                              index,
                                                                            );
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  // Expanded(
                                                                  //   flex: 1,
                                                                  //   child:
                                                                  //       Tooltip(
                                                                  //     richMessage:
                                                                  //         const TextSpan(
                                                                  //       text:
                                                                  //           '',
                                                                  //       style:
                                                                  //           TextStyle(
                                                                  //         color: HomeScreen_Color.Colors_Text1_,
                                                                  //         fontWeight: FontWeight.bold,
                                                                  //         fontFamily: FontWeight_.Fonts_T,
                                                                  //         //fontSize: 10.0
                                                                  //       ),
                                                                  //     ),
                                                                  //     decoration:
                                                                  //         BoxDecoration(
                                                                  //       borderRadius:
                                                                  //           BorderRadius.circular(5),
                                                                  //       color:
                                                                  //           Colors.grey[200],
                                                                  //     ),
                                                                  //     child: Translate.TranslateAndSetText(
                                                                  //         _TransReBillModels[index].doctax == '' ? 'ยกเลิก' : 'ยกเลิก(ใบกำกับภาษี)',
                                                                  //         Colors.red,
                                                                  //         TextAlign.center,
                                                                  //         null,
                                                                  //         Font_.Fonts_T,
                                                                  //         14,
                                                                  //         1),

                                                                  //   ),
                                                                  // ),
                                                                  // Padding(
                                                                  //   padding:
                                                                  //       const EdgeInsets.all(0.0),
                                                                  //   child:
                                                                  //       InkWell(
                                                                  //     onTap:
                                                                  //         () async {
                                                                  //       setState(() {
                                                                  //         red_Trans_select2(index);
                                                                  //         red_Pay2(index);
                                                                  //       });
                                                                  //       Future.delayed(const Duration(milliseconds: 300),
                                                                  //           () async {
                                                                  //         checkshowDialog2(
                                                                  //           index,
                                                                  //         );
                                                                  //       });
                                                                  //     },
                                                                  //     child:
                                                                  //         Container(
                                                                  //       width:
                                                                  //           80,
                                                                  //       decoration:
                                                                  //           BoxDecoration(
                                                                  //         color: Colors.pink[300],
                                                                  //         borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                  //       ),
                                                                  //       padding:
                                                                  //           const EdgeInsets.all(2.0),
                                                                  //       child:
                                                                  //           Row(
                                                                  //         mainAxisAlignment: MainAxisAlignment.center,
                                                                  //         children: [
                                                                  //           if (_TransReBillModels[index].ptser.toString() != '1')
                                                                  //             if (_TransReBillModels[index].slip == null || _TransReBillModels[index].slip.toString() == 'null' || _TransReBillModels[index].slip.toString() == '') Icon(Icons.image_not_supported),
                                                                  //           Translate.TranslateAndSetText('เรียกดู', AccountScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                                                                  //           // const AutoSizeText(
                                                                  //           //   minFontSize: 10,
                                                                  //           //   maxFontSize: 25,
                                                                  //           //   maxLines: 1,
                                                                  //           //   'เรียกดู',
                                                                  //           //   textAlign: TextAlign.center,
                                                                  //           //   overflow: TextOverflow.ellipsis,
                                                                  //           //   style: TextStyle(
                                                                  //           //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                  //           //       //fontWeight: FontWeight.bold,
                                                                  //           //       fontFamily: Font_.Fonts_T),
                                                                  //           // ),
                                                                  //         ],
                                                                  //       ),
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                ],
                                                              ),
                                                            )),
                                                          ),
                                                        ),
                                                        if (index + 1 ==
                                                                _TransReBillModels
                                                                    .length &&
                                                            _TransReBillModels
                                                                    .length !=
                                                                0)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  '<<- End ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: tappedIndex_Color
                                                                          .End_Colors,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      // color: Colors
                                                                      //     .orange,
                                                                      border: Border.all(
                                                                          color: tappedIndex_Color
                                                                              .End_Colors,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    height: 1,
                                                                  ),
                                                                ),
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  ' End ->>',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: tappedIndex_Color
                                                                          .End_Colors,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  })),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomLeft:
                                                            Radius.circular(6),
                                                        bottomRight:
                                                            Radius.circular(8)),
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
                                            final position = _scrollController2
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
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(3.0),
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

///////////////-------------------------------------------------->
  Widget bill_payCancel_BC_Verifi() {
    double calculatedWidth =
        (ac9_3.where((item) => item["st"] == '1').toList().length <= 9)
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.85 +
                ((ac9_3.where((item) => item["st"] == '1').toList().length -
                        9) *
                    60);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Container(
            width: (Responsive.isDesktop(context)) ? calculatedWidth : 1200,
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
                        : 1200,
                    child: Column(
                      children: [
                        ScrollConfiguration(
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
                                SizedBox(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: (Responsive.isDesktop(context))
                                            ? calculatedWidth
                                            : 1200,
                                        decoration: BoxDecoration(
                                          color:
                                              AppbackgroundColor.TiTile_Colors,
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
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(2.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ค้นหา :',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.center,
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
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(8),
                                                            topRight:
                                                                Radius.circular(
                                                                    0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      child: _searchBarMain1(),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 2, 0, 2),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        // .withOpacity(0.5),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight:
                                                                    Radius
                                                                        .circular(
                                                                            6),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            6)),
                                                        // border: Border.all(
                                                        //     color:
                                                        //         Colors.grey,
                                                        //     width: 1),
                                                      ),
                                                      width: 130,
                                                      // height: 30,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton2<
                                                            String>(
                                                          isExpanded: true,
                                                          hint: Center(
                                                            child: Text(
                                                              'หัวข้อ',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ),

                                                          items: ac9_3
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index = entry
                                                                .key; // Get the index
                                                            var item =
                                                                entry.value;
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: item[
                                                                  "ser"], // Use "ser" as the value
                                                              enabled:
                                                                  false, // Set to true to allow selection
                                                              child:
                                                                  StatefulBuilder(
                                                                builder: (context,
                                                                    menuSetState) {
                                                                  // final isSelected = selectedItems.contains(item);
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      int selectedIndex = ac9_3.indexWhere((items) =>
                                                                          items[
                                                                              "ser"] ==
                                                                          item[
                                                                              "ser"]);
                                                                      // print(ac1[selectedIndex]
                                                                      //     [
                                                                      //     "pn"]);
                                                                      // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                                                      //This rebuilds the StatefulWidget to update the button's text
                                                                      setState(
                                                                          () {
                                                                        if (item["st"]! ==
                                                                            '1') {
                                                                          ac9_3[selectedIndex]["st"] =
                                                                              '0';
                                                                        } else {
                                                                          ac9_3[selectedIndex]["st"] =
                                                                              '1';
                                                                        }
                                                                      });
                                                                      //This rebuilds the dropdownMenu Widget to update the check mark
                                                                      menuSetState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: double
                                                                          .infinity,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          if (item["st"]! ==
                                                                              '1')
                                                                            Icon(
                                                                              Icons.check_box_outlined,
                                                                              color: Colors.green[400],
                                                                            )
                                                                          else
                                                                            const Icon(Icons.check_box_outline_blank),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              item["pn"]!,
                                                                              maxLines: 2,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: AccountScreen_Color.Colors_Text1_,
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
                                                  Container(
                                                      width: 150,
                                                      child:
                                                          Next_page_billCancel_Verifi())
                                                  // Expanded(
                                                  //     child:
                                                  //         Next_page_billCancel())
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppbackgroundColor
                                                            .Sub_Abg_Colors
                                                        .withOpacity(0.5),
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
                                                    // border: Border.all(color: Colors.white, width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'เดือน :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            //value: MONTH_Now,
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    MONTH_Now ==
                                                                            null
                                                                        ? 'เลือก'
                                                                        : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              for (int item = 1;
                                                                  item < 13;
                                                                  item++)
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      '${item}',
                                                                  child: Translate.TranslateAndSetText(
                                                                      '${monthsInThai[item - 1]}',
                                                                      Colors
                                                                          .grey,
                                                                      TextAlign
                                                                          .start,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      12,
                                                                      1),
                                                                )
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              MONTH_Now = value;
                                                              red_Trans_bill_Verifi();

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
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ปี :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
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
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: YE_Th.map(
                                                                (item) =>
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          '${item}',
                                                                      child:
                                                                          Text(
                                                                        '${item}',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                    )).toList(),

                                                            onChanged:
                                                                (value) async {
                                                              YEAR_Now = value;
                                                              red_Trans_bill_Verifi();
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
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ระบบ :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 160,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            // value: YEAR_Now,
                                                            hint: Translate.TranslateAndSetText(
                                                                (ser_payby ==
                                                                            null ||
                                                                        ser_payby ==
                                                                            '0')
                                                                    ? 'ทั้งหมด'
                                                                    : '$ser_payby',
                                                                Colors.grey,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '0',
                                                                child: Translate.TranslateAndSetText(
                                                                    'ทั้งหมด',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '1',
                                                                child: Text(
                                                                  'Web Admin(W)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '2',
                                                                child: Text(
                                                                  'Web User(U)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '3',
                                                                child: Text(
                                                                  'Web Market(LP)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '4',
                                                                child: Text(
                                                                  'Handheld(H)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ),
                                                              )
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              setState(() {
                                                                ser_payby =
                                                                    value;
                                                              });

                                                              // print(value);
                                                              red_Trans_bill_Verifi();
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
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                      height: 20,
                                                      width: 3,
                                                      color: Colors.grey),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppbackgroundColor
                                                            .Sub_Abg_Colors
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.only(
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
                                                    // border: Border.all(color: Colors.white, width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ประเภทวันที่ :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 125,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            // value: YEAR_Now,
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    'ทั้งหมด',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 120,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '0',
                                                                child: Translate.TranslateAndSetText(
                                                                    'ทั้งหมด',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '1',
                                                                child: Translate.TranslateAndSetText(
                                                                    'วันที่ทำรายการ',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '2',
                                                                child: Translate.TranslateAndSetText(
                                                                    'วันที่รับชำระ',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                              ),
                                                              // DropdownMenuItem<
                                                              //     String>(
                                                              //   value: '3',
                                                              //   child: Text(
                                                              //     'กำหนดชำระ',
                                                              //     textAlign:
                                                              //         TextAlign
                                                              //             .center,
                                                              //     style:
                                                              //         TextStyle(
                                                              //       overflow:
                                                              //           TextOverflow
                                                              //               .ellipsis,
                                                              //       fontSize:
                                                              //           14,
                                                              //       color: Colors
                                                              //           .grey,
                                                              //     ),
                                                              //   ),
                                                              // ),
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              setState(() {
                                                                Text_searchBar1
                                                                    .clear();
                                                                _TransReBillModels =
                                                                    TransReBillModels_;
                                                                Date_ser =
                                                                    int.parse(
                                                                        value!);
                                                              });
                                                              // print(Date_ser);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ค้นหาวันที่ :',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      // SizedBox(
                                                      //   height: 30, //Date_ser
                                                      //   width: 120,
                                                      //   child: _searchBar2(),
                                                      // )
                                                      Container(
                                                        height: 25, //Date_ser
                                                        width: 120,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                          borderRadius: const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10)),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1),
                                                        ),
                                                        child: _searchBar1(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                // Expanded(
                                                //     child:
                                                //         Next_page_billCancel())
                                              ],
                                            ),
                                            const Divider(),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: ac9_3
                                                        .where((item) =>
                                                            item["st"] ==
                                                            '1') // Filter items
                                                        .toList() // Convert to a list
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int index = entry
                                                          .key; // Get the index
                                                      var item = entry
                                                          .value; // Get the item

                                                      return Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                            item["pn"] ??
                                                                "", // Use "pn" or an empty string if null
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            (item["ser"] ==
                                                                        '11' ||
                                                                    item["ser"] ==
                                                                        '12' ||
                                                                    item["ser"] ==
                                                                        '13' ||
                                                                    item["ser"] ==
                                                                        '16')
                                                                ? TextAlign
                                                                    .center
                                                                : (item["ser"] ==
                                                                        '9')
                                                                    ? TextAlign
                                                                        .right
                                                                    : TextAlign
                                                                        .start,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                Container(
                                                  width: 80,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          '...',
                                                          AccountScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                )
                                              ],
                                            ),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.center,
                                            //   children: [
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child:
                                            // Translate
                                            //             .TranslateAndSetText(
                                            //                 'เลขที่สัญญา',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.start,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'วันที่ทำรายการ',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.start,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'วันที่รับชำระ',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.start,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'เลขที่ใบเสร็จ',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.start,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     // Expanded(
                                            //     //   flex: 1,
                                            //     //   child: Padding(
                                            //     //     padding:
                                            //     //         EdgeInsets.all(8.0),
                                            //     //     child: Text(
                                            //     //       'เลขที่ใบวางบิล',
                                            //     //       textAlign:
                                            //     //           TextAlign.start,
                                            //     //       style: TextStyle(
                                            //     //         color:
                                            //     //             AccountScreen_Color
                                            //     //                 .Colors_Text1_,
                                            //     //         fontWeight:
                                            //     //             FontWeight.bold,
                                            //     //         fontFamily:
                                            //     //             FontWeight_.Fonts_T,
                                            //     //         //fontSize: 10.0
                                            //     //       ),
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'รหัสพื้นที่',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.start,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'ชื่อร้านค้า',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.start,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),

                                            //     Expanded(
                                            //       flex: 2,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'เหตุผล',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.start,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'จำนวนเงิน',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.end,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     // Expanded(
                                            //     //   flex: 1,
                                            //     //   child: Padding(
                                            //     //     padding:
                                            //     //         EdgeInsets.all(8.0),
                                            //     //     child: Text(
                                            //     //       'กำหนดชำระ',
                                            //     //       textAlign: TextAlign.end,
                                            //     //       style: TextStyle(
                                            //     //         color:
                                            //     //             AccountScreen_Color
                                            //     //                 .Colors_Text1_,
                                            //     //         fontWeight:
                                            //     //             FontWeight.bold,
                                            //     //         fontFamily:
                                            //     //             FontWeight_.Fonts_T,
                                            //     //       ),
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Padding(
                                            //         padding:
                                            //             EdgeInsets.all(8.0),
                                            //         child: Translate
                                            //             .TranslateAndSetText(
                                            //                 'ช่องทางชำระ',
                                            //                 AccountScreen_Color
                                            //                     .Colors_Text1_,
                                            //                 TextAlign.center,
                                            //                 FontWeight.bold,
                                            //                 FontWeight_.Fonts_T,
                                            //                 14,
                                            //                 1),
                                            //       ),
                                            //     ),
                                            //     // Expanded(
                                            //     //   flex: 1,
                                            //     //   child: Padding(
                                            //     //     padding:
                                            //     //         EdgeInsets.all(8.0),
                                            //     //     child: Text(
                                            //     //       'ทำรายการ',
                                            //     //       textAlign:
                                            //     //           TextAlign.center,
                                            //     //       style: TextStyle(
                                            //     //         color:
                                            //     //             AccountScreen_Color
                                            //     //                 .Colors_Text1_,
                                            //     //         fontWeight:
                                            //     //             FontWeight.bold,
                                            //     //         fontFamily:
                                            //     //             FontWeight_.Fonts_T,
                                            //     //       ),
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     // Expanded(
                                            //     //   flex: 1,
                                            //     //   child: Padding(
                                            //     //     padding:
                                            //     //         EdgeInsets.all(8.0),
                                            //     //     child: Translate
                                            //     //         .TranslateAndSetText(
                                            //     //             'สถานะ ',
                                            //     //             AccountScreen_Color
                                            //     //                 .Colors_Text1_,
                                            //     //             TextAlign.center,
                                            //     //             FontWeight.bold,
                                            //     //             FontWeight_.Fonts_T,
                                            //     //             14,
                                            //     //             1),
                                            //     //   ),
                                            //     // ),
                                            //     SizedBox(
                                            //       width: 60,
                                            //     )
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.63,
                                          width: Responsive.isDesktop(context)
                                              ? calculatedWidth
                                              : 1200,
                                          decoration: const BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(0)),
                                            // border: Border.all(color: Colors.grey, width: 1),
                                          ),
                                          child: _TransReBillModels.isEmpty
                                              ? SizedBox(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const CircularProgressIndicator(),
                                                      StreamBuilder(
                                                        stream: Stream.periodic(
                                                            const Duration(
                                                                milliseconds:
                                                                    25),
                                                            (i) => i),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot.hasData)
                                                            return const Text(
                                                                '');
                                                          double elapsed = double
                                                                  .parse(snapshot
                                                                      .data
                                                                      .toString()) *
                                                              0.05;
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: (elapsed >
                                                                    8.00)
                                                                ? const Text(
                                                                    'ไม่พบข้อมูล',
                                                                    style: TextStyle(
                                                                        color: PeopleChaoScreen_Color
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
                                                                        color: PeopleChaoScreen_Color
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
                                                  controller:
                                                      _scrollController2,
                                                  // itemExtent: 50,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      _TransReBillModels.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Column(
                                                      children: [
                                                        Material(
                                                          color: tappedIndex_ ==
                                                                  index
                                                                      .toString()
                                                              ? tappedIndex_Color
                                                                  .tappedIndex_Colors
                                                              : AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                          child: Container(
                                                            // color: tappedIndex_ ==
                                                            //         index.toString()
                                                            //     ? tappedIndex_Color
                                                            //         .tappedIndex_Colors
                                                            //         .withOpacity(0.5)
                                                            //     : null,
                                                            child: ListTile(
                                                                // onTap:
                                                                //     () async {
                                                                //   setState(() {
                                                                //     tappedIndex_ =
                                                                //         index
                                                                //             .toString();
                                                                //     // red_Trans_select(
                                                                //     //     index);
                                                                //     // red_Invoice(
                                                                //     //     index);
                                                                //   });

                                                                // },
                                                                title:
                                                                    Container(
                                                              decoration:
                                                                  BoxDecoration(
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
                                                                  if (where_ac9_3(
                                                                          "0") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text:
                                                                              '${_TransReBillModels[index].cid}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].cid == null
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].cid}',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "1") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (_TransReBillModels[index].daterec ==
                                                                                null)
                                                                            ? '-'
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].daterec} 00:00:00').year + 0}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "2") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (_TransReBillModels[index].pay_by.toString() ==
                                                                                'LP')
                                                                            ? (_TransReBillModels[index].date == null)
                                                                                ? '-'
                                                                                : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].date} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].date} 00:00:00').year + 0}'
                                                                            : '-',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "3") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (_TransReBillModels[index].pdate ==
                                                                                null)
                                                                            ? '-'
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00'))}-${DateTime.parse('${_TransReBillModels[index].pdate} 00:00:00').year + 0}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "4") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Copy_Text(
                                                                              context,
                                                                              _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}'),
                                                                          Expanded(
                                                                            child:
                                                                                Tooltip(
                                                                              richMessage: TextSpan(
                                                                                text: _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}',
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
                                                                                minFontSize: 10,
                                                                                maxFontSize: 16,
                                                                                maxLines: 1,
                                                                                _TransReBillModels[index].doctax == '' ? '${_TransReBillModels[index].docno}' : '${_TransReBillModels[index].doctax}',
                                                                                textAlign: TextAlign.left,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "5") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        _TransReBillModels[index].zn ==
                                                                                null
                                                                            ? '${_TransReBillModels[index].znn}'
                                                                            : '${_TransReBillModels[index].zn}',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "6") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: _TransReBillModels[index].ln == null
                                                                              ? '${_TransReBillModels[index].room_number}'
                                                                              : '${_TransReBillModels[index].ln}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].ln == null
                                                                              ? '${_TransReBillModels[index].room_number}'
                                                                              : '${_TransReBillModels[index].ln}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "7") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: _TransReBillModels[index].sname == null
                                                                              ? '${_TransReBillModels[index].remark}'
                                                                              : '${_TransReBillModels[index].sname}',
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].sname == null
                                                                              ? '${_TransReBillModels[index].remark}'
                                                                              : '${_TransReBillModels[index].sname}',
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "8") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        _TransReBillModels[index].cname ==
                                                                                null
                                                                            ? '-'
                                                                            : '${_TransReBillModels[index].cname}',
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "9") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].total_dis == null
                                                                              ? (_TransReBillModels[index].total_bill == null)
                                                                                  ? ''
                                                                                  : '${nFormat.format(double.parse(_TransReBillModels[index].total_bill!))}'
                                                                              : '${nFormat.format(double.parse(_TransReBillModels[index].total_dis!))}',
                                                                          textAlign:
                                                                              TextAlign.right,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "10") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].type == null
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].type}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "11") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].ref1 == null
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].ref1}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "12") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text:
                                                                              '${_TransReBillModels[index].ref2}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].ref2 == null
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].ref2}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              color: Colors.amber.shade900,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "13") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text:
                                                                              '${_TransReBillModels[index].ref4}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          _TransReBillModels[index].ref4 == null
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].ref4}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "14") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              8,
                                                                          maxFontSize:
                                                                              12,
                                                                          maxLines:
                                                                              1,
                                                                          (_TransReBillModels[index].pay_by.toString() == 'W')
                                                                              ? 'Web Admin (${_TransReBillModels[index].pay_by})'
                                                                              : (_TransReBillModels[index].pay_by.toString() == 'U')
                                                                                  ? 'Web User (${_TransReBillModels[index].pay_by})'
                                                                                  : (_TransReBillModels[index].pay_by.toString() == 'LP')
                                                                                      ? 'Web Market (${_TransReBillModels[index].pay_by})'
                                                                                      : (_TransReBillModels[index].pay_by.toString() == 'LP')
                                                                                          ? 'Handheld (${_TransReBillModels[index].pay_by})'
                                                                                          : 'Unknow ?? (${_TransReBillModels[index].pay_by})',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "15") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            const TextSpan(
                                                                          text:
                                                                              '',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child: Translate.TranslateAndSetText(
                                                                            (_TransReBillModels[index].pay_by.toString() == 'W')
                                                                                ? 'ชำระค่าบริการ'
                                                                                : (_TransReBillModels[index].pay_by.toString() == 'U')
                                                                                    ? 'ชำระค่าบริการ'
                                                                                    : (_TransReBillModels[index].pay_by.toString() == 'LP')
                                                                                        ? 'จองล็อกเสียบ'
                                                                                        : (_TransReBillModels[index].pay_by.toString() == 'LP')
                                                                                            ? 'ชำระค่าบริการ'
                                                                                            : 'ไม่ทราบ ??',
                                                                            AccountScreen_Color.Colors_Text1_,
                                                                            TextAlign.right,
                                                                            null,
                                                                            Font_.Fonts_T,
                                                                            14,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_3(
                                                                          "16") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: (_TransReBillModels[index].remark == null)
                                                                              ? '-'
                                                                              : '${_TransReBillModels[index].remark}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child: Translate.TranslateAndSetText(
                                                                            (_TransReBillModels[index].remark == null)
                                                                                ? '-'
                                                                                : '${_TransReBillModels[index].remark}',
                                                                            Colors.red,
                                                                            TextAlign.center,
                                                                            null,
                                                                            Font_.Fonts_T,
                                                                            14,
                                                                            1),
                                                                      ),
                                                                    ),
                                                                  Center(
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          InkWell(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              80,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(10),
                                                                                bottomRight: Radius.circular(10)),
                                                                          ),
                                                                          padding:
                                                                              const EdgeInsets.all(2.0),
                                                                          child:
                                                                              Center(child: Translate.TranslateAndSet_TextAutoSize('เรียกดู', CustomerScreen_Color.Colors_Text3_, TextAlign.center, null, Font_.Fonts_T, 8, 14, 1)),
                                                                        ),
                                                                        onTap:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            tappedIndex_ =
                                                                                index.toString();
                                                                            red_Trans_select2(index);
                                                                            red_Pay2(index);
                                                                          });
                                                                          Future.delayed(
                                                                              const Duration(milliseconds: 300),
                                                                              () async {
                                                                            checkshowDialog2(
                                                                              index,
                                                                            );
                                                                          });
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                          ),
                                                        ),
                                                        if (index + 1 ==
                                                                _TransReBillModels
                                                                    .length &&
                                                            _TransReBillModels
                                                                    .length !=
                                                                0)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  '<<- End ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: tappedIndex_Color
                                                                          .End_Colors,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      // color: Colors
                                                                      //     .orange,
                                                                      border: Border.all(
                                                                          color: tappedIndex_Color
                                                                              .End_Colors,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    height: 1,
                                                                  ),
                                                                ),
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  ' End ->>',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: tappedIndex_Color
                                                                          .End_Colors,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  })),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomLeft:
                                                            Radius.circular(6),
                                                        bottomRight:
                                                            Radius.circular(8)),
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
                                            final position = _scrollController2
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
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(3.0),
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
                      ],
                    )),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       InkWell(
          //         onTap: () {
          //           _exportExcel_();
          //         },
          //         child: Container(
          //             decoration: BoxDecoration(
          //               color: Colors.grey,
          //               borderRadius: const BorderRadius.only(
          //                   topLeft: Radius.circular(6),
          //                   topRight: Radius.circular(6),
          //                   bottomLeft: Radius.circular(6),
          //                   bottomRight: Radius.circular(6)),
          //               border: Border.all(color: Colors.grey, width: 1),
          //             ),
          //             child: Row(
          //               children: const [
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Icon(Icons.file_open, color: Colors.black),
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Text(
          //                     'export file',
          //                     style: TextStyle(
          //                         color: AccountScreen_Color.Colors_Text2_,
          //                         // fontWeight:
          //                         //     FontWeight.bold,
          //                         fontFamily: Font_.Fonts_T,
          //                         fontSize: 10.0),
          //                   ),
          //                 ),
          //               ],
          //             )),
          //       ),
          //       InkWell(
          //         onTap: () async {
          //           List newValuePDFimg = [];
          //           for (int index = 0; index < 1; index++) {
          //             if (renTalModels[0].imglogo!.trim() == '' ||
          //                 renTalModels[0].imglogo!.trim() == 'null' ||
          //                 renTalModels[0].imglogo!.trim() == 'Null') {
          //               // newValuePDFimg.add(
          //               //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
          //             } else {
          //               newValuePDFimg.add(
          //                   '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
          //             }
          //           }
          //           Pdfgen_historybill.exportPDF_historybill(
          //             context,
          //             _TransReBillModels,
          //             renTal_name,
          //             ' ${renTalModels[0].bill_addr}',
          //             ' ${renTalModels[0].bill_email}',
          //             ' ${renTalModels[0].bill_tel}',
          //             ' ${renTalModels[0].bill_tax}',
          //             ' ${renTalModels[0].bill_name}',
          //             newValuePDFimg,
          //           );
          //         },
          //         child: Container(
          //             decoration: BoxDecoration(
          //               color: Colors.grey,
          //               borderRadius: const BorderRadius.only(
          //                   topLeft: Radius.circular(6),
          //                   topRight: Radius.circular(6),
          //                   bottomLeft: Radius.circular(6),
          //                   bottomRight: Radius.circular(6)),
          //               border: Border.all(color: Colors.grey, width: 1),
          //             ),
          //             child: Row(
          //               children: const [
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Icon(Icons.print, color: Colors.black),
          //                 ),
          //                 Padding(
          //                   padding: EdgeInsets.all(8.0),
          //                   child: Text(
          //                     'พิมพ์',
          //                     style: TextStyle(
          //                         color: AccountScreen_Color.Colors_Text2_,
          //                         // fontWeight:
          //                         //     FontWeight.bold,
          //                         fontFamily: Font_.Fonts_T,
          //                         fontSize: 10.0),
          //                   ),
          //                 ),
          //               ],
          //             )),
          //       ),
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     child: Row(
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: InkWell(
          //             onTap: () {},
          //             child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Colors.orange[200],
          //                   borderRadius: const BorderRadius.only(
          //                       topLeft: Radius.circular(6),
          //                       topRight: Radius.circular(6),
          //                       bottomLeft: Radius.circular(6),
          //                       bottomRight: Radius.circular(6)),
          //                   border: Border.all(color: Colors.grey, width: 1),
          //                 ),
          //                 child: Row(
          //                   children: const [
          //                     Padding(
          //                       padding: EdgeInsets.all(8.0),
          //                       child: Icon(Icons.cancel_presentation,
          //                           color: Colors.black),
          //                     ),
          //                     Padding(
          //                       padding: EdgeInsets.all(8.0),
          //                       child: Text(
          //                         'ยกเลิกการรับชำระ',
          //                         style: TextStyle(
          //                           color: AccountScreen_Color.Colors_Text2_,
          //                           // fontWeight:
          //                           //     FontWeight.bold,
          //                           fontFamily: Font_.Fonts_T,
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 )),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: InkWell(
          //             onTap: () {},
          //             child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Colors.red[200],
          //                   borderRadius: const BorderRadius.only(
          //                       topLeft: Radius.circular(6),
          //                       topRight: Radius.circular(6),
          //                       bottomLeft: Radius.circular(6),
          //                       bottomRight: Radius.circular(6)),
          //                   border: Border.all(color: Colors.grey, width: 1),
          //                 ),
          //                 child: Row(
          //                   children: const [
          //                     Padding(
          //                       padding: EdgeInsets.all(8.0),
          //                       child: Icon(Icons.cancel_outlined,
          //                           color: Colors.black),
          //                     ),
          //                     Padding(
          //                       padding: EdgeInsets.all(8.0),
          //                       child: Text(
          //                         'ลดหนี้',
          //                         style: TextStyle(
          //                           color: AccountScreen_Color.Colors_Text2_,
          //                           // fontWeight:
          //                           //     FontWeight.bold,
          //                           fontFamily: Font_.Fonts_T,
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 )),
          //           ),
          //         ),
          //         Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: InkWell(
          //             onTap: () {},
          //             child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Colors.green[200],
          //                   borderRadius: const BorderRadius.only(
          //                       topLeft: Radius.circular(6),
          //                       topRight: Radius.circular(6),
          //                       bottomLeft: Radius.circular(6),
          //                       bottomRight: Radius.circular(6)),
          //                   border: Border.all(color: Colors.grey, width: 1),
          //                 ),
          //                 child: Row(
          //                   children: const [
          //                     Padding(
          //                       padding: EdgeInsets.all(8.0),
          //                       child: Icon(Icons.refresh, color: Colors.black),
          //                     ),
          //                     Padding(
          //                       padding: EdgeInsets.all(8.0),
          //                       child: Text(
          //                         'เปลี่ยนสถานะบิล',
          //                         style: TextStyle(
          //                           color: AccountScreen_Color.Colors_Text2_,
          //                           // fontWeight:
          //                           //     FontWeight.bold,
          //                           fontFamily: Font_.Fonts_T,
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 )),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }

  ///-------------------------------------------------------------------->
  Widget bill_InvoceCancel_BC() {
    double calculatedWidth =
        (ac9_2.where((item) => item["st"] == '1').toList().length <= 8)
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.85 +
                ((ac9_2.where((item) => item["st"] == '1').toList().length -
                        8) *
                    60);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Container(
            width: (Responsive.isDesktop(context)) ? calculatedWidth : 1200,
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
                        : 1200,
                    child: Column(
                      children: [
                        ScrollConfiguration(
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
                                SizedBox(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: (Responsive.isDesktop(context))
                                            ? calculatedWidth
                                            : 1200,
                                        decoration: BoxDecoration(
                                          color:
                                              AppbackgroundColor.TiTile_Colors,
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
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(2.0),
                                                    child: Translate
                                                        .TranslateAndSetText(
                                                            'ค้นหา :',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.center,
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
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        borderRadius: const BorderRadius
                                                                .only(
                                                            topLeft: Radius
                                                                .circular(8),
                                                            topRight:
                                                                Radius.circular(
                                                                    0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    8),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    0)),
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                      ),
                                                      child: _searchBarMain2(),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 2, 2, 2),
                                                    child: Container(
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        // .withOpacity(0.5),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                topRight:
                                                                    Radius
                                                                        .circular(
                                                                            8),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            8)),
                                                        // border: Border.all(
                                                        //     color:
                                                        //         Colors.grey,
                                                        //     width: 1),
                                                      ),
                                                      width: 130,
                                                      // height: 30,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton2<
                                                            String>(
                                                          isExpanded: true,
                                                          hint: Center(
                                                            child: Text(
                                                              'หัวข้อ',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                              ),
                                                            ),
                                                          ),

                                                          items: ac9_2
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            int index = entry
                                                                .key; // Get the index
                                                            var item =
                                                                entry.value;
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: item[
                                                                  "ser"], // Use "ser" as the value
                                                              enabled:
                                                                  false, // Set to true to allow selection
                                                              child:
                                                                  StatefulBuilder(
                                                                builder: (context,
                                                                    menuSetState) {
                                                                  // final isSelected = selectedItems.contains(item);
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      int selectedIndex = ac9_2.indexWhere((items) =>
                                                                          items[
                                                                              "ser"] ==
                                                                          item[
                                                                              "ser"]);
                                                                      // print(ac1[selectedIndex]
                                                                      //     [
                                                                      //     "pn"]);
                                                                      // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
                                                                      //This rebuilds the StatefulWidget to update the button's text
                                                                      setState(
                                                                          () {
                                                                        if (item["st"]! ==
                                                                            '1') {
                                                                          ac9_2[selectedIndex]["st"] =
                                                                              '0';
                                                                        } else {
                                                                          ac9_2[selectedIndex]["st"] =
                                                                              '1';
                                                                        }
                                                                      });
                                                                      //This rebuilds the dropdownMenu Widget to update the check mark
                                                                      menuSetState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height: double
                                                                          .infinity,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          if (item["st"]! ==
                                                                              '1')
                                                                            Icon(
                                                                              Icons.check_box_outlined,
                                                                              color: Colors.green[400],
                                                                            )
                                                                          else
                                                                            const Icon(Icons.check_box_outline_blank),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              item["pn"]!,
                                                                              maxLines: 2,
                                                                              style: const TextStyle(
                                                                                fontSize: 12,
                                                                                color: AccountScreen_Color.Colors_Text1_,
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
                                                  Container(
                                                    width: 150,
                                                    child:
                                                        Next_page_InvoiceCancel(),
                                                  )
                                                  // Expanded(
                                                  //     child:
                                                  //         Next_page_billCancel())
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: AppbackgroundColor
                                                            .Sub_Abg_Colors
                                                        .withOpacity(0.5),
                                                    borderRadius:
                                                        BorderRadius.only(
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
                                                    // border: Border.all(color: Colors.white, width: 1),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'เดือน :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
                                                                ),
                                                              ),
                                                            ),
                                                            isExpanded: false,
                                                            //value: MONTH_Now,
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    MONTH_Now ==
                                                                            null
                                                                        ? 'เลือก'
                                                                        : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    12,
                                                                    1),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: [
                                                              for (int item = 1;
                                                                  item < 13;
                                                                  item++)
                                                                DropdownMenuItem<
                                                                    String>(
                                                                  value:
                                                                      '${item}',
                                                                  child: Translate.TranslateAndSetText(
                                                                      '${monthsInThai[item - 1]}',
                                                                      Colors
                                                                          .grey,
                                                                      TextAlign
                                                                          .start,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      12,
                                                                      1),
                                                                )
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              MONTH_Now = value;
                                                              red_InvoiceMon_bill();

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
                                                        padding:
                                                            EdgeInsets.all(2.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ปี :',
                                                                ReportScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                            borderRadius: BorderRadius.only(
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
                                                            // border: Border.all(color: Colors.grey, width: 1),
                                                          ),
                                                          width: 120,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child:
                                                              DropdownButtonFormField2(
                                                            alignment: Alignment
                                                                .center,
                                                            focusColor:
                                                                Colors.white,
                                                            autofocus: false,
                                                            decoration:
                                                                InputDecoration(
                                                              floatingLabelAlignment:
                                                                  FloatingLabelAlignment
                                                                      .center,
                                                              enabled: true,
                                                              hoverColor:
                                                                  Colors.brown,
                                                              prefixIconColor:
                                                                  Colors.blue,
                                                              fillColor: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.05),
                                                              filled: false,
                                                              isDense: true,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    const BorderSide(
                                                                        color: Colors
                                                                            .red),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              focusedBorder:
                                                                  const OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                ),
                                                                borderSide:
                                                                    BorderSide(
                                                                  width: 1,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          227,
                                                                          227),
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
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            iconSize: 20,
                                                            buttonHeight: 30,
                                                            buttonWidth: 200,
                                                            // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                                            dropdownDecoration:
                                                                BoxDecoration(
                                                              // color: Colors
                                                              //     .amber,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 1),
                                                            ),
                                                            items: YE_Th.map(
                                                                (item) =>
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          '${item}',
                                                                      child:
                                                                          Text(
                                                                        '${item}',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Colors.grey,
                                                                        ),
                                                                      ),
                                                                    )).toList(),

                                                            onChanged:
                                                                (value) async {
                                                              YEAR_Now = value;
                                                              red_InvoiceMon_bill();

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
                                                      // if (InvoiceModels
                                                      //         .length !=
                                                      //     0)
                                                      //   Container(
                                                      //       padding:
                                                      //           const EdgeInsets
                                                      //               .all(8.0),
                                                      //       // width: 130,
                                                      //       child:
                                                      //           Next_page_Save())
                                                    ],
                                                  ),
                                                ),
                                                // Expanded(
                                                //     child: SizedBox(
                                                //   child:
                                                //       Next_page_InvoiceCancel(),
                                                // ))
                                              ],
                                            ),
                                            const Divider(),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: ac9_2
                                                        .where((item) =>
                                                            item["st"] ==
                                                            '1') // Filter items
                                                        .toList() // Convert to a list
                                                        .asMap()
                                                        .entries
                                                        .map((entry) {
                                                      int index = entry
                                                          .key; // Get the index
                                                      var item = entry
                                                          .value; // Get the item

                                                      return Expanded(
                                                        flex: 1,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  0.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                            item["pn"] ??
                                                                "", // Use "pn" or an empty string if null
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            (item["ser"] ==
                                                                        '2' ||
                                                                    item["ser"] ==
                                                                        '3' ||
                                                                    item["ser"] ==
                                                                        '8' ||
                                                                    item["ser"] ==
                                                                        '12' ||
                                                                    item["ser"] ==
                                                                        '13' ||
                                                                    item["ser"] ==
                                                                        '15')
                                                                ? TextAlign
                                                                    .center
                                                                : (item["ser"] == '9' ||
                                                                        item["ser"] ==
                                                                            '10' ||
                                                                        item["ser"] ==
                                                                            '11')
                                                                    ? TextAlign
                                                                        .right
                                                                    : TextAlign
                                                                        .start,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                                Container(
                                                  width: 80,
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          '...',
                                                          AccountScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.center,
                                                          FontWeight.bold,
                                                          FontWeight_.Fonts_T,
                                                          14,
                                                          1),
                                                ),
                                              ],
                                            ),
                                            // Row(
                                            //   mainAxisAlignment:
                                            //       MainAxisAlignment.center,
                                            //   children: [
                                            //     // Container(
                                            //     //   width: 70,
                                            //     //   child: const Text(
                                            //     //     '...',
                                            //     //     textAlign: TextAlign.start,
                                            //     //     style: TextStyle(
                                            //     //       color: ManageScreen_Color
                                            //     //           .Colors_Text1_,
                                            //     //       fontWeight:
                                            //     //           FontWeight.bold,
                                            //     //       fontFamily:
                                            //     //           FontWeight_.Fonts_T,
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child:
                                            // Translate
                                            //           .TranslateAndSetText(
                                            //               'เลขที่สัญญา',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.start,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'เลขที่ใบแจ้งหนี้',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.start,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     // Expanded(
                                            //     //   flex: 1,
                                            //     //   child: Text(
                                            //     //     'สถานะ',
                                            //     //     textAlign: TextAlign.start,
                                            //     //     style: TextStyle(
                                            //     //       color: ManageScreen_Color
                                            //     //           .Colors_Text1_,
                                            //     //       fontWeight: FontWeight.bold,
                                            //     //       fontFamily: FontWeight_.Fonts_T,
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'วันที่ออกใบแจ้งหนี้',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.start,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'วันที่ครบกำหนดชำระ',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.start,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 2,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'ชื่อร้านค้า',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.start,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     // Expanded(
                                            //     //   flex: 2,
                                            //     //   child: Text(
                                            //     //     'รอบการเช่า',
                                            //     //     textAlign: TextAlign.start,
                                            //     //     style: TextStyle(
                                            //     //       color: ManageScreen_Color
                                            //     //           .Colors_Text1_,
                                            //     //       fontWeight: FontWeight.bold,
                                            //     //       fontFamily: FontWeight_.Fonts_T,
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'โซน',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.start,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'รหัสพื้นที่',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.start,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'ช่องทางชำระ',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.center,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     // for (int index = 0;
                                            //     //     index < expModels.length;
                                            //     //     index++)
                                            //     //   Expanded(
                                            //     //     flex: 2,
                                            //     //     child: Text(
                                            //     //       '${expModels[index].expname}',
                                            //     //       textAlign: TextAlign.end,
                                            //     //       style: TextStyle(
                                            //     //         color: ManageScreen_Color
                                            //     //             .Colors_Text1_,
                                            //     //         fontWeight: FontWeight.bold,
                                            //     //         fontFamily:
                                            //     //             FontWeight_.Fonts_T,
                                            //     //       ),
                                            //     //     ),
                                            //     //   ),
                                            //     // Expanded(
                                            //     //   flex: 2,
                                            //     //   child: Text(
                                            //     //     'ภาษีมูลค่าเพิ่ม',
                                            //     //     textAlign: TextAlign.end,
                                            //     //     style: TextStyle(
                                            //     //       color: ManageScreen_Color
                                            //     //           .Colors_Text1_,
                                            //     //       fontWeight: FontWeight.bold,
                                            //     //       fontFamily: FontWeight_.Fonts_T,
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     // Expanded(
                                            //     //   flex: 2,
                                            //     //   child: Text(
                                            //     //     'ภาษีหัก ณ ที่จ่าย',
                                            //     //     textAlign: TextAlign.end,
                                            //     //     style: TextStyle(
                                            //     //       color: ManageScreen_Color
                                            //     //           .Colors_Text1_,
                                            //     //       fontWeight: FontWeight.bold,
                                            //     //       fontFamily: FontWeight_.Fonts_T,
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'ส่วนลด',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.end,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'ยอดรวม',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.center,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'ยอดสุทธิ',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.end,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),

                                            //     // Expanded(
                                            //     //   flex: 2,
                                            //     //   child: Text(
                                            //     //     'หมายเหตุ',
                                            //     //     textAlign: TextAlign.end,
                                            //     //     style: TextStyle(
                                            //     //       color: ManageScreen_Color
                                            //     //           .Colors_Text1_,
                                            //     //       fontWeight: FontWeight.bold,
                                            //     //       fontFamily: FontWeight_.Fonts_T,
                                            //     //     ),
                                            //     //   ),
                                            //     // ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Translate
                                            //           .TranslateAndSetText(
                                            //               'สถานะ',
                                            //               AccountScreen_Color
                                            //                   .Colors_Text1_,
                                            //               TextAlign.end,
                                            //               FontWeight.bold,
                                            //               FontWeight_.Fonts_T,
                                            //               14,
                                            //               1),
                                            //     ),
                                            //     Expanded(
                                            //       flex: 1,
                                            //       child: Text(
                                            //         '',
                                            //         textAlign: TextAlign.end,
                                            //         style: TextStyle(
                                            //           color: ManageScreen_Color
                                            //               .Colors_Text1_,
                                            //           fontWeight:
                                            //               FontWeight.bold,
                                            //           fontFamily:
                                            //               FontWeight_.Fonts_T,
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.63,
                                          width: Responsive.isDesktop(context)
                                              ? calculatedWidth
                                              : 1200,
                                          decoration: const BoxDecoration(
                                            color: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(0),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight:
                                                    Radius.circular(0)),
                                            // border: Border.all(color: Colors.grey, width: 1),
                                          ),
                                          child: InvoiceModels.isEmpty
                                              ? SizedBox(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const CircularProgressIndicator(),
                                                      StreamBuilder(
                                                        stream: Stream.periodic(
                                                            const Duration(
                                                                milliseconds:
                                                                    25),
                                                            (i) => i),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (!snapshot.hasData)
                                                            return const Text(
                                                                '');
                                                          double elapsed = double
                                                                  .parse(snapshot
                                                                      .data
                                                                      .toString()) *
                                                              0.05;
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: (elapsed >
                                                                    8.00)
                                                                ? const Text(
                                                                    'No Data',
                                                                    style: TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        fontFamily:
                                                                            Font_.Fonts_T
                                                                        //fontSize: 10.0
                                                                        ),
                                                                  )
                                                                : Text(
                                                                    'Download : ${elapsed.toStringAsFixed(2)} s.',
                                                                    // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
                                                                    style: const TextStyle(
                                                                        color: PeopleChaoScreen_Color
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
                                                  controller:
                                                      _scrollController3,
                                                  // itemExtent: 50,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      InvoiceModels.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Column(
                                                      children: [
                                                        Material(
                                                          color: tappedIndex_ ==
                                                                  index
                                                                      .toString()
                                                              ? tappedIndex_Color
                                                                  .tappedIndex_Colors
                                                              : AppbackgroundColor
                                                                  .Sub_Abg_Colors,
                                                          child: Container(
                                                            child: ListTile(
                                                                // onTap:
                                                                //     () async {
                                                                //   setState(() {
                                                                //     tappedIndex_ =
                                                                //         '${index}';
                                                                //   });
                                                                //   var ciddoc =
                                                                //       InvoiceModels[
                                                                //               index]
                                                                //           .cid;
                                                                //   var qutser =
                                                                //       '1';
                                                                //   var tser = InvoiceModels[
                                                                //           index]
                                                                //       .total_dis;
                                                                //   var docno =
                                                                //       InvoiceModels[
                                                                //               index]
                                                                //           .docno;

                                                                //   setState(() {
                                                                //     payment_Ptser1 =
                                                                //         InvoiceModels[index]
                                                                //             .ptser;
                                                                //     payment_Ptname1 =
                                                                //         InvoiceModels[index]
                                                                //             .ptname;
                                                                //     payment_Bno1 =
                                                                //         InvoiceModels[index]
                                                                //             .bno;

                                                                //     Datex_invoice =
                                                                //         InvoiceModels[index]
                                                                //             .daterec;

                                                                //     payment_type1 =
                                                                //         InvoiceModels[index]
                                                                //             .btype;
                                                                //     payment_bank1 =
                                                                //         InvoiceModels[index]
                                                                //             .bank;
                                                                //   });
                                                                //   red_Trans_select(
                                                                //       index,
                                                                //       ciddoc,
                                                                //       qutser,
                                                                //       tser,
                                                                //       docno);
                                                                // },
                                                                title:
                                                                    Container(
                                                              decoration:
                                                                  BoxDecoration(
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
                                                                  if (where_ac9_2(
                                                                          "0") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        '${InvoiceModels[index].cid}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          //fontSize: 10.0
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "1") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Copy_Text(
                                                                              context,
                                                                              '${InvoiceModels[index].docno}'),
                                                                          // InkWell(
                                                                          //     onTap: () async {
                                                                          //       Future.delayed(const Duration(milliseconds: 500), () {
                                                                          //         Clipboard.setData(ClipboardData(text: '${InvoiceModels[index].docno}'));
                                                                          //         ScaffoldMessenger.of(context).showSnackBar(
                                                                          //           SnackBar(
                                                                          //               content: Row(
                                                                          //             children: [
                                                                          //               Icon(
                                                                          //                 Icons.content_copy,
                                                                          //                 color: Colors.white,
                                                                          //               ),
                                                                          //               SizedBox(width: 8.0),
                                                                          //               Text('Copy :${InvoiceModels[index].docno}', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
                                                                          //             ],
                                                                          //           )),
                                                                          //         );
                                                                          //       });
                                                                          //     },
                                                                          //     child: Icon(
                                                                          //       Icons.content_copy,
                                                                          //       size: 18,
                                                                          //     )),
                                                                          Expanded(
                                                                            child:
                                                                                AutoSizeText(
                                                                              minFontSize: 10,
                                                                              maxFontSize: 16,
                                                                              maxLines: 1,
                                                                              (InvoiceModels[index].docno == null) ? '' : '${InvoiceModels[index].docno}',
                                                                              textAlign: TextAlign.start,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
                                                                                // fontWeight: FontWeight.bold,
                                                                                fontFamily: Font_.Fonts_T,
                                                                                //fontSize: 10.0
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  // Expanded(
                                                                  //   flex: 2,
                                                                  //   child: AutoSizeText(
                                                                  //     minFontSize: 10,
                                                                  //     maxFontSize: 25,
                                                                  //     maxLines: 1,
                                                                  //     '${InvoiceModels[index].docno}',
                                                                  //     textAlign: TextAlign.start,
                                                                  //     overflow: TextOverflow.ellipsis,
                                                                  //     style: TextStyle(
                                                                  //       color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
                                                                  //       // fontWeight: FontWeight.bold,
                                                                  //       fontFamily: Font_.Fonts_T,
                                                                  //       //fontSize: 10.0
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                  if (where_ac9_2(
                                                                          "2") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].daterec == null ||
                                                                                InvoiceModels[index].daterec.toString() == '')
                                                                            ? ''
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec}'))}-${DateTime.parse('${InvoiceModels[index].daterec}').year + 0}',
                                                                        //'${DateFormat('dd-MM-yyyy').format(DateTime.parse('${InvoiceModels[index].daterec}'))}',
                                                                        textAlign:
                                                                            TextAlign.center,

                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          // fontSize: 12.0
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "3") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].date == null ||
                                                                                InvoiceModels[index].date.toString() == '')
                                                                            ? ''
                                                                            : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].date}'))}-${DateTime.parse('${InvoiceModels[index].date}').year + 0}',
                                                                        //'${DateFormat('dd-MM-yyyy').format(DateTime.parse('${InvoiceModels[index].daterec}'))}',
                                                                        textAlign:
                                                                            TextAlign.center,

                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          // fontSize: 12.0
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "4") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].scname ==
                                                                                null)
                                                                            ? ''
                                                                            : '${InvoiceModels[index].scname}',
                                                                        // '${transMeterModels[index].ovalue}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          //fontSize: 12.0
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "5") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].cname ==
                                                                                null)
                                                                            ? ''
                                                                            : '${InvoiceModels[index].cname}',
                                                                        // '${transMeterModels[index].ovalue}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          //fontSize: 12.0
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  // Expanded(
                                                                  //   flex: 1,
                                                                  //   child: AutoSizeText(
                                                                  //     minFontSize: 10,
                                                                  //     maxFontSize: 25,
                                                                  //     maxLines: 1,
                                                                  //     '${InvoiceModels[index].zn}',
                                                                  //     //'${transMeterModels[index].qty}',
                                                                  //     textAlign: TextAlign.start,
                                                                  //     style: TextStyle(
                                                                  //       color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
                                                                  //       // fontWeight:
                                                                  //       //     FontWeight.bold,
                                                                  //       fontFamily: Font_.Fonts_T,
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                  if (where_ac9_2(
                                                                          "6") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].zn ==
                                                                                null)
                                                                            ? ''
                                                                            : '${InvoiceModels[index].zn}',
                                                                        //'${transMeterModels[index].qty}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "7") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].ln ==
                                                                                null)
                                                                            ? ''
                                                                            : '${InvoiceModels[index].ln}',
                                                                        //'${transMeterModels[index].qty}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "8") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child: (InvoiceModels[index].btype == null ||
                                                                              InvoiceModels[index].btype.toString() == '')
                                                                          ? Container(
                                                                              width: 40,
                                                                              height: 30,
                                                                              color: Colors.red[100],
                                                                            )
                                                                          : AutoSizeText(
                                                                              minFontSize: 10,
                                                                              maxFontSize: 16,
                                                                              maxLines: 1,
                                                                              InvoiceModels[index].btype == null ? '' : '${InvoiceModels[index].btype}',
                                                                              //'${transMeterModels[index].qty}',
                                                                              textAlign: TextAlign.center,
                                                                              style: const TextStyle(
                                                                                color: ManageScreen_Color.Colors_Text2_,
                                                                                // fontWeight:
                                                                                //     FontWeight.bold,
                                                                                fontFamily: Font_.Fonts_T,
                                                                              ),
                                                                            ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "9") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].amt_dis == null ||
                                                                                InvoiceModels[index].amt_dis.toString() == '')
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(InvoiceModels[index].amt_dis.toString()))}',
                                                                        // '${nFormat.format(double.parse(InvoiceModels[index].total_bill.toString()) - double.parse(InvoiceModels[index].total_dis.toString()))}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "10") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        //'${InvoiceModels[index].total_bill}',
                                                                        (InvoiceModels[index].total_bill == null ||
                                                                                InvoiceModels[index].total_bill.toString() == '')
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(InvoiceModels[index].total_bill.toString()))}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "11") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].total_dis == null ||
                                                                                InvoiceModels[index].total_dis.toString() == '')
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(InvoiceModels[index].total_dis.toString()))}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "12") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            16,
                                                                        maxLines:
                                                                            1,
                                                                        'ถูกยกเลิก',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.red,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac9_2(
                                                                          "13") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Tooltip(
                                                                        richMessage:
                                                                            TextSpan(
                                                                          text: (InvoiceModels[index].remark == null)
                                                                              ? '-'
                                                                              : '${InvoiceModels[index].remark}',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                HomeScreen_Color.Colors_Text1_,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontFamily:
                                                                                FontWeight_.Fonts_T,
                                                                            //fontSize: 10.0
                                                                          ),
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                          color:
                                                                              Colors.grey[200],
                                                                        ),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              16,
                                                                          maxLines:
                                                                              1,
                                                                          '${InvoiceModels[index].remark}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                            // fontWeight:
                                                                            //     FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  Center(
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              4.0),
                                                                      child:
                                                                          InkWell(
                                                                        child:
                                                                            Container(
                                                                          width:
                                                                              80,
                                                                          decoration:
                                                                              const BoxDecoration(
                                                                            color:
                                                                                Colors.red,
                                                                            borderRadius: BorderRadius.only(
                                                                                topLeft: Radius.circular(10),
                                                                                topRight: Radius.circular(10),
                                                                                bottomLeft: Radius.circular(10),
                                                                                bottomRight: Radius.circular(10)),
                                                                          ),
                                                                          padding:
                                                                              const EdgeInsets.all(2.0),
                                                                          child:
                                                                              Center(child: Translate.TranslateAndSet_TextAutoSize('เรียกดู', CustomerScreen_Color.Colors_Text3_, TextAlign.center, null, Font_.Fonts_T, 8, 14, 1)),
                                                                        ),
                                                                        onTap:
                                                                            () async {
                                                                          setState(
                                                                              () {
                                                                            tappedIndex_ =
                                                                                '${index}';
                                                                          });
                                                                          var ciddoc =
                                                                              InvoiceModels[index].cid;
                                                                          var qutser =
                                                                              '1';
                                                                          var tser =
                                                                              InvoiceModels[index].total_dis;
                                                                          var docno =
                                                                              InvoiceModels[index].docno;

                                                                          setState(
                                                                              () {
                                                                            payment_Ptser1 =
                                                                                InvoiceModels[index].ptser;
                                                                            payment_Ptname1 =
                                                                                InvoiceModels[index].ptname;
                                                                            payment_Bno1 =
                                                                                InvoiceModels[index].bno;

                                                                            Datex_invoice =
                                                                                InvoiceModels[index].daterec;

                                                                            payment_type1 =
                                                                                InvoiceModels[index].btype;
                                                                            payment_bank1 =
                                                                                InvoiceModels[index].bank;
                                                                          });
                                                                          red_Trans_select(
                                                                              index,
                                                                              ciddoc,
                                                                              qutser,
                                                                              tser,
                                                                              docno);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )),
                                                          ),
                                                        ),
                                                        if (index + 1 ==
                                                                InvoiceModels
                                                                    .length &&
                                                            InvoiceModels
                                                                    .length !=
                                                                0)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  '<<- End ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: tappedIndex_Color
                                                                          .End_Colors,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      // color: Colors
                                                                      //     .orange,
                                                                      border: Border.all(
                                                                          color: tappedIndex_Color
                                                                              .End_Colors,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    height: 1,
                                                                  ),
                                                                ),
                                                                AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      25,
                                                                  maxLines: 1,
                                                                  ' End ->>',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: tappedIndex_Color
                                                                          .End_Colors,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  })),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                            _scrollController3.animateTo(
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
                                                            Radius.circular(6),
                                                        topRight:
                                                            Radius.circular(6),
                                                        bottomLeft:
                                                            Radius.circular(6),
                                                        bottomRight:
                                                            Radius.circular(8)),
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
                                          if (_scrollController3.hasClients) {
                                            final position = _scrollController3
                                                .position.maxScrollExtent;
                                            _scrollController3.animateTo(
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
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(3.0),
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
                                        onTap: _moveUp3,
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
                                        onTap: _moveDown3,
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

  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<FinnancetransModel> finnancetransModels = [];
//////////////----------------------------->
  Future<Null> red_Trans_select2(index) async {
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
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);

          var sumPvatx = double.parse(_TransReBillHistoryModel.pvat!);
          var sumVatx = double.parse(_TransReBillHistoryModel.vat!);
          var sumWhtx = double.parse(_TransReBillHistoryModel.wht!);
          var sumAmtx = double.parse(_TransReBillHistoryModel.total!);
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

  Future<Null> red_Pay2(index) async {
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

  ////////--------------------------------------------------------------->
  Future<Null> red_Trans_select(index, ciddoc, qutser, tser, docno) async {
    if (_InvoiceHistoryModels.length != 0) {
      setState(() {
        _InvoiceHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        sum_disamt = 0;
        sum_disp = 0;
      });
    }
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

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog2(index) async {
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
                                              'รายละเอียดบิล(ถูกยกเลิก)',
                                              AccountScreen_Color.Colors_Text1_,
                                              TextAlign.center,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
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
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Translate
                                                        .TranslateAndSetText(
                                                            'เลขที่บิล : ',
                                                            Colors.red,
                                                            TextAlign.center,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1),
                                                    Center(
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 12,
                                                        '${_TransReBillModels[index].docno}(ถูกยกเลิก)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T
                                                            //fontSize: 10.0
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_TransReBillModels[index]
                                                          .doctax !=
                                                      null &&
                                                  _TransReBillModels[index]
                                                          .doctax
                                                          .toString() !=
                                                      '')
                                                Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Translate
                                                          .TranslateAndSetText(
                                                              'ใบกำกับภาษี : ',
                                                              Colors.red,
                                                              TextAlign.center,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                      Center(
                                                        child: AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 12,
                                                          '${_TransReBillModels[index].doctax}(ถูกยกเลิก)',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T
                                                              //fontSize: 10.0
                                                              //fontSize: 10.0
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
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'กำหนดชำระ',
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
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'VAT',
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
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
                                          maxLines: 1,
                                          'WHT',
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
                                                            ? '-'
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
                                                            ? '-'
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
                                                      flex: 2,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        _TransReBillHistoryModels[
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
                                                        (_TransReBillHistoryModels[
                                                                        index]
                                                                    .expname ==
                                                                null)
                                                            ? '-'
                                                            : '${_TransReBillHistoryModels[index].expname}',
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
                                          width: 300,
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
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        12,
                                                        1),
                                                //  AutoSizeText(
                                                //   minFontSize: 8,
                                                //   maxFontSize: 13,
                                                //   'วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 0}',
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
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'รูปแบบการชำระ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        12,
                                                        1),
                                                //  AutoSizeText(
                                                //   minFontSize: 8,
                                                //   maxFontSize: 13,
                                                //   'รูปแบบการชำระ',
                                                //   textAlign:
                                                //       TextAlign.end,
                                                //   style: TextStyle(
                                                //       color: PeopleChaoScreen_Color
                                                //           .Colors_Text1_,
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
                                                //           FontWeight_
                                                //               .Fonts_T
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
                                                          '${i + 1}. Total : ${nFormat.format(double.parse(finnancetransModels[i].amt!))}  (${finnancetransModels[i].ptname})',
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
                                                      //           FontWeight
                                                      //               .w500,
                                                      //       fontFamily: Font_
                                                      //           .Fonts_T),
                                                      // ),
                                                      if (finnancetransModels[i]
                                                              .type
                                                              .toString() !=
                                                          'CASH')
                                                        AutoSizeText(
                                                          minFontSize: 8,
                                                          maxFontSize: 11,
                                                          '  ** ${i + 1}.1. Bank : ${finnancetransModels[i].bank} , No. : ${finnancetransModels[i].bno}',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .grey[800],
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
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
                                                                    'รวม',
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
                                                                //  AutoSizeText(
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
                      (Slip_history.toString() == '' ||
                              Slip_history == null ||
                              Slip_history.toString() == 'null')
                          ? const SizedBox()
                          : Container(
                              padding: const EdgeInsets.all(8.0),
                              width: 180,
                              child: InkWell(
                                onTap: () {
                                  bool hasNonCashTransaction =
                                      finnancetransModels.any((transaction) {
                                    return transaction.ptser
                                            .toString()
                                            .trim() ==
                                        '7';
                                  });

                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        backgroundColor:
                                            AppbackgroundColor.Sub_Abg_Colors,
                                        titlePadding: const EdgeInsets.all(0.0),
                                        contentPadding:
                                            const EdgeInsets.all(10.0),
                                        actionsPadding:
                                            const EdgeInsets.all(6.0),
                                        title: Center(
                                          child: Column(
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Icon(
                                                          Icons.highlight_off,
                                                          size: 30,
                                                          color:
                                                              Colors.red[700]),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Translate.TranslateAndSetText(
                                                  'บิลเลขที่  ${_TransReBillModels[index].docno} ',
                                                  AccountScreen_Color
                                                      .Colors_Text1_,
                                                  TextAlign.start,
                                                  FontWeight.bold,
                                                  FontWeight_.Fonts_T,
                                                  12,
                                                  1),
                                              // Text(
                                              //   'บิลเลขที่  ${_TransReBillModels[index].docno} ',
                                              //   maxLines: 1,
                                              //   textAlign: TextAlign.start,
                                              //   style: const TextStyle(
                                              //       color: Colors.black,
                                              //       fontWeight: FontWeight.bold,
                                              //       fontFamily:
                                              //           FontWeight_.Fonts_T,
                                              //       fontSize: 12.0),
                                              // ),
                                              (hasNonCashTransaction == true)
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(2.0),
                                                            child: Text(
                                                              '${Slip_history}',
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
                                                          ),
                                                          InkWell(
                                                            onTap: () async {
                                                              final String url =
                                                                  '${ref_2}';
                                                              if (await canLaunch(
                                                                  url)) {
                                                                await launch(
                                                                    url);
                                                              } else {
                                                                throw 'Could not launch $url';
                                                              }
                                                            },
                                                            child: Icon(
                                                              Icons
                                                                  .open_in_browser,
                                                              color:
                                                                  Colors.blue,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ])
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          '${Slip_history}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                              fontSize: 12.0),
                                                        ),
                                                        InkWell(
                                                          onTap: () =>
                                                              downloadImage_slip(
                                                                  '${MyConstant().domain}/files/$foder/slip/${Slip_history}',
                                                                  '${_TransReBillModels[index].docno}'),
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
                                        content: (hasNonCashTransaction == true)
                                            ? StreamBuilder(
                                                stream: Stream.periodic(
                                                    const Duration(seconds: 0)),
                                                builder: (context, snapshot) {
                                                  return SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        Container(
                                                          // height: 600,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          child: WebViewX2Pagebeamcheck(
                                                              id_ser: (Slip_history ==
                                                                          '' ||
                                                                      Slip_history ==
                                                                          null)
                                                                  ? ref_2
                                                                  : Slip_history),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                })
                                            : SingleChildScrollView(
                                                child:
                                                    ListBody(children: <Widget>[
                                                SizedBox(
                                                  width: 300,
                                                  child: Image.network(
                                                      '${MyConstant().domain}/files/$foder/slip/${Slip_history}'),
                                                )
                                              ])),
                                        actions: <Widget>[
                                          (hasNonCashTransaction == true)
                                              ? SizedBox()
                                              : SizedBox(
                                                  // width: 300,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                    decoration: BoxDecoration(
                                      color: Colors.blue[200],
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(6),
                                          topRight: Radius.circular(6),
                                          bottomLeft: Radius.circular(6),
                                          bottomRight: Radius.circular(6)),
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                    ),
                                    child: (finnancetransModels
                                                .any((transaction) {
                                              return transaction.ptser
                                                      .toString()
                                                      .trim() ==
                                                  '7';
                                            }) ==
                                            false)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(Icons.image,
                                                    color: Colors.black),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'หลักฐานการโอน',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        14,
                                                        1),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        4, 0, 4, 0),
                                                child: CircleAvatar(
                                                  radius: 12.0,
                                                  backgroundImage: AssetImage(
                                                      'images/LogoBank/BEAM.png'),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ชำระ/ตรวจสอบ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        14,
                                                        1),
                                                //  Text(
                                                //   'ชำระ/ตรวจสอบ',
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
                ],
              ),
            ));
  }

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(index, docno) async {
    int selectedIndex = InvoiceModels.indexWhere(
        (item) => item.docno.toString() == docno.toString());

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
                                              14,
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
                                                  14,
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
                                                  14,
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
                                            14,
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
                                            14,
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
                                            14,
                                            1),
                                      ),
                                      const Expanded(
                                        flex: 1,
                                        child: AutoSizeText(
                                          minFontSize: 8,
                                          maxFontSize: 14,
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
                                            14,
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
                                            14,
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
                                                        maxFontSize: 14,
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
                                                        maxFontSize: 14,
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
                                                              maxFontSize: 14,
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
                                                              maxFontSize: 14,
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
                                                        maxFontSize: 14,
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
                                                        maxFontSize: 14,
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
                                                        maxFontSize: 14,
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
                                                        maxFontSize: 14,
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
                                          width: 300,
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
                                                        'วันที่ออกใบแจ้งหนี้/วางบิล : ${DateFormat('dd-MM').format(DateTime.parse('${Datex_invoice}'))}-${DateTime.parse('${Datex_invoice}').year + 0}',
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
                                              ),
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'รูปแบบชำระ : ',
                                                        AccountScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.start,
                                                        null,
                                                        Font_.Fonts_T,
                                                        12,
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
                                                        12,
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
                                                                12,
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
                  ])
                ],
              ),
            ));
  }
}
