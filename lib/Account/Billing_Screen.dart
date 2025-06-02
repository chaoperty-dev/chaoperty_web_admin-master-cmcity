import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_BillingNoteInvlice_PDF.dart';
import '../Model/GetCFinnancetrans_Model.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetInvoiceRe_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRegis_model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/GetZone_Model.dart';
import '../Model/chack_pay_invoice_model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Responsive/responsive.dart';
import '../Style/File_s.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Ac_Sub/Account_Bill_Invoce.dart';
import 'Ac_Sub/Account_Bill_Invoce_Success.dart';
import 'Verifi_Exc_Billing.dart';
import '../Account/Ac_List/Ac_List_Title.dart';

class BillingScreen extends StatefulWidget {
  final Texts;
  const BillingScreen({super.key, this.Texts});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var nFormat2 = NumberFormat("###0.00", "en_US");
  TextEditingController Text_searchBar_main1 = TextEditingController();
  TextEditingController Text_searchBar_main2 = TextEditingController();
  //-------------------------------------->
  TextEditingController Text_searchBar1 = TextEditingController();
  TextEditingController Text_searchBar2 = TextEditingController();
  final Formbecause_ = TextEditingController();
  //-------------------------------------->
  DateTime datex = DateTime.now();
  int? show_more;
  String tappedIndex_ = '';
  int Ser_Tap = 0;
  int Status_dates = 0;
  //-------------------------------------->
  List<ZoneModel> zoneModels = [];
  List<ZoneModel> zoneModels_report = [];
  List<InvoiceReModel> InvoiceModels_Save = [];
  List<InvoiceReModel> InvoiceModels = [];
  List<Regis_model> regis_models = [];
  List<InvoiceReModel> _InvoiceModels = <InvoiceReModel>[];
  List<InvoiceReModel> limitedList_InvoiceModels_ = [];
  List<TransReBillModel> TransReBillModels_ = [];
  List<TransReBillHistoryModel> TranHisBillModels = [];
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<PayMentModel> payMentModels = [];
  List<ExpModel> expModels = [];
  List<RenTalModel> renTalModels = [];
  List<TransModel> _TransModels = [];
  List<Map<String, String>> ac4_1 = [];
  List<Map<String, String>> ac4_3 = [];
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
  String? rtname,
      rtser,
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
      newValuePDFimg_QR,
      api_key;
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
  List<String> invoice_select = [];
  List<String> invoice_loade_Success = [];
  ///////////--------------------------------------------->
  List<String> invoice_select_delete = [];
  List<String> invoice_loade_Success_delete = [];

  ///////////--------------------------------------------->
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0;
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  ///////////--------------------------------------------->
  int limit_save = 50; // The maximum number of items you want
  int offset_save = 0; // The starting index of items you want
  int endIndex_save = 0;
  int? Cancell_bill = 0, Day_Cancell_bill = 0;
  ///////////--------------------------------------------->
  String? numinvoice;
  int TitleType_Default_Receipt = 0;
  String _ReportValue_type = "ไม่ระบุ";
  String? TitleType_Default_Receipt_Name;
  ///////////--------------------------------------------->
  var round_p, paper, paper_run;
  ///////////--------------------------------------------->
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'คู่ฉบับ',
    'สำเนา',
    'สำเนาคู่ฉบับ',
  ];
  ///////////--------------------------------------------->
  String? base64_Imgmap, tem_page_ser;
  ///////////--------------------------------------------->
  ScrollController _scrollController1 = ScrollController();
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
  String randomString = '';

  String? email_login;
  String? seremail_login;
  final Pincontroller = TextEditingController();
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

  ///////////--------------------------------------------->
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
      ac4_1.addAll(
          AcListTitle().ac_4_1); // Use addAll to add the contents of the list
      ac4_3.addAll(AcListTitle().ac_4_3);
    });
  }

  ////////////----------------------------------->
  where_ac4_1(String ser) {
    if (ac4_1
        .where((item) =>
            item["ser"].toString() == ser && item["st"].toString() == '1')
        .isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  ////////////----------------------------------->
  where_ac4_3(String ser) {
    if (ac4_3
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
      email_login = preferences.getString('email');
      seremail_login = preferences.getString('ser');
      // fname_ = preferences.getString('fname');
      // if (preferences.getString('renTalSer') == '65') {
      //   viewTab = 0;
      // }
    });
    red_InvoiceMon_bill();
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
          var api = renTalModel.api_key;
          setState(() {
            api_key = api;
            Cancell_bill = int.parse(renTalModel.cancell_bill!);
            Day_Cancell_bill = int.parse(renTalModel.day_cancell_bill!);
            foder = foderx;
            rtser = renTalModel.ser!.trim();
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

  Future<Null> red_InvoiceMon_bill() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    setState(() {
      limitedList_InvoiceModels_.clear();
      InvoiceModels.clear();
      _InvoiceModels.clear();
      offset_save = 0;
      endIndex_save = 0;
      invoice_select.clear();
    });
    String Serdata =
        (zone.toString() == '0' || zone == null) ? 'All' : 'Allzone';
    String url = (Serdata.toString() == 'All')
        ? '${MyConstant().domain}/GC_bill_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now&status=$Status_dates'
        : '${MyConstant().domain}/GC_bill_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now&status=$Status_dates';
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
      // read_Invoice_limit2();
    } catch (e) {}
  }
////////--------------------------------------------------------------->

  Future<Null> red_InvoiceMon_billPay() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    setState(() {
      limitedList_InvoiceModels_.clear();
      InvoiceModels.clear();
      _InvoiceModels.clear();
      offset_save = 0;
      endIndex_save = 0;
      invoice_select.clear();
    });
    String Serdata =
        (zone.toString() == '0' || zone == null) ? 'All' : 'Allzone';
    String url = (Serdata.toString() == 'All')
        ? '${MyConstant().domain}/GC_billPay_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now'
        : '${MyConstant().domain}/GC_billPay_invoiceMon_history.php?isAdd=true&ren=$ren&Serdata=$Serdata&serzone=$zone&_monts=$MONTH_Now&yex=$YEAR_Now';
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
      // read_Invoice_limit2();
    } catch (e) {}
  }

  ///----------------------->

  Future<Null> read_Invoice_limit() async {
    setState(() {
      endIndex = offset + limit;
      InvoiceModels = limitedList_InvoiceModels_.sublist(
          offset, // Start index
          (endIndex <= limitedList_InvoiceModels_.length)
              ? endIndex
              : limitedList_InvoiceModels_.length // End index
          );
    });
  }

  Future<Null> read_Invoice_limit2() async {
    setState(() {
      endIndex_save = offset_save + limit_save;
      InvoiceModels_Save = limitedList_InvoiceModels_.sublist(
          offset_save, // Start index
          (endIndex_save <= limitedList_InvoiceModels_.length)
              ? endIndex_save
              : limitedList_InvoiceModels_.length // End index
          );
    });
    // for (int index = 0; index < InvoiceModels_Save.length; index++) {
    //   setState(() {
    //     invoice_select.add('${InvoiceModels_Save[index].docno}');
    //   });
    // }
  }

// //////////////----------------------------->
//   void checkAutoSearch() {
//     if (widget.Texts != null && widget.Texts.isNotEmpty) {
//       checkAutoSearch_Invoice();
//     }
//   }

// //////////////----------------------------->
//   String? _previousText;

//   void didUpdateWidget(covariant BillingScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (_previousText != widget.Texts) {
//       _previousText = widget.Texts;
//       if (widget.Texts != null) {
//         checkAutoSearch_Invoice();
//       }
//     }
//   }

// //////////////----------------------------->
//   Future<Null> checkAutoSearch_Invoice() async {
//     SharedPreferences preferences = await SharedPreferences.getInstance();
//     var Text = widget.Texts.toString();
//     var text = Text.toLowerCase();

//     setState(() {
//       InvoiceModels = _InvoiceModels.where((Invoice) {
//         var notTitle = Invoice.cid.toString().toLowerCase();
//         var notTitle2 = Invoice.docno.toString().toLowerCase();
//         var notTitle3 = Invoice.ln.toString().toLowerCase();
//         var notTitle4 = Invoice.btype.toString().toLowerCase();
//         var notTitle5 = Invoice.bank.toString().toLowerCase();
//         var notTitle6 = Invoice.cname.toString().toLowerCase();
//         var notTitle7 = Invoice.expname.toString().toLowerCase();
//         var notTitle8 = Invoice.date.toString().toLowerCase();
//         var notTitle9 = Invoice.remark.toString().toLowerCase();
//         return notTitle.contains(text) ||
//             notTitle2.contains(text) ||
//             notTitle3.contains(text) ||
//             notTitle4.contains(text) ||
//             notTitle5.contains(text) ||
//             notTitle6.contains(text) ||
//             notTitle7.contains(text) ||
//             notTitle8.contains(text) ||
//             notTitle9.contains(text);
//       }).toList();
//     });
//     print('checkAutoSearch_TransReBill : $text // ${InvoiceModels.length}');
//   }

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
          InvoiceModels = _InvoiceModels.where((Invoice) {
            var notTitle = Invoice.cid.toString();
            var notTitle2 = Invoice.docno.toString();
            var notTitle3 = Invoice.ln.toString();
            var notTitle4 = Invoice.btype.toString();
            var notTitle5 = Invoice.bank.toString();
            var notTitle6 = Invoice.cname.toString();
            var notTitle7 = Invoice.expname.toString();
            var notTitle8 = Invoice.date.toString();
            var notTitle9 = Invoice.remark.toString();
            var notTitle10 = Invoice.inv.toString();
            // var notTitle2 = Invoice.docno.toString().toLowerCase();
            // var notTitle3 = Invoice.ln.toString().toLowerCase();
            // var notTitle4 = Invoice.btype.toString().toLowerCase();
            // var notTitle5 = Invoice.bank.toString().toLowerCase();
            // var notTitle6 = Invoice.cname.toString().toLowerCase();
            // var notTitle7 = Invoice.expname.toString().toLowerCase();
            // var notTitle8 = Invoice.date.toString().toLowerCase();
            // var notTitle9 = Invoice.remark.toString().toLowerCase();
            return notTitle.contains(text) ||
                notTitle2.contains(text) ||
                notTitle3.contains(text) ||
                notTitle4.contains(text) ||
                notTitle5.contains(text) ||
                notTitle6.contains(text) ||
                notTitle7.contains(text) ||
                notTitle8.contains(text) ||
                notTitle9.contains(text) ||
                notTitle10.contains(text);
          }).toList();
        });

        if (text.isEmpty) {
          read_Invoice_limit();
        } else {}
      },
    );
  }

//////////////----------------------------->
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
                    const Icon(
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

                                    read_Invoice_limit();
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
                        '${(endIndex / limit)}/${(limitedList_InvoiceModels_.length / limit).ceil()}',
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
                        onTap: (endIndex >= limitedList_InvoiceModels_.length)
                            ? null
                            : () async {
                                setState(() {
                                  offset = offset + limit;
                                  tappedIndex_ = '';
                                  read_Invoice_limit();
                                });
                                _scrollController2.animateTo(
                                  0,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                              },
                        child: Icon(
                          Icons.arrow_right,
                          color: (endIndex >= limitedList_InvoiceModels_.length)
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

  // Widget Next_page_Save() {
  //   return Row(
  //     children: [
  //       // Expanded(child: Text('')),
  //       StreamBuilder(
  //           stream: Stream.periodic(const Duration(milliseconds: 300)),
  //           builder: (context, snapshot) {
  //             return Container(
  //               decoration: const BoxDecoration(
  //                 color: AppbackgroundColor.Sub_Abg_Colors,
  //                 borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(10),
  //                     topRight: Radius.circular(0),
  //                     bottomLeft: Radius.circular(10),
  //                     bottomRight: Radius.circular(0)),
  //               ),
  //               padding: const EdgeInsets.all(2.0),
  //               child: Row(
  //                 children: [
  //                   InkWell(
  //                       onTap: (offset_save == 0)
  //                           ? null
  //                           : () async {
  //                               if (offset_save == 0) {
  //                               } else {
  //                                 setState(() {
  //                                   offset_save = offset_save - limit_save;
  //                                   invoice_select.clear();
  //                                   read_Invoice_limit2();
  //                                   // tappedIndex_ = '';
  //                                 });
  //                               }
  //                             },
  //                       child: Icon(
  //                         Icons.arrow_left,
  //                         color: (offset_save == 0)
  //                             ? Colors.grey[200]
  //                             : Colors.black,
  //                         size: 25,
  //                       )),
  //                   Padding(
  //                     padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
  //                     child: Text(
  //                       '${offset_save + 1} - ${endIndex_save}',
  //                       //  '${(endIndex_save / limit_save)}/${(limitedList_InvoiceModels_.length / limit_save).ceil()}',
  //                       textAlign: TextAlign.start,
  //                       style: const TextStyle(
  //                         fontSize: 12,
  //                         color: Colors.green,
  //                         fontWeight: FontWeight.bold,
  //                         fontFamily: FontWeight_.Fonts_T,
  //                         //fontSize: 10.0
  //                       ),
  //                     ),
  //                   ),
  //                   InkWell(
  //                       onTap:
  //                           (endIndex_save >= limitedList_InvoiceModels_.length)
  //                               ? null
  //                               : () async {
  //                                   setState(() {
  //                                     offset_save = offset_save + limit_save;
  //                                     invoice_select.clear();
  //                                     // tappedIndex_ = '';
  //                                     read_Invoice_limit2();
  //                                   });
  //                                 },
  //                       child: Icon(
  //                         Icons.arrow_right,
  //                         color: (endIndex_save >=
  //                                 limitedList_InvoiceModels_.length)
  //                             ? Colors.grey[200]
  //                             : Colors.black,
  //                         size: 25,
  //                       )),
  //                 ],
  //               ),
  //             );
  //           }),
  //       Container(
  //         padding: const EdgeInsets.all(2.0),
  //         decoration: const BoxDecoration(
  //           color: Colors.green,
  //           borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(0),
  //               topRight: Radius.circular(10),
  //               bottomLeft: Radius.circular(0),
  //               bottomRight: Radius.circular(10)),
  //         ),
  //         child: InkWell(
  //           onTap: () async {
  //             setState(() {
  //               invoice_select.clear();
  //               read_Invoice_limit2();
  //             });

  //             List newValuePDFimg = [];
  //             for (int index = 0; index < 1; index++) {
  //               if (renTalModels[0].imglogo!.trim() == '') {
  //                 // newValuePDFimg.add(
  //                 //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
  //               } else {
  //                 newValuePDFimg.add(
  //                     '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
  //               }
  //             }

  //             _showMyDialog_SAVE2(newValuePDFimg);
  //           },
  //           child: const Icon(
  //             Icons.download,
  //             color: Colors.white,
  //             size: 22,
  //           ),
  //         ),
  //       )
  //     ],
  //   );
  // }

  ////////--------------------------------------------------------------->

  Future<Null> red_Trans_select(
      index, ciddoc, qutser, tser, docno, page) async {
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
        '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = (_InvoiceHistoryModel.pvat_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = (_InvoiceHistoryModel.vat_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = (_InvoiceHistoryModel.wht == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = (_InvoiceHistoryModel.total_t == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = (_InvoiceHistoryModel.disendbill == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = (_InvoiceHistoryModel.disendbillper == null)
              ? 0.00
              : double.parse(_InvoiceHistoryModel.disendbillper!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;
            numinvoice = _InvoiceHistoryModel.docno;
            paper = _InvoiceHistoryModel.paper;
            paper_run = _InvoiceHistoryModel.paper_run;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      }
      checkshowDialog(index, docno, page);
    } catch (e) {}
    _ReportValue_type = (paper.toString() == '0')
        ? '${TitleType_Default_Receipt_[0]}'
        : (paper.toString() == '1')
            ? '${TitleType_Default_Receipt_[1]}'
            : (paper.toString() == '2')
                ? '${TitleType_Default_Receipt_[2]}'
                : (paper.toString() == '3')
                    ? '${TitleType_Default_Receipt_[3]}'
                    : (paper.toString() == '4')
                        ? '${TitleType_Default_Receipt_[4]}'
                        : '${TitleType_Default_Receipt_[0]}';

    TitleType_Default_Receipt_Name = (paper.toString() == '0')
        ? '${TitleType_Default_Receipt_[0]}'
        : (paper.toString() == '1')
            ? '${TitleType_Default_Receipt_[1]}'
            : (paper.toString() == '2')
                ? '${TitleType_Default_Receipt_[2]}'
                : (paper.toString() == '3')
                    ? '${TitleType_Default_Receipt_[3]}'
                    : (paper.toString() == '4')
                        ? '${TitleType_Default_Receipt_[4]}'
                        : '${TitleType_Default_Receipt_[0]}';
  }
  ////////--------------------------------------------------------------->
  // Future<Null> red_Trans_select(index, ciddoc, qutser) async {
  //   if (_TransModels.isNotEmpty) {
  //     setState(() {
  //       _TransModels.clear();
  //       // sum_pvat = 0;
  //       // sum_vat = 0;
  //       // sum_wht = 0;
  //       // sum_amt = 0;
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   // var ciddoc = widget.Get_Value_cid;
  //   // var qutser = widget.Get_Value_NameShop_index;

  //   String url =
  //       '${MyConstant().domain}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     print(result);
  //     if (result.toString() != 'null') {
  //       setState(() {
  //         _TransModels.clear();
  //         // sum_pvat = 0;
  //         // sum_vat = 0;
  //         // sum_wht = 0;
  //         // sum_amt = 0;
  //       });
  //       for (var map in result) {
  //         TransModel _TransModel = TransModel.fromJson(map);

  //         var sum_pvatx = double.parse(_TransModel.pvat!);
  //         var sum_vatx = double.parse(_TransModel.vat!);
  //         var sum_whtx = double.parse(_TransModel.wht!);
  //         var sum_amtx = double.parse(_TransModel.total!);
  //         setState(() {
  //           // sum_pvat = sum_pvat + sum_pvatx;
  //           // sum_vat = sum_vat + sum_vatx;
  //           // sum_wht = sum_wht + sum_whtx;
  //           // sum_amt = sum_amt + sum_amtx;
  //           _TransModels.add(_TransModel);
  //         });
  //       }
  //       checkshowDialog(index);
  //     }
  //   } catch (e) {}
  // }

////////--------------------------------------------------------------->
  Widget build(BuildContext context) {
    double calculatedWidth =
        (ac4_1.where((item) => item["st"] == '1').toList().length <= 14)
            ? MediaQuery.of(context).size.width * 0.85
            : MediaQuery.of(context).size.width * 0.85 +
                ((ac4_1.where((item) => item["st"] == '1').toList().length -
                        14) *
                    100);
    return Column(
      children: [
        if (Ser_Tap == 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: PopupMenuButton(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5)),
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Translate.TranslateAndSetText(
                        'ตัวอย่างไฟล์ Excel',
                        Colors.green[600],
                        TextAlign.start,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        1),
                    // Text(
                    //   'ตัวอย่างไฟล์ Excel',
                    //   style: TextStyle(
                    //     color: Colors.green[600],
                    //     fontWeight: FontWeight.bold,
                    //     fontFamily: Font_.Fonts_T,
                    //   ),
                    // ),
                  ),
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                        onTap: () async {
                          final fileUrl =
                              '${MyConstant().domain}/Awaitdownload/ตย.ไฟล์_KTB_รับชำระ.xlsx';

                          if (await canLaunch(fileUrl)) {
                            await launch(fileUrl);
                          } else {
                            // Handle error
                            // print('Could not launch $fileUrl');
                          }
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
                          // width: 200,บช.ที่จะใช้  Online Standard QR ต้องไปสมัคร
                          child: Row(
                            children: [
                              Translate.TranslateAndSetText(
                                  'รูปแบบ : ธนาคารกรุงไทย (KTB)  ',
                                  AccountScreen_Color.Colors_Text1_,
                                  TextAlign.start,
                                  FontWeight.bold,
                                  FontWeight_.Fonts_T,
                                  14,
                                  1),
                              // Text(
                              //   'รูปแบบ : ธนาคารกรุงไทย (KTB)  ',
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     color: ReportScreen_Color.Colors_Text2_,
                              //     // fontWeight: FontWeight.bold,
                              //     fontFamily: Font_.Fonts_T,
                              //   ),
                              // ),
                              CircleAvatar(
                                radius: 12.0,
                                backgroundImage:
                                    AssetImage('images/LogoBank/KTB.png'),
                                backgroundColor: Colors.transparent,
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 8, 8, 0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      Status_dates = 0;
                      Ser_Tap = 0;
                      invoice_select_delete.clear();
                      invoice_loade_Success_delete.clear();
                    });
                    red_InvoiceMon_bill();
                  },
                  child: Container(
                    // width: 100, Verifi_Billing_Screen
                    decoration: BoxDecoration(
                      color: (Ser_Tap == 0)
                          ? Colors.blueGrey[600]
                          : Colors.blueGrey[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Translate.TranslateAndSetText(
                        "ประวัติวางบิล",
                        (Ser_Tap == 0) ? Colors.white : Colors.black,
                        TextAlign.start,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        12,
                        1),
                    // Text(
                    //   "ประวัติวางบิล",
                    //   style: TextStyle(
                    //     color: (Ser_Tap == 0) ? Colors.white : Colors.black,
                    //     fontFamily: FontWeight_.Fonts_T,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      Status_dates = 0;
                      Ser_Tap = 1;
                      invoice_select_delete.clear();
                      invoice_loade_Success_delete.clear();
                    });
                    red_InvoiceMon_bill();
                  },
                  child: Container(
                    // width: 130,
                    decoration: BoxDecoration(
                      color: (Ser_Tap == 1)
                          ? Colors.blueGrey[600]
                          : Colors.blueGrey[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Translate.TranslateAndSetText(
                        "ตรวจสอบวางบิล",
                        (Ser_Tap == 1) ? Colors.white : Colors.black,
                        TextAlign.start,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        12,
                        1),
                    // Text(
                    //   "ตรวจสอบวางบิล",
                    //   style: TextStyle(
                    //     color: (Ser_Tap == 1) ? Colors.white : Colors.black,
                    //     fontFamily: FontWeight_.Fonts_T,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      Status_dates = 0;
                      Ser_Tap = 2;
                      invoice_select_delete.clear();
                      invoice_loade_Success_delete.clear();
                    });
                    red_InvoiceMon_billPay();
                  },
                  child: Container(
                    // width: 100, Verifi_Billing_Screen
                    decoration: BoxDecoration(
                      color: (Ser_Tap == 2)
                          ? Colors.blueGrey[600]
                          : Colors.blueGrey[200],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0)),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                     padding: const EdgeInsets.all(4.0),
                    child: Translate.TranslateAndSetText(
                        "ประวัติวางบิล(ชำระแล้ว)",
                        (Ser_Tap == 2) ? Colors.white : Colors.black,
                        TextAlign.start,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        12,
                        1),
                    // Text(
                    //   "ประวัติวางบิล(ชำระแล้ว)",
                    //   style: TextStyle(
                    //     color: (Ser_Tap == 2) ? Colors.white : Colors.black,
                    //     fontFamily: FontWeight_.Fonts_T,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ),
                ),
              ),
            ],
          ),
        ),
      (Ser_Tap == 1)
            ? const Verifi_Exc_Billing()
            : (Ser_Tap == 2)
                ? Account_Bill_InvoceSuccess()

                /// bill_pay()
                : (Ser_Tap == 0)
                    ? const Account_Bill_Invoce()
                    :SizedBox()
          //  Padding(
          //           padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
          //           child: Column(
          //             children: [
          //               Container(
          //                 width: (Responsive.isDesktop(context))
          //                     ?
          //                     //  (rtser.toString() == '50' ||
          //                     //         rtser.toString() == '72' ||
          //                     //         rtser.toString() == '92' ||
          //                     //         rtser.toString() == '93' ||
          //                     //         rtser.toString() == '94')
          //                     //     ? MediaQuery.of(context).size.width * 0.88
          //                     //     :
          //                     calculatedWidth
          //                     : 1200,
          //                 decoration: const BoxDecoration(
          //                   color: AppbackgroundColor.Sub_Abg_Colors,
          //                   borderRadius: BorderRadius.only(
          //                       topLeft: Radius.circular(10),
          //                       topRight: Radius.circular(10),
          //                       bottomLeft: Radius.circular(10),
          //                       bottomRight: Radius.circular(10)),
          //                   // border: Border.all(color: Colors.grey, width: 1),
          //                 ),
          //                 child: Column(
          //                   children: [
          //                     Container(
          //                         width: (Responsive.isDesktop(context))
          //                             ?
          //                             //  (rtser.toString() == '50' ||
          //                             //         rtser.toString() == '72' ||
          //                             //         rtser.toString() == '92' ||
          //                             //         rtser.toString() == '93' ||
          //                             //         rtser.toString() == '94')
          //                             //     ? MediaQuery.of(context).size.width *
          //                             //         0.88
          //                             //     :
          //                             calculatedWidth
          //                             : 1200,
          //                         child: Column(
          //                           children: [
          //                             ScrollConfiguration(
          //                               behavior:
          //                                   ScrollConfiguration.of(context)
          //                                       .copyWith(dragDevices: {
          //                                 PointerDeviceKind.touch,
          //                                 PointerDeviceKind.mouse,
          //                               }),
          //                               child: SingleChildScrollView(
          //                                 scrollDirection: Axis.horizontal,
          //                                 dragStartBehavior:
          //                                     DragStartBehavior.start,
          //                                 child: Row(
          //                                   children: [
          //                                     SizedBox(
          //                                       child: Column(
          //                                         children: [
          //                                           Container(
          //                                             width: (Responsive
          //                                                     .isDesktop(
          //                                                         context))
          //                                                 ?
          //                                                 //  (rtser.toString() == '50' ||
          //                                                 //         rtser.toString() ==
          //                                                 //             '72' ||
          //                                                 //         rtser.toString() ==
          //                                                 //             '92' ||
          //                                                 //         rtser.toString() ==
          //                                                 //             '93' ||
          //                                                 //         rtser.toString() ==
          //                                                 //             '94')
          //                                                 //     ? MediaQuery.of(
          //                                                 //                 context)
          //                                                 //             .size
          //                                                 //             .width *
          //                                                 //         0.9
          //                                                 //     :
          //                                                 calculatedWidth
          //                                                 : 1200,
          //                                             decoration: BoxDecoration(
          //                                               color:
          //                                                   AppbackgroundColor
          //                                                       .TiTile_Colors,
          //                                               borderRadius:
          //                                                   BorderRadius.only(
          //                                                       topLeft: Radius
          //                                                           .circular(
          //                                                               10),
          //                                                       topRight:
          //                                                           Radius
          //                                                               .circular(
          //                                                                   10),
          //                                                       bottomLeft: Radius
          //                                                           .circular(
          //                                                               0),
          //                                                       bottomRight:
          //                                                           Radius
          //                                                               .circular(
          //                                                                   0)),
          //                                             ),
          //                                             padding:
          //                                                 const EdgeInsets.all(
          //                                                     8.0),
          //                                             child: Column(
          //                                               children: [
          //                                                 Padding(
          //                                                   padding:
          //                                                       const EdgeInsets
          //                                                           .all(2.0),
          //                                                   child: Row(
          //                                                     children: [
          //                                                       Padding(
          //                                                         padding:
          //                                                             EdgeInsets
          //                                                                 .all(
          //                                                                     2.0),
          //                                                         child: Translate.TranslateAndSetText(
          //                                                             'ค้นหา :',
          //                                                             AccountScreen_Color
          //                                                                 .Colors_Text1_,
          //                                                             TextAlign
          //                                                                 .start,
          //                                                             FontWeight
          //                                                                 .bold,
          //                                                             FontWeight_
          //                                                                 .Fonts_T,
          //                                                             14,
          //                                                             1),
          //                                                       ),
          //                                                       Expanded(
          //                                                         // flex: 1,
          //                                                         child:
          //                                                             Container(
          //                                                           height:
          //                                                               35, //Date_ser
          //                                                           // width: 150,
          //                                                           decoration:
          //                                                               BoxDecoration(
          //                                                             color: AppbackgroundColor
          //                                                                 .Sub_Abg_Colors,
          //                                                             borderRadius: const BorderRadius
          //                                                                     .only(
          //                                                                 topLeft: Radius.circular(
          //                                                                     8),
          //                                                                 topRight: Radius.circular(
          //                                                                     0),
          //                                                                 bottomLeft: Radius.circular(
          //                                                                     8),
          //                                                                 bottomRight:
          //                                                                     Radius.circular(0)),
          //                                                             border: Border.all(
          //                                                                 color: Colors
          //                                                                     .grey,
          //                                                                 width:
          //                                                                     1),
          //                                                           ),
          //                                                           child:
          //                                                               _searchBarMain1(),
          //                                                         ),
          //                                                       ),
          //                                                       Padding(
          //                                                         padding:
          //                                                             const EdgeInsets
          //                                                                     .fromLTRB(
          //                                                                 0,
          //                                                                 2,
          //                                                                 2,
          //                                                                 2),
          //                                                         child:
          //                                                             Container(
          //                                                           height: 35,
          //                                                           decoration:
          //                                                               BoxDecoration(
          //                                                             color: AppbackgroundColor
          //                                                                 .Sub_Abg_Colors,
          //                                                             // .withOpacity(0.5),
          //                                                             borderRadius: BorderRadius.only(
          //                                                                 topLeft: Radius.circular(
          //                                                                     0),
          //                                                                 topRight: Radius.circular(
          //                                                                     8),
          //                                                                 bottomLeft: Radius.circular(
          //                                                                     0),
          //                                                                 bottomRight:
          //                                                                     Radius.circular(8)),
          //                                                             // border: Border.all(
          //                                                             //     color:
          //                                                             //         Colors.grey,
          //                                                             //     width: 1),
          //                                                           ),
          //                                                           width: 130,
          //                                                           // height: 30,
          //                                                           padding:
          //                                                               const EdgeInsets.all(
          //                                                                   2.0),
          //                                                           child:
          //                                                               DropdownButtonHideUnderline(
          //                                                             child: DropdownButton2<
          //                                                                 String>(
          //                                                               isExpanded:
          //                                                                   true,
          //                                                               hint:
          //                                                                   Center(
          //                                                                 child:
          //                                                                     Text(
          //                                                                   'หัวข้อ',
          //                                                                   style:
          //                                                                       const TextStyle(
          //                                                                     fontSize: 14,
          //                                                                     color: AccountScreen_Color.Colors_Text1_,
          //                                                                     fontWeight: FontWeight.bold,
          //                                                                     fontFamily: Font_.Fonts_T,
          //                                                                   ),
          //                                                                 ),
          //                                                               ),

          //                                                               items: ac4_1
          //                                                                   .asMap()
          //                                                                   .entries
          //                                                                   .map((entry) {
          //                                                                 int index =
          //                                                                     entry.key; // Get the index
          //                                                                 var item =
          //                                                                     entry.value;
          //                                                                 return DropdownMenuItem<
          //                                                                     String>(
          //                                                                   value:
          //                                                                       item["ser"], // Use "ser" as the value
          //                                                                   enabled:
          //                                                                       false, // Set to true to allow selection
          //                                                                   child:
          //                                                                       StatefulBuilder(
          //                                                                     builder: (context, menuSetState) {
          //                                                                       // final isSelected = selectedItems.contains(item);
          //                                                                       return InkWell(
          //                                                                         onTap: () {
          //                                                                           int selectedIndex = ac4_1.indexWhere((items) => items["ser"] == item["ser"]);
          //                                                                           // print(ac1[selectedIndex]
          //                                                                           //     [
          //                                                                           //     "pn"]);
          //                                                                           // isSelected ? selectedItems.remove(item) : selectedItems.add(item);
          //                                                                           //This rebuilds the StatefulWidget to update the button's text
          //                                                                           setState(() {
          //                                                                             if (item["st"]! == '1') {
          //                                                                               ac4_1[selectedIndex]["st"] = '0';
          //                                                                             } else {
          //                                                                               ac4_1[selectedIndex]["st"] = '1';
          //                                                                             }
          //                                                                           });
          //                                                                           //This rebuilds the dropdownMenu Widget to update the check mark
          //                                                                           menuSetState(() {});
          //                                                                         },
          //                                                                         child: Container(
          //                                                                           height: double.infinity,
          //                                                                           padding: const EdgeInsets.symmetric(horizontal: 4.0),
          //                                                                           child: Row(
          //                                                                             children: [
          //                                                                               if (item["st"]! == '1')
          //                                                                                 Icon(
          //                                                                                   Icons.check_box_outlined,
          //                                                                                   color: Colors.green[400],
          //                                                                                 )
          //                                                                               else
          //                                                                                 const Icon(Icons.check_box_outline_blank),
          //                                                                               Expanded(
          //                                                                                 child: Text(
          //                                                                                   item["pn"]!,
          //                                                                                   maxLines: 2,
          //                                                                                   style: const TextStyle(
          //                                                                                     fontSize: 12,
          //                                                                                     color: AccountScreen_Color.Colors_Text1_,
          //                                                                                     fontWeight: FontWeight.w600,
          //                                                                                     fontFamily: Font_.Fonts_T,
          //                                                                                   ),
          //                                                                                 ),
          //                                                                               ),
          //                                                                             ],
          //                                                                           ),
          //                                                                         ),
          //                                                                       );
          //                                                                     },
          //                                                                   ),
          //                                                                 );
          //                                                               }).toList(),
          //                                                               //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
          //                                                               // value: selectedItems.isEmpty ? null : selectedItems.last,
          //                                                               onChanged:
          //                                                                   (value) {},
          //                                                             ),
          //                                                           ),
          //                                                         ),
          //                                                       ),
          //                                                       Container(
          //                                                           width: 150,
          //                                                           child:
          //                                                               Next_page())
          //                                                       // Expanded(
          //                                                       //     child:
          //                                                       //         Next_page_billCancel())
          //                                                     ],
          //                                                   ),
          //                                                 ),
          //                                                 const Divider(),
          //                                                 Row(
          //                                                   children: [
          //                                                     // Expanded(
          //                                                     //   child:
          //                                                     Container(
          //                                                       decoration:
          //                                                           BoxDecoration(
          //                                                         color: AppbackgroundColor
          //                                                                 .Sub_Abg_Colors
          //                                                             .withOpacity(
          //                                                                 0.5),
          //                                                         borderRadius: const BorderRadius
          //                                                                 .only(
          //                                                             topLeft:
          //                                                                 Radius.circular(
          //                                                                     10),
          //                                                             topRight:
          //                                                                 Radius.circular(
          //                                                                     10),
          //                                                             bottomLeft:
          //                                                                 Radius.circular(
          //                                                                     10),
          //                                                             bottomRight:
          //                                                                 Radius.circular(
          //                                                                     10)),
          //                                                         // border: Border.all(color: Colors.white, width: 1),
          //                                                       ),
          //                                                       child: Row(
          //                                                         children: [
          //                                                           Padding(
          //                                                             padding:
          //                                                                 EdgeInsets.all(
          //                                                                     2.0),

          //                                                             ///Status_dates
          //                                                             child: Translate.TranslateAndSetText(
          //                                                                 'สถานะ :',
          //                                                                 ReportScreen_Color
          //                                                                     .Colors_Text2_,
          //                                                                 TextAlign
          //                                                                     .start,
          //                                                                 null,
          //                                                                 Font_
          //                                                                     .Fonts_T,
          //                                                                 12,
          //                                                                 1),
          //                                                           ),
          //                                                           Padding(
          //                                                             padding:
          //                                                                 const EdgeInsets.all(
          //                                                                     2.0),
          //                                                             child:
          //                                                                 Container(
          //                                                               decoration:
          //                                                                   const BoxDecoration(
          //                                                                 color:
          //                                                                     AppbackgroundColor.Sub_Abg_Colors,
          //                                                                 borderRadius: BorderRadius.only(
          //                                                                     topLeft: Radius.circular(10),
          //                                                                     topRight: Radius.circular(10),
          //                                                                     bottomLeft: Radius.circular(10),
          //                                                                     bottomRight: Radius.circular(10)),
          //                                                                 // border: Border.all(color: Colors.grey, width: 1),
          //                                                               ),
          //                                                               width:
          //                                                                   250,
          //                                                               padding:
          //                                                                   const EdgeInsets.all(2.0),
          //                                                               child:
          //                                                                   DropdownButtonFormField2(
          //                                                                 alignment:
          //                                                                     Alignment.center,
          //                                                                 focusColor:
          //                                                                     Colors.white,
          //                                                                 autofocus:
          //                                                                     false,
          //                                                                 decoration:
          //                                                                     InputDecoration(
          //                                                                   floatingLabelAlignment:
          //                                                                       FloatingLabelAlignment.center,
          //                                                                   enabled:
          //                                                                       true,
          //                                                                   hoverColor:
          //                                                                       Colors.brown,
          //                                                                   prefixIconColor:
          //                                                                       Colors.blue,
          //                                                                   fillColor:
          //                                                                       Colors.white.withOpacity(0.05),
          //                                                                   filled:
          //                                                                       false,
          //                                                                   isDense:
          //                                                                       true,
          //                                                                   contentPadding:
          //                                                                       EdgeInsets.zero,
          //                                                                   border:
          //                                                                       OutlineInputBorder(
          //                                                                     borderSide: const BorderSide(color: Colors.red),
          //                                                                     borderRadius: BorderRadius.circular(10),
          //                                                                   ),
          //                                                                   focusedBorder:
          //                                                                       const OutlineInputBorder(
          //                                                                     borderRadius: BorderRadius.only(
          //                                                                       topRight: Radius.circular(10),
          //                                                                       topLeft: Radius.circular(10),
          //                                                                       bottomRight: Radius.circular(10),
          //                                                                       bottomLeft: Radius.circular(10),
          //                                                                     ),
          //                                                                     borderSide: BorderSide(
          //                                                                       width: 1,
          //                                                                       color: Color.fromARGB(255, 231, 227, 227),
          //                                                                     ),
          //                                                                   ),
          //                                                                 ),
          //                                                                 isExpanded:
          //                                                                     false,
          //                                                                 // value: YEAR_Now,
          //                                                                 hint: Translate.TranslateAndSetText(
          //                                                                     'ประจำเดือน',
          //                                                                     AccountScreen_Color.Colors_Text1_,
          //                                                                     TextAlign.start,
          //                                                                     null,
          //                                                                     Font_.Fonts_T,
          //                                                                     12,
          //                                                                     1),
          //                                                                 // value: (Status_dates == null)
          //                                                                 //     ? 'ประจำเดือน'
          //                                                                 //     : (Status_dates == 1)
          //                                                                 //         ? 'เลยกำหนดชำระ'
          //                                                                 //         : (Status_dates == 2)
          //                                                                 //             ? 'ยังเลยกำหนดชำระ'
          //                                                                 //             : 'ประจำเดือน',

          //                                                                 icon:
          //                                                                     const Icon(
          //                                                                   Icons.arrow_drop_down,
          //                                                                   // Icons.sort_rounded,
          //                                                                   color:
          //                                                                       Colors.black,
          //                                                                 ),
          //                                                                 style:
          //                                                                     const TextStyle(
          //                                                                   color:
          //                                                                       Colors.grey,
          //                                                                 ),
          //                                                                 iconSize:
          //                                                                     20,
          //                                                                 buttonHeight: (Status_dates == 0)
          //                                                                     ? 30
          //                                                                     : 47,
          //                                                                 buttonWidth:
          //                                                                     250,
          //                                                                 // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
          //                                                                 dropdownDecoration:
          //                                                                     BoxDecoration(
          //                                                                   // color: Colors
          //                                                                   //     .amber,
          //                                                                   borderRadius:
          //                                                                       BorderRadius.circular(10),
          //                                                                   border:
          //                                                                       Border.all(color: Colors.white, width: 1),
          //                                                                 ),
          //                                                                 items: [
          //                                                                   DropdownMenuItem<String>(
          //                                                                     value: '0',
          //                                                                     child: Translate.TranslateAndSetText('🟢ประจำเดือน', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
          //                                                                   ),
          //                                                                   DropdownMenuItem<String>(
          //                                                                     value: '1',
          //                                                                     child: Column(
          //                                                                       mainAxisAlignment: MainAxisAlignment.center,
          //                                                                       crossAxisAlignment: CrossAxisAlignment.start,
          //                                                                       children: [
          //                                                                         Translate.TranslateAndSetText('🟢เลยกำหนดชำระ', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
          //                                                                         Translate.TranslateAndSetText('***(กำหนดชำระ < วันปัจจุบัน)', Colors.red[300], TextAlign.start, null, Font_.Fonts_T, 10, 2),
          //                                                                       ],
          //                                                                     ),
          //                                                                   ),
          //                                                                   DropdownMenuItem<String>(
          //                                                                     value: '2',
          //                                                                     child: Column(
          //                                                                       mainAxisAlignment: MainAxisAlignment.center,
          //                                                                       crossAxisAlignment: CrossAxisAlignment.start,
          //                                                                       children: [
          //                                                                         Translate.TranslateAndSetText('🟢ยังไม่เลยกำหนดชำระ', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 12, 1),
          //                                                                         Translate.TranslateAndSetText('**(กำหนดชำระ >= วันปัจจุบัน)', Colors.red[300], TextAlign.start, null, Font_.Fonts_T, 10, 2),
          //                                                                       ],
          //                                                                     ),
          //                                                                   ),
          //                                                                 ],

          //                                                                 onChanged:
          //                                                                     (value) async {
          //                                                                   setState(() {
          //                                                                     Status_dates = int.parse(value.toString());
          //                                                                   });
          //                                                                   red_InvoiceMon_bill();
          //                                                                 },
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                           if (Status_dates ==
          //                                                               0)
          //                                                             Padding(
          //                                                               padding:
          //                                                                   EdgeInsets.all(2.0),
          //                                                               child: Translate.TranslateAndSetText(
          //                                                                   'เดือนที่ครบกำหนด :',
          //                                                                   AccountScreen_Color.Colors_Text1_,
          //                                                                   TextAlign.start,
          //                                                                   null,
          //                                                                   Font_.Fonts_T,
          //                                                                   14,
          //                                                                   1),
          //                                                             ),
          //                                                           if (Status_dates ==
          //                                                               0)
          //                                                             Padding(
          //                                                               padding:
          //                                                                   const EdgeInsets.all(2.0),
          //                                                               child:
          //                                                                   Container(
          //                                                                 decoration:
          //                                                                     const BoxDecoration(
          //                                                                   color:
          //                                                                       AppbackgroundColor.Sub_Abg_Colors,
          //                                                                   borderRadius: BorderRadius.only(
          //                                                                       topLeft: Radius.circular(10),
          //                                                                       topRight: Radius.circular(10),
          //                                                                       bottomLeft: Radius.circular(10),
          //                                                                       bottomRight: Radius.circular(10)),
          //                                                                   // border: Border.all(color: Colors.grey, width: 1),
          //                                                                 ),
          //                                                                 width:
          //                                                                     120,
          //                                                                 padding:
          //                                                                     const EdgeInsets.all(2.0),
          //                                                                 child:
          //                                                                     DropdownButtonFormField2(
          //                                                                   alignment:
          //                                                                       Alignment.center,
          //                                                                   focusColor:
          //                                                                       Colors.white,
          //                                                                   autofocus:
          //                                                                       false,
          //                                                                   decoration:
          //                                                                       InputDecoration(
          //                                                                     floatingLabelAlignment: FloatingLabelAlignment.center,
          //                                                                     enabled: true,
          //                                                                     hoverColor: Colors.brown,
          //                                                                     prefixIconColor: Colors.blue,
          //                                                                     fillColor: Colors.white.withOpacity(0.05),
          //                                                                     filled: false,
          //                                                                     isDense: true,
          //                                                                     contentPadding: EdgeInsets.zero,
          //                                                                     border: OutlineInputBorder(
          //                                                                       borderSide: const BorderSide(color: Colors.red),
          //                                                                       borderRadius: BorderRadius.circular(10),
          //                                                                     ),
          //                                                                     focusedBorder: const OutlineInputBorder(
          //                                                                       borderRadius: BorderRadius.only(
          //                                                                         topRight: Radius.circular(10),
          //                                                                         topLeft: Radius.circular(10),
          //                                                                         bottomRight: Radius.circular(10),
          //                                                                         bottomLeft: Radius.circular(10),
          //                                                                       ),
          //                                                                       borderSide: BorderSide(
          //                                                                         width: 1,
          //                                                                         color: Color.fromARGB(255, 231, 227, 227),
          //                                                                       ),
          //                                                                     ),
          //                                                                   ),
          //                                                                   isExpanded:
          //                                                                       false,
          //                                                                   //value: MONTH_Now,
          //                                                                   hint: Translate.TranslateAndSetText(
          //                                                                       MONTH_Now == null ? 'เลือก' : '${monthsInThai[int.parse('${MONTH_Now}') - 1]}',
          //                                                                       AccountScreen_Color.Colors_Text1_,
          //                                                                       TextAlign.start,
          //                                                                       null,
          //                                                                       Font_.Fonts_T,
          //                                                                       14,
          //                                                                       1),

          //                                                                   icon:
          //                                                                       const Icon(
          //                                                                     Icons.arrow_drop_down,
          //                                                                     color: Colors.black,
          //                                                                   ),
          //                                                                   style:
          //                                                                       const TextStyle(
          //                                                                     color: Colors.grey,
          //                                                                   ),
          //                                                                   iconSize:
          //                                                                       20,
          //                                                                   buttonHeight:
          //                                                                       30,
          //                                                                   buttonWidth:
          //                                                                       200,
          //                                                                   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
          //                                                                   dropdownDecoration:
          //                                                                       BoxDecoration(
          //                                                                     // color: Colors
          //                                                                     //     .amber,
          //                                                                     borderRadius: BorderRadius.circular(10),
          //                                                                     border: Border.all(color: Colors.white, width: 1),
          //                                                                   ),
          //                                                                   items: [
          //                                                                     for (int item = 1; item < 13; item++)
          //                                                                       DropdownMenuItem<String>(
          //                                                                         value: '${item}',
          //                                                                         child: Translate.TranslateAndSetText('${monthsInThai[item - 1]}', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 14, 1),

          //                                                                         //  Text(
          //                                                                         //   '${monthsInThai[item - 1]}',
          //                                                                         //   // '${item}',
          //                                                                         //   textAlign: TextAlign.center,
          //                                                                         //   style: const TextStyle(
          //                                                                         //     overflow: TextOverflow.ellipsis,
          //                                                                         //     fontSize: 14,
          //                                                                         //     color: Colors.grey,
          //                                                                         //   ),
          //                                                                         // ),
          //                                                                       )
          //                                                                   ],

          //                                                                   onChanged:
          //                                                                       (value) async {
          //                                                                     MONTH_Now = value;
          //                                                                     red_InvoiceMon_bill();

          //                                                                     // red_Trans_bill();
          //                                                                     // if (Value_Chang_Zone_Income !=
          //                                                                     //     null) {
          //                                                                     //   red_Trans_billIncome();
          //                                                                     //   red_Trans_billMovemen();
          //                                                                     // }
          //                                                                   },
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                           if (Status_dates ==
          //                                                               0)
          //                                                             Padding(
          //                                                               padding:
          //                                                                   EdgeInsets.all(2.0),
          //                                                               child: Translate.TranslateAndSetText(
          //                                                                   'ปีที่ครบกำหนด :',
          //                                                                   AccountScreen_Color.Colors_Text1_,
          //                                                                   TextAlign.start,
          //                                                                   null,
          //                                                                   Font_.Fonts_T,
          //                                                                   14,
          //                                                                   1),
          //                                                             ),
          //                                                           if (Status_dates ==
          //                                                               0)
          //                                                             Padding(
          //                                                               padding:
          //                                                                   const EdgeInsets.all(2.0),
          //                                                               child:
          //                                                                   Container(
          //                                                                 decoration:
          //                                                                     const BoxDecoration(
          //                                                                   color:
          //                                                                       AppbackgroundColor.Sub_Abg_Colors,
          //                                                                   borderRadius: BorderRadius.only(
          //                                                                       topLeft: Radius.circular(10),
          //                                                                       topRight: Radius.circular(10),
          //                                                                       bottomLeft: Radius.circular(10),
          //                                                                       bottomRight: Radius.circular(10)),
          //                                                                   // border: Border.all(color: Colors.grey, width: 1),
          //                                                                 ),
          //                                                                 width:
          //                                                                     120,
          //                                                                 padding:
          //                                                                     const EdgeInsets.all(2.0),
          //                                                                 child:
          //                                                                     DropdownButtonFormField2(
          //                                                                   alignment:
          //                                                                       Alignment.center,
          //                                                                   focusColor:
          //                                                                       Colors.white,
          //                                                                   autofocus:
          //                                                                       false,
          //                                                                   decoration:
          //                                                                       InputDecoration(
          //                                                                     floatingLabelAlignment: FloatingLabelAlignment.center,
          //                                                                     enabled: true,
          //                                                                     hoverColor: Colors.brown,
          //                                                                     prefixIconColor: Colors.blue,
          //                                                                     fillColor: Colors.white.withOpacity(0.05),
          //                                                                     filled: false,
          //                                                                     isDense: true,
          //                                                                     contentPadding: EdgeInsets.zero,
          //                                                                     border: OutlineInputBorder(
          //                                                                       borderSide: const BorderSide(color: Colors.red),
          //                                                                       borderRadius: BorderRadius.circular(10),
          //                                                                     ),
          //                                                                     focusedBorder: const OutlineInputBorder(
          //                                                                       borderRadius: BorderRadius.only(
          //                                                                         topRight: Radius.circular(10),
          //                                                                         topLeft: Radius.circular(10),
          //                                                                         bottomRight: Radius.circular(10),
          //                                                                         bottomLeft: Radius.circular(10),
          //                                                                       ),
          //                                                                       borderSide: BorderSide(
          //                                                                         width: 1,
          //                                                                         color: Color.fromARGB(255, 231, 227, 227),
          //                                                                       ),
          //                                                                     ),
          //                                                                   ),
          //                                                                   isExpanded:
          //                                                                       false,
          //                                                                   // value: YEAR_Now,
          //                                                                   hint:
          //                                                                       Text(
          //                                                                     YEAR_Now == null ? 'เลือก-Select' : '$YEAR_Now',
          //                                                                     maxLines: 2,
          //                                                                     textAlign: TextAlign.center,
          //                                                                     style: const TextStyle(
          //                                                                       overflow: TextOverflow.ellipsis,
          //                                                                       fontSize: 12,
          //                                                                       color: Colors.grey,
          //                                                                     ),
          //                                                                   ),
          //                                                                   icon:
          //                                                                       const Icon(
          //                                                                     Icons.arrow_drop_down,
          //                                                                     color: Colors.black,
          //                                                                   ),
          //                                                                   style:
          //                                                                       const TextStyle(
          //                                                                     color: Colors.grey,
          //                                                                   ),
          //                                                                   iconSize:
          //                                                                       20,
          //                                                                   buttonHeight:
          //                                                                       30,
          //                                                                   buttonWidth:
          //                                                                       200,
          //                                                                   // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
          //                                                                   dropdownDecoration:
          //                                                                       BoxDecoration(
          //                                                                     // color: Colors
          //                                                                     //     .amber,
          //                                                                     borderRadius: BorderRadius.circular(10),
          //                                                                     border: Border.all(color: Colors.white, width: 1),
          //                                                                   ),
          //                                                                   items: YE_Th.map((item) =>
          //                                                                       DropdownMenuItem<String>(
          //                                                                         value: '${item}',
          //                                                                         child: Text(
          //                                                                           '${item}',
          //                                                                           textAlign: TextAlign.center,
          //                                                                           style: const TextStyle(
          //                                                                             overflow: TextOverflow.ellipsis,
          //                                                                             fontSize: 14,
          //                                                                             color: Colors.grey,
          //                                                                           ),
          //                                                                         ),
          //                                                                       )).toList(),

          //                                                                   onChanged:
          //                                                                       (value) async {
          //                                                                     YEAR_Now = value;
          //                                                                     red_InvoiceMon_bill();

          //                                                                     // red_Trans_bill();
          //                                                                     // if (Value_Chang_Zone_Income !=
          //                                                                     //     null) {
          //                                                                     //   red_Trans_billIncome();
          //                                                                     //   red_Trans_billMovemen();
          //                                                                     // }
          //                                                                   },
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                           Padding(
          //                                                             padding:
          //                                                                 EdgeInsets.all(
          //                                                                     2.0),
          //                                                             child: Translate.TranslateAndSetText(
          //                                                                 'เรียงจาก :',
          //                                                                 AccountScreen_Color
          //                                                                     .Colors_Text1_,
          //                                                                 TextAlign
          //                                                                     .start,
          //                                                                 null,
          //                                                                 Font_
          //                                                                     .Fonts_T,
          //                                                                 14,
          //                                                                 1),
          //                                                           ),
          //                                                           Padding(
          //                                                             padding:
          //                                                                 const EdgeInsets.all(
          //                                                                     2.0),
          //                                                             child:
          //                                                                 Container(
          //                                                               decoration:
          //                                                                   const BoxDecoration(
          //                                                                 color:
          //                                                                     AppbackgroundColor.Sub_Abg_Colors,
          //                                                                 borderRadius: BorderRadius.only(
          //                                                                     topLeft: Radius.circular(10),
          //                                                                     topRight: Radius.circular(10),
          //                                                                     bottomLeft: Radius.circular(10),
          //                                                                     bottomRight: Radius.circular(10)),
          //                                                                 // border: Border.all(color: Colors.grey, width: 1),
          //                                                               ),
          //                                                               width:
          //                                                                   160,
          //                                                               padding:
          //                                                                   const EdgeInsets.all(2.0),
          //                                                               child:
          //                                                                   DropdownButtonFormField2(
          //                                                                 alignment:
          //                                                                     Alignment.center,
          //                                                                 focusColor:
          //                                                                     Colors.white,
          //                                                                 autofocus:
          //                                                                     false,
          //                                                                 decoration:
          //                                                                     InputDecoration(
          //                                                                   floatingLabelAlignment:
          //                                                                       FloatingLabelAlignment.center,
          //                                                                   enabled:
          //                                                                       true,
          //                                                                   hoverColor:
          //                                                                       Colors.brown,
          //                                                                   prefixIconColor:
          //                                                                       Colors.blue,
          //                                                                   fillColor:
          //                                                                       Colors.white.withOpacity(0.05),
          //                                                                   filled:
          //                                                                       false,
          //                                                                   isDense:
          //                                                                       true,
          //                                                                   contentPadding:
          //                                                                       EdgeInsets.zero,
          //                                                                   border:
          //                                                                       OutlineInputBorder(
          //                                                                     borderSide: const BorderSide(color: Colors.red),
          //                                                                     borderRadius: BorderRadius.circular(10),
          //                                                                   ),
          //                                                                   focusedBorder:
          //                                                                       const OutlineInputBorder(
          //                                                                     borderRadius: BorderRadius.only(
          //                                                                       topRight: Radius.circular(10),
          //                                                                       topLeft: Radius.circular(10),
          //                                                                       bottomRight: Radius.circular(10),
          //                                                                       bottomLeft: Radius.circular(10),
          //                                                                     ),
          //                                                                     borderSide: BorderSide(
          //                                                                       width: 1,
          //                                                                       color: Color.fromARGB(255, 231, 227, 227),
          //                                                                     ),
          //                                                                   ),
          //                                                                 ),
          //                                                                 isExpanded:
          //                                                                     false,
          //                                                                 // value: YEAR_Now,
          //                                                                 hint: Translate.TranslateAndSetText(
          //                                                                     'เลขที่ใบแจ้งหนี้',
          //                                                                     AccountScreen_Color.Colors_Text1_,
          //                                                                     TextAlign.start,
          //                                                                     null,
          //                                                                     Font_.Fonts_T,
          //                                                                     12,
          //                                                                     1),

          //                                                                 icon:
          //                                                                     const Icon(
          //                                                                   Icons.arrow_drop_down,
          //                                                                   // Icons.sort_rounded,
          //                                                                   color:
          //                                                                       Colors.black,
          //                                                                 ),
          //                                                                 style:
          //                                                                     const TextStyle(
          //                                                                   color:
          //                                                                       Colors.grey,
          //                                                                 ),
          //                                                                 iconSize:
          //                                                                     20,
          //                                                                 buttonHeight:
          //                                                                     30,
          //                                                                 buttonWidth:
          //                                                                     160,
          //                                                                 // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
          //                                                                 dropdownDecoration:
          //                                                                     BoxDecoration(
          //                                                                   // color: Colors
          //                                                                   //     .amber,
          //                                                                   borderRadius:
          //                                                                       BorderRadius.circular(10),
          //                                                                   border:
          //                                                                       Border.all(color: Colors.white, width: 1),
          //                                                                 ),
          //                                                                 items: [
          //                                                                   DropdownMenuItem<String>(
          //                                                                     value: '0',
          //                                                                     child: Translate.TranslateAndSetText('เลขที่ใบแจ้งหนี้', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 14, 1),
          //                                                                   ),
          //                                                                   DropdownMenuItem<String>(
          //                                                                     value: '1',
          //                                                                     child: Translate.TranslateAndSetText('เลขที่สัญญา', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 14, 1),
          //                                                                   ),
          //                                                                   DropdownMenuItem<String>(
          //                                                                     value: '2',
          //                                                                     child: Translate.TranslateAndSetText('วันที่ออกใบ', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 14, 1),
          //                                                                   ),
          //                                                                   DropdownMenuItem<String>(
          //                                                                     value: '3',
          //                                                                     child: Translate.TranslateAndSetText('วันที่ครบกำหนด', Colors.grey, TextAlign.start, null, Font_.Fonts_T, 14, 1),
          //                                                                   ),
          //                                                                 ],

          //                                                                 onChanged:
          //                                                                     (value) async {
          //                                                                   if (value.toString() ==
          //                                                                       '0') {
          //                                                                     limitedList_InvoiceModels_.sort((a, b) => b.docno!.compareTo(a.docno!));
          //                                                                   } else if (value.toString() ==
          //                                                                       '1') {
          //                                                                     limitedList_InvoiceModels_.sort((a, b) => b.cid!.compareTo(a.cid!));
          //                                                                   } else if (value.toString() ==
          //                                                                       '2') {
          //                                                                     //DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec}'))
          //                                                                     limitedList_InvoiceModels_.sort((a, b) => DateTime.parse(b.daterec!).compareTo(DateTime.parse(a.daterec!)));
          //                                                                     // InvoiceModels.sort((a, b) => b.daterec!.compareTo(a.daterec!));
          //                                                                   } else if (value.toString() ==
          //                                                                       '3') {
          //                                                                     limitedList_InvoiceModels_.sort((a, b) => DateTime.parse(b.date!).compareTo(DateTime.parse(a.date!)));
          //                                                                     // InvoiceModels.sort((a, b) => b.date!.compareTo(a.date!));
          //                                                                   } else {
          //                                                                     limitedList_InvoiceModels_.sort((a, b) => b.docno!.compareTo(a.docno!));
          //                                                                   }
          //                                                                   //  limitedList_InvoiceModels_
          //                                                                   setState(() {
          //                                                                     _InvoiceModels = limitedList_InvoiceModels_;
          //                                                                   });
          //                                                                   read_Invoice_limit();
          //                                                                   // print(value);
          //                                                                 },
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                           // if (InvoiceModels
          //                                                           //         .length !=
          //                                                           //     0)
          //                                                           //   Container(
          //                                                           //       padding:
          //                                                           //           const EdgeInsets.all(
          //                                                           //               8.0),
          //                                                           //       // width: 130,
          //                                                           //       child:
          //                                                           //           Next_page_Save())
          //                                                         ],
          //                                                       ),
          //                                                     ),
          //                                                     // ),
          //                                                     Expanded(
          //                                                       child: Row(
          //                                                         mainAxisAlignment:
          //                                                             MainAxisAlignment
          //                                                                 .end,
          //                                                         children: [
          //                                                           if (api_key ==
          //                                                               'Y')
          //                                                             Container(
          //                                                               decoration:
          //                                                                   BoxDecoration(
          //                                                                 color:
          //                                                                     Colors.deepOrange[400],
          //                                                                 borderRadius: const BorderRadius.only(
          //                                                                     topLeft: Radius.circular(8),
          //                                                                     topRight: Radius.circular(8),
          //                                                                     bottomLeft: Radius.circular(8),
          //                                                                     bottomRight: Radius.circular(8)),
          //                                                                 border: Border.all(
          //                                                                     color: Colors.grey,
          //                                                                     width: 1),
          //                                                               ),
          //                                                               width:
          //                                                                   200,
          //                                                               child:
          //                                                                   Padding(
          //                                                                 padding:
          //                                                                     const EdgeInsets.all(8.0),
          //                                                                 child:
          //                                                                     InkWell(
          //                                                                   onTap:
          //                                                                       () async {
          //                                                                     PanaraConfirmDialog.showAnimatedGrow(
          //                                                                       context,
          //                                                                       title: "Check Payment",
          //                                                                       message: "เช็คการชำระเงิน",
          //                                                                       confirmButtonText: "Confirm",
          //                                                                       cancelButtonText: "Cancel",
          //                                                                       onTapConfirm: () async {
          //                                                                         Dia_log();
          //                                                                         for (var index = 0; index < _InvoiceModels.length; index++) {
          //                                                                           if (_InvoiceModels[index].refapi != "") {
          //                                                                             var refapi = _InvoiceModels[index].refapi;
          //                                                                             var incid = _InvoiceModels[index].cid;
          //                                                                             var indocno = _InvoiceModels[index].docno;
          //                                                                             var insum = double.parse(_InvoiceModels[index].total_dis!);
          //                                                                             var name = _InvoiceModels[index].scname;
          //                                                                             var datec = _InvoiceModels[index].date;

          //                                                                             // print('$refapi $insum $incid $indocno $name $datec');
          //                                                                             // if (_InvoiceModels[index].ser_noti != null) {
          //                                                                             SharedPreferences preferences = await SharedPreferences.getInstance();
          //                                                                             var ren = preferences.getString('renTalSer');
          //                                                                             String url = '${MyConstant().domain}/chack_invoice_api.php?isAdd=true&ren=$ren&refapi=$refapi&name=$name&insum=$insum&datec=$datec';

          //                                                                             try {
          //                                                                               var response = await http.get(Uri.parse(url));

          //                                                                               var result = json.decode(response.body);

          //                                                                               if (result.toString() != 'No') {
          //                                                                                 print(result.toString());
          //                                                                                 ChackpayinvoiceModel chackpayinvoiceModel = ChackpayinvoiceModel.fromJson(result);
          //                                                                                 var amountx = chackpayinvoiceModel.amount;
          //                                                                                 var ref_idx = chackpayinvoiceModel.ref_id;
          //                                                                                 var transTimex = chackpayinvoiceModel.transTime;
          //                                                                                 var reference2x = chackpayinvoiceModel.reference2;
          //                                                                                 var reference1x = chackpayinvoiceModel.reference1;
          //                                                                                 var Value_newDateY1 = DateTime.now();
          //                                                                                 var Value_newDatepay = chackpayinvoiceModel.transDate;
          //                                                                                 // print('>>>> $amountx $ref_idx $transTimex $reference2x $reference1x $Value_newDatepay');
          //                                                                                 red_Trans_selectPay_check(index).then((value) => in_Trans_invoice_refnoPay_chack(index, Value_newDateY1, Value_newDatepay, '0'));
          //                                                                               } else {
          //                                                                                 print('ยังไม่มีการชำระ');
          //                                                                               }
          //                                                                             } catch (e) {
          //                                                                               // print('Error-Dis(read_GC_rental) : ${e}');
          //                                                                             }
          //                                                                           } else {
          //                                                                             print(' ${_InvoiceModels[index].cid}');
          //                                                                           }
          //                                                                         }
          //                                                                         setState(() {
          //                                                                           // Future.delayed(const Duration(milliseconds: 800));
          //                                                                           red_InvoiceMon_bill();
          //                                                                         });
          //                                                                         Navigator.pop(context);
          //                                                                         Navigator.pop(context);
          //                                                                       },
          //                                                                       onTapCancel: () {
          //                                                                         Navigator.pop(context);
          //                                                                       },
          //                                                                       panaraDialogType: PanaraDialogType.success,
          //                                                                     );
          //                                                                   },
          //                                                                   child:
          //                                                                       Row(
          //                                                                     mainAxisAlignment: MainAxisAlignment.center,
          //                                                                     children: [
          //                                                                       Text(
          //                                                                         'Check Payment',
          //                                                                         textAlign: TextAlign.center,
          //                                                                         style: const TextStyle(
          //                                                                           color: Colors.white,
          //                                                                           // fontWeight:
          //                                                                           //     FontWeight.bold,
          //                                                                           fontFamily: Font_.Fonts_T,
          //                                                                         ),
          //                                                                       ),
          //                                                                     ],
          //                                                                   ),
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                           if (api_key ==
          //                                                               'Y')
          //                                                             SizedBox(
          //                                                               width:
          //                                                                   10,
          //                                                             ),
          //                                                           Container(
          //                                                             decoration:
          //                                                                 BoxDecoration(
          //                                                               color: Colors
          //                                                                   .blueAccent,
          //                                                               borderRadius: const BorderRadius.only(
          //                                                                   topLeft:
          //                                                                       Radius.circular(8),
          //                                                                   topRight: Radius.circular(8),
          //                                                                   bottomLeft: Radius.circular(8),
          //                                                                   bottomRight: Radius.circular(8)),
          //                                                               border: Border.all(
          //                                                                   color:
          //                                                                       Colors.grey,
          //                                                                   width: 1),
          //                                                             ),
          //                                                             width:
          //                                                                 200,
          //                                                             child:
          //                                                                 Padding(
          //                                                               padding:
          //                                                                   const EdgeInsets.all(8.0),
          //                                                               child:
          //                                                                   InkWell(
          //                                                                 onTap:
          //                                                                     () async {
          //                                                                   PanaraConfirmDialog.showAnimatedGrow(
          //                                                                     context,
          //                                                                     title: "Line Notification",
          //                                                                     message: "แจ้งเตือนชำระค่าบริการผ่านไลน์",
          //                                                                     confirmButtonText: "Confirm",
          //                                                                     cancelButtonText: "Cancel",
          //                                                                     onTapConfirm: () async {
          //                                                                       for (var index = 0; index < _InvoiceModels.length; index++) {
          //                                                                         if (_InvoiceModels[index].ser_noti != null) {
          //                                                                           var serregis = _InvoiceModels[index].ser_noti;
          //                                                                           var incid = _InvoiceModels[index].cid;
          //                                                                           var indocno = _InvoiceModels[index].docno;
          //                                                                           var insum = nFormat.format(double.parse(_InvoiceModels[index].total_dis!));
          //                                                                           if (_InvoiceModels[index].ser_noti != null) {
          //                                                                             SharedPreferences preferences = await SharedPreferences.getInstance();
          //                                                                             var ren = preferences.getString('renTalSer');
          //                                                                             String url = '${MyConstant().domain}/sent_line_noti.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
          //                                                                             renTal_name = preferences.getString('renTalName');
          //                                                                             try {
          //                                                                               var response = await http.get(Uri.parse(url));

          //                                                                               var result = json.decode(response.body);

          //                                                                               if (result.toString() == 'Line Successfully') {
          //                                                                                 // print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
          //                                                                                 // ScaffoldMessenger.of(context).showSnackBar(
          //                                                                                 //   SnackBar(
          //                                                                                 //     content: Text(
          //                                                                                 //       'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ) (${_InvoiceModels[index].scname} : ${_InvoiceModels[index].cname})',
          //                                                                                 //       style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                                 //     ),
          //                                                                                 //   ),
          //                                                                                 // );
          //                                                                               } else {
          //                                                                                 // print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
          //                                                                                 // ScaffoldMessenger.of(context).showSnackBar(
          //                                                                                 //   SnackBar(
          //                                                                                 //     content: Text(
          //                                                                                 //       'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่) (${_InvoiceModels[index].scname} : ${_InvoiceModels[index].cname})',
          //                                                                                 //       style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                                 //     ),
          //                                                                                 //   ),
          //                                                                                 // );
          //                                                                               }
          //                                                                             } catch (e) {
          //                                                                               // print('Error-Dis(read_GC_rental) : ${e}');
          //                                                                             }
          //                                                                           }
          //                                                                         }
          //                                                                         if (index + 1 == _InvoiceModels.length) {
          //                                                                           Navigator.pop(context);
          //                                                                           ScaffoldMessenger.of(context).showSnackBar(
          //                                                                             SnackBar(
          //                                                                               content: Text(
          //                                                                                 'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
          //                                                                                 style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                               ),
          //                                                                             ),
          //                                                                           );
          //                                                                           ScaffoldMessenger.of(context).showSnackBar(
          //                                                                             SnackBar(
          //                                                                               content: Text(
          //                                                                                 'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
          //                                                                                 style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                               ),
          //                                                                             ),
          //                                                                           );
          //                                                                         }
          //                                                                       }
          //                                                                       // Navigator.pop(context);
          //                                                                     },
          //                                                                     onTapCancel: () {
          //                                                                       Navigator.pop(context);
          //                                                                     },
          //                                                                     panaraDialogType: PanaraDialogType.success,
          //                                                                   );
          //                                                                 },
          //                                                                 child:
          //                                                                     Row(
          //                                                                   mainAxisAlignment:
          //                                                                       MainAxisAlignment.center,
          //                                                                   children: [
          //                                                                     Icon(
          //                                                                       Icons.notifications,
          //                                                                       color: Colors.yellow.shade900,
          //                                                                     ),
          //                                                                     SizedBox(
          //                                                                       width: 10,
          //                                                                     ),
          //                                                                     Text(
          //                                                                       'Line Notification',
          //                                                                       textAlign: TextAlign.center,
          //                                                                       style: const TextStyle(
          //                                                                         color: Colors.black,
          //                                                                         // fontWeight:
          //                                                                         //     FontWeight.bold,
          //                                                                         fontFamily: Font_.Fonts_T,
          //                                                                       ),
          //                                                                     ),
          //                                                                   ],
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                           ),
          //                                                         ],
          //                                                       ),
          //                                                     )
          //                                                   ],
          //                                                 ),
          //                                                 const Divider(),
          //                                                 Row(
          //                                                   mainAxisAlignment:
          //                                                       MainAxisAlignment
          //                                                           .center,
          //                                                   children: [
          //                                                     (invoice_select.length !=
          //                                                                 0 &&
          //                                                             InvoiceModels
          //                                                                     .length !=
          //                                                                 0)
          //                                                         ? Padding(
          //                                                             padding:
          //                                                                 const EdgeInsets.all(
          //                                                                     8.0),
          //                                                             child:
          //                                                                 Row(
          //                                                               mainAxisAlignment:
          //                                                                   MainAxisAlignment.spaceBetween,
          //                                                               children: [
          //                                                                 Container(
          //                                                                   decoration:
          //                                                                       BoxDecoration(
          //                                                                     color: Colors.white,
          //                                                                     borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(0), bottomLeft: Radius.circular(8), bottomRight: Radius.circular(0)),
          //                                                                     border: Border.all(color: Colors.grey, width: 1),
          //                                                                   ),
          //                                                                   padding:
          //                                                                       const EdgeInsets.all(2),
          //                                                                   child:
          //                                                                       Text(
          //                                                                     'Save ( ${invoice_select.length} )',
          //                                                                     textAlign: TextAlign.center,
          //                                                                     style: TextStyle(
          //                                                                       fontSize: 13,
          //                                                                       color: Colors.grey[800],
          //                                                                       fontWeight: FontWeight.bold,
          //                                                                       fontFamily: FontWeight_.Fonts_T,
          //                                                                     ),
          //                                                                   ),
          //                                                                 ),
          //                                                                 PopupMenuButton(
          //                                                                   child:
          //                                                                       Container(
          //                                                                     decoration: BoxDecoration(
          //                                                                       color: Colors.orange,
          //                                                                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(8), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(8)),
          //                                                                       border: Border.all(color: Colors.grey, width: 1),
          //                                                                     ),
          //                                                                     padding: const EdgeInsets.all(2),
          //                                                                     child: const Icon(
          //                                                                       Icons.download,
          //                                                                       color: Colors.white,
          //                                                                       size: 22,
          //                                                                     ),
          //                                                                   ),
          //                                                                   itemBuilder: (BuildContext context) =>
          //                                                                       [
          //                                                                     PopupMenuItem(
          //                                                                         onTap: () async {
          //                                                                           Future.delayed(const Duration(microseconds: 800), () async {
          //                                                                             List newValuePDFimg = [];

          //                                                                             for (int index = 0; index < 1; index++) {
          //                                                                               if (renTalModels[0].imglogo!.trim() == '') {
          //                                                                                 // newValuePDFimg.add(
          //                                                                                 //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
          //                                                                               } else {
          //                                                                                 newValuePDFimg.add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
          //                                                                               }
          //                                                                             }

          //                                                                             _showMyDialog_SAVE2(newValuePDFimg, 'Folder');
          //                                                                           });
          //                                                                         },
          //                                                                         child: Container(
          //                                                                           decoration: const BoxDecoration(
          //                                                                             // color: Colors.green[100]!
          //                                                                             //     .withOpacity(0.5),
          //                                                                             border: Border(
          //                                                                               bottom: BorderSide(
          //                                                                                 color: Colors.black12,
          //                                                                                 width: 1,
          //                                                                               ),
          //                                                                             ),
          //                                                                           ),
          //                                                                           padding: const EdgeInsets.all(2.0),
          //                                                                           // width: 200,
          //                                                                           child: Row(
          //                                                                             children: [
          //                                                                               Text(
          //                                                                                 'Save( ${invoice_select.length} ) : Folder ',
          //                                                                                 style: const TextStyle(
          //                                                                                   fontSize: 14,
          //                                                                                   color: ReportScreen_Color.Colors_Text2_,
          //                                                                                   // fontWeight: FontWeight.bold,
          //                                                                                   fontFamily: Font_.Fonts_T,
          //                                                                                 ),
          //                                                                               ),
          //                                                                               Icon(Icons.folder, color: Colors.amber[600])
          //                                                                             ],
          //                                                                           ),
          //                                                                         )),
          //                                                                     PopupMenuItem(
          //                                                                         onTap: () async {
          //                                                                           Future.delayed(const Duration(microseconds: 800), () async {
          //                                                                             List newValuePDFimg = [];

          //                                                                             for (int index = 0; index < 1; index++) {
          //                                                                               if (renTalModels[0].imglogo!.trim() == '') {
          //                                                                                 // newValuePDFimg.add(
          //                                                                                 //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
          //                                                                               } else {
          //                                                                                 newValuePDFimg.add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
          //                                                                               }
          //                                                                             }

          //                                                                             _showMyDialog_SAVE2(newValuePDFimg, 'File');
          //                                                                           });
          //                                                                         },
          //                                                                         child: Container(
          //                                                                           decoration: const BoxDecoration(
          //                                                                             // color: Colors.green[100]!
          //                                                                             //     .withOpacity(0.5),
          //                                                                             border: Border(
          //                                                                               bottom: BorderSide(
          //                                                                                 color: Colors.black12,
          //                                                                                 width: 1,
          //                                                                               ),
          //                                                                             ),
          //                                                                           ),
          //                                                                           padding: const EdgeInsets.all(2.0),
          //                                                                           // width: 200,
          //                                                                           child: Row(
          //                                                                             children: [
          //                                                                               Text(
          //                                                                                 'Save( ${invoice_select.length} ) : File ',
          //                                                                                 style: const TextStyle(
          //                                                                                   fontSize: 14,
          //                                                                                   color: ReportScreen_Color.Colors_Text2_,
          //                                                                                   // fontWeight: FontWeight.bold,
          //                                                                                   fontFamily: Font_.Fonts_T,
          //                                                                                 ),
          //                                                                               ),
          //                                                                               const Icon(Icons.file_copy, color: AppBarColors.ABar_Colors)
          //                                                                             ],
          //                                                                           ),
          //                                                                         )),
          //                                                                     PopupMenuItem(
          //                                                                         onTap: () async {
          //                                                                           setState(() {
          //                                                                             invoice_select.clear();
          //                                                                           });
          //                                                                         },
          //                                                                         child: Container(
          //                                                                           decoration: const BoxDecoration(
          //                                                                             // color: Colors.green[100]!
          //                                                                             //     .withOpacity(0.5),
          //                                                                             border: Border(
          //                                                                               bottom: BorderSide(
          //                                                                                 color: Colors.black12,
          //                                                                                 width: 1,
          //                                                                               ),
          //                                                                             ),
          //                                                                           ),
          //                                                                           padding: const EdgeInsets.all(2.0),
          //                                                                           // width: 200,
          //                                                                           child: Row(
          //                                                                             children: [
          //                                                                               Translate.TranslateAndSetText('ยกเลิกทั้งหมด( ${invoice_select.length} ) : ', AccountScreen_Color.Colors_Text1_, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
          //                                                                               // Text(
          //                                                                               //   'ยกเลิกทั้งหมด( ${invoice_select.length} ) : ',
          //                                                                               //   style: const TextStyle(
          //                                                                               //     fontSize: 14,
          //                                                                               //     color: ReportScreen_Color.Colors_Text2_,
          //                                                                               //     // fontWeight: FontWeight.bold,
          //                                                                               //     fontFamily: Font_.Fonts_T,
          //                                                                               //   ),
          //                                                                               // ),
          //                                                                               const Icon(
          //                                                                                 Icons.check_box_outline_blank,
          //                                                                                 color: Colors.red,
          //                                                                                 size: 22,
          //                                                                               ),
          //                                                                             ],
          //                                                                           ),
          //                                                                         )),
          //                                                                   ],
          //                                                                 ),
          //                                                                 // Container(
          //                                                                 //   decoration:
          //                                                                 //       BoxDecoration(
          //                                                                 //     color:
          //                                                                 //         Colors.orange,
          //                                                                 //     borderRadius: const BorderRadius.only(
          //                                                                 //         topLeft: Radius.circular(0),
          //                                                                 //         topRight: Radius.circular(8),
          //                                                                 //         bottomLeft: Radius.circular(0),
          //                                                                 //         bottomRight: Radius.circular(8)),
          //                                                                 //     border: Border.all(
          //                                                                 //         color: Colors.grey,
          //                                                                 //         width: 1),
          //                                                                 //   ),
          //                                                                 //   padding:
          //                                                                 //       const EdgeInsets.all(2),
          //                                                                 //   child:
          //                                                                 //       InkWell(
          //                                                                 //     onTap:
          //                                                                 //         () async {
          //                                                                 //       List
          //                                                                 //           newValuePDFimg =
          //                                                                 //           [];

          //                                                                 //       for (int index = 0;
          //                                                                 //           index < 1;
          //                                                                 //           index++) {
          //                                                                 //         if (renTalModels[0].imglogo!.trim() == '') {
          //                                                                 //           // newValuePDFimg.add(
          //                                                                 //           //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
          //                                                                 //         } else {
          //                                                                 //           newValuePDFimg.add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
          //                                                                 //         }
          //                                                                 //       }

          //                                                                 //       _showMyDialog_SAVE2(newValuePDFimg);
          //                                                                 //     },
          //                                                                 //     child:
          //                                                                 //         const Icon(
          //                                                                 //       Icons.download,
          //                                                                 //       color:
          //                                                                 //           Colors.white,
          //                                                                 //       size:
          //                                                                 //           22,
          //                                                                 //     ),
          //                                                                 //   ),
          //                                                                 // )
          //                                                               ],
          //                                                             ),
          //                                                           )
          //                                                         : (Text_searchBar_main1
          //                                                                 .text
          //                                                                 .isNotEmpty)
          //                                                             ? const Expanded(
          //                                                                 flex:
          //                                                                     1,
          //                                                                 child:
          //                                                                     Text(
          //                                                                   '...',
          //                                                                   textAlign:
          //                                                                       TextAlign.center,
          //                                                                   style:
          //                                                                       TextStyle(
          //                                                                     color: Colors.green,
          //                                                                     // fontWeight:
          //                                                                     //     FontWeight.bold,
          //                                                                     fontFamily: Font_.Fonts_T,
          //                                                                   ),
          //                                                                 ))
          //                                                             : Padding(
          //                                                                 padding: const EdgeInsets.fromLTRB(
          //                                                                     8,
          //                                                                     0,
          //                                                                     4,
          //                                                                     0),
          //                                                                 child:
          //                                                                     Container(
          //                                                                   decoration:
          //                                                                       BoxDecoration(
          //                                                                     color: Colors.white,
          //                                                                     borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
          //                                                                     border: Border.all(color: Colors.grey, width: 1),
          //                                                                   ),
          //                                                                   padding:
          //                                                                       const EdgeInsets.all(2.0),
          //                                                                   width:
          //                                                                       100,
          //                                                                   child:
          //                                                                       InkWell(
          //                                                                     onTap: () async {
          //                                                                       setState(() {
          //                                                                         invoice_select_delete.clear();
          //                                                                         invoice_select.clear();
          //                                                                       });
          //                                                                       // print(InvoiceModels
          //                                                                       //     .length);
          //                                                                       for (int index = 0; index < InvoiceModels.length; index++) {
          //                                                                         if (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') {
          //                                                                         } else {
          //                                                                           setState(() {
          //                                                                             invoice_select.add('${InvoiceModels[index].docno}');
          //                                                                           });
          //                                                                         }
          //                                                                       }
          //                                                                     },
          //                                                                     child: Text(
          //                                                                       'All: ${(endIndex / limit)}/${(limitedList_InvoiceModels_.length / limit).ceil()} [✔]',
          //                                                                       textAlign: TextAlign.center,
          //                                                                       style: const TextStyle(
          //                                                                         color: Colors.green,
          //                                                                         // fontWeight:
          //                                                                         //     FontWeight.bold,
          //                                                                         fontFamily: Font_.Fonts_T,
          //                                                                       ),
          //                                                                     ),
          //                                                                   ),
          //                                                                 ),
          //                                                               ),
          //                                                     Expanded(
          //                                                       flex: 12,
          //                                                       child: Row(
          //                                                         mainAxisAlignment:
          //                                                             MainAxisAlignment
          //                                                                 .start,
          //                                                         children: ac4_1
          //                                                             .where((item) => item["st"] == '1') // Filter items
          //                                                             .toList() // Convert to a list
          //                                                             .asMap()
          //                                                             .entries
          //                                                             .map((entry) {
          //                                                           int index =
          //                                                               entry
          //                                                                   .key; // Get the index
          //                                                           var item = entry
          //                                                               .value; // Get the item

          //                                                           return Expanded(
          //                                                             flex: 1,
          //                                                             child:
          //                                                                 Padding(
          //                                                               padding:
          //                                                                   EdgeInsets.all(0.0),
          //                                                               child: Translate
          //                                                                   .TranslateAndSetText(
          //                                                                 item["pn"] ??
          //                                                                     "", // Use "pn" or an empty string if null
          //                                                                 AccountScreen_Color
          //                                                                     .Colors_Text1_,
          //                                                                 (item["ser"] == '2' || item["ser"] == '3' || item["ser"] == '8' || item["ser"] == '12' || item["ser"] == '13' || item["ser"] == '14')
          //                                                                     ? TextAlign.center
          //                                                                     : (item["ser"] == '9' || item["ser"] == '10' || item["ser"] == '11')
          //                                                                         ? TextAlign.right
          //                                                                         : TextAlign.start,
          //                                                                 FontWeight
          //                                                                     .bold,
          //                                                                 FontWeight_
          //                                                                     .Fonts_T,
          //                                                                 14,
          //                                                                 1,
          //                                                               ),
          //                                                             ),
          //                                                           );
          //                                                         }).toList(),
          //                                                       ),
          //                                                     ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'เลขสัญญา',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .start,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // Expanded(
          //                                                     //   flex: 2,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'เลขที่ใบแจ้งหนี้',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .start,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // // Expanded(
          //                                                     // //   flex: 1,
          //                                                     // //   child: Text(
          //                                                     // //     'สถานะ',
          //                                                     // //     textAlign: TextAlign.start,
          //                                                     // //     style: TextStyle(
          //                                                     // //       color: ManageScreen_Color
          //                                                     // //           .Colors_Text1_,
          //                                                     // //       fontWeight: FontWeight.bold,
          //                                                     // //       fontFamily: FontWeight_.Fonts_T,
          //                                                     // //     ),
          //                                                     // //   ),
          //                                                     // // ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'ออกใบแจ้งหนี้',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .start,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       12,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'กำหนดชำระ',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .start,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       12,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // Expanded(
          //                                                     //   flex: 2,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'ชื่อร้านค้า',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .start,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // // Expanded(
          //                                                     // //   flex: 2,
          //                                                     // //   child: Text(
          //                                                     // //     'รอบการเช่า',
          //                                                     // //     textAlign: TextAlign.start,
          //                                                     // //     style: TextStyle(
          //                                                     // //       color: ManageScreen_Color
          //                                                     // //           .Colors_Text1_,
          //                                                     // //       fontWeight: FontWeight.bold,
          //                                                     // //       fontFamily: FontWeight_.Fonts_T,
          //                                                     // //     ),
          //                                                     // //   ),
          //                                                     // // ),
          //                                                     // // Expanded(
          //                                                     // //   flex: 1,
          //                                                     // //   child: Translate.TranslateAndSetText(
          //                                                     // //       'โซน',
          //                                                     // //       AccountScreen_Color
          //                                                     // //           .Colors_Text1_,
          //                                                     // //       TextAlign
          //                                                     // //           .start,
          //                                                     // //       FontWeight
          //                                                     // //           .bold,
          //                                                     // //       FontWeight_
          //                                                     // //           .Fonts_T,
          //                                                     // //       14,
          //                                                     // //       1),
          //                                                     // // ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'รหัสพื้นที่',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .start,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'ช่องทางชำระ',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .center,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // // for (int index = 0;
          //                                                     // //     index < expModels.length;
          //                                                     // //     index++)
          //                                                     // //   Expanded(
          //                                                     // //     flex: 2,
          //                                                     // //     child: Text(
          //                                                     // //       '${expModels[index].expname}',
          //                                                     // //       textAlign: TextAlign.end,
          //                                                     // //       style: TextStyle(
          //                                                     // //         color: ManageScreen_Color
          //                                                     // //             .Colors_Text1_,
          //                                                     // //         fontWeight: FontWeight.bold,
          //                                                     // //         fontFamily:
          //                                                     // //             FontWeight_.Fonts_T,
          //                                                     // //       ),
          //                                                     // //     ),
          //                                                     // //   ),
          //                                                     // // Expanded(
          //                                                     // //   flex: 2,
          //                                                     // //   child: Text(
          //                                                     // //     'ภาษีมูลค่าเพิ่ม',
          //                                                     // //     textAlign: TextAlign.end,
          //                                                     // //     style: TextStyle(
          //                                                     // //       color: ManageScreen_Color
          //                                                     // //           .Colors_Text1_,
          //                                                     // //       fontWeight: FontWeight.bold,
          //                                                     // //       fontFamily: FontWeight_.Fonts_T,
          //                                                     // //     ),
          //                                                     // //   ),
          //                                                     // // ),
          //                                                     // // Expanded(
          //                                                     // //   flex: 2,
          //                                                     // //   child: Text(
          //                                                     // //     'ภาษีหัก ณ ที่จ่าย',
          //                                                     // //     textAlign: TextAlign.end,
          //                                                     // //     style: TextStyle(
          //                                                     // //       color: ManageScreen_Color
          //                                                     // //           .Colors_Text1_,
          //                                                     // //       fontWeight: FontWeight.bold,
          //                                                     // //       fontFamily: FontWeight_.Fonts_T,
          //                                                     // //     ),
          //                                                     // //   ),
          //                                                     // // ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'ส่วนลด',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .end,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'ยอดรวม',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .end,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),
          //                                                     // Expanded(
          //                                                     //   flex: 1,
          //                                                     //   child: Translate.TranslateAndSetText(
          //                                                     //       'ยอดสุทธิ',
          //                                                     //       AccountScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       TextAlign
          //                                                     //           .center,
          //                                                     //       FontWeight
          //                                                     //           .bold,
          //                                                     //       FontWeight_
          //                                                     //           .Fonts_T,
          //                                                     //       14,
          //                                                     //       1),
          //                                                     // ),

          //                                                     // Expanded(
          //                                                     //   flex: 2,
          //                                                     //   child: Text(
          //                                                     //     'หมายเหตุ',
          //                                                     //     textAlign: TextAlign.end,
          //                                                     //     style: TextStyle(
          //                                                     //       color: ManageScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       fontWeight: FontWeight.bold,
          //                                                     //       fontFamily: FontWeight_.Fonts_T,
          //                                                     //     ),
          //                                                     //   ),
          //                                                     // ),
          //                                                     // if (rtser.toString() == '50' ||
          //                                                     //     rtser.toString() ==
          //                                                     //         '72' ||
          //                                                     //     rtser.toString() ==
          //                                                     //         '92' ||
          //                                                     //     rtser.toString() ==
          //                                                     //         '93' ||
          //                                                     //     rtser.toString() ==
          //                                                     //         '94')
          //                                                     // Container(
          //                                                     //   width: 70,
          //                                                     //   child: Text(
          //                                                     //     '',
          //                                                     //     textAlign:
          //                                                     //         TextAlign
          //                                                     //             .end,
          //                                                     //     style:
          //                                                     //         TextStyle(
          //                                                     //       color: ManageScreen_Color
          //                                                     //           .Colors_Text1_,
          //                                                     //       fontWeight:
          //                                                     //           FontWeight
          //                                                     //               .bold,
          //                                                     //       fontFamily:
          //                                                     //           FontWeight_
          //                                                     //               .Fonts_T,
          //                                                     //     ),
          //                                                     //   ),
          //                                                     // ),
          //                                                     Expanded(
          //                                                       flex: 3,
          //                                                       child: (invoice_select_delete.length !=
          //                                                                   0 &&
          //                                                               InvoiceModels.length !=
          //                                                                   0)
          //                                                           ? Padding(
          //                                                               padding:
          //                                                                   const EdgeInsets.all(8.0),
          //                                                               child:
          //                                                                   Row(
          //                                                                 mainAxisAlignment:
          //                                                                     MainAxisAlignment.end,
          //                                                                 children: [
          //                                                                   Container(
          //                                                                     decoration: BoxDecoration(
          //                                                                       color: Colors.white,
          //                                                                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(0), bottomLeft: Radius.circular(8), bottomRight: Radius.circular(0)),
          //                                                                       border: Border.all(color: Colors.grey, width: 1),
          //                                                                     ),
          //                                                                     padding: const EdgeInsets.all(2),
          //                                                                     child: Text(
          //                                                                       'delete ( ${invoice_select_delete.length} )',
          //                                                                       textAlign: TextAlign.center,
          //                                                                       style: TextStyle(
          //                                                                         fontSize: 13,
          //                                                                         color: Colors.grey[800],
          //                                                                         fontWeight: FontWeight.bold,
          //                                                                         fontFamily: FontWeight_.Fonts_T,
          //                                                                       ),
          //                                                                     ),
          //                                                                   ),
          //                                                                   PopupMenuButton(
          //                                                                     child: Container(
          //                                                                       decoration: BoxDecoration(
          //                                                                         color: Colors.red,
          //                                                                         borderRadius: const BorderRadius.only(topLeft: Radius.circular(0), topRight: Radius.circular(8), bottomLeft: Radius.circular(0), bottomRight: Radius.circular(8)),
          //                                                                         border: Border.all(color: Colors.grey, width: 1),
          //                                                                       ),
          //                                                                       padding: const EdgeInsets.all(2),
          //                                                                       child: const Icon(
          //                                                                         Icons.delete,
          //                                                                         color: Colors.white,
          //                                                                         size: 22,
          //                                                                       ),
          //                                                                     ),
          //                                                                     itemBuilder: (BuildContext context) => [
          //                                                                       PopupMenuItem(
          //                                                                           onTap: () async {
          //                                                                             Future.delayed(const Duration(microseconds: 800), () async {
          //                                                                               _showMyDialog_delete();
          //                                                                             });
          //                                                                           },
          //                                                                           child: Container(
          //                                                                             decoration: const BoxDecoration(
          //                                                                               // color: Colors.green[100]!
          //                                                                               //     .withOpacity(0.5),
          //                                                                               border: Border(
          //                                                                                 bottom: BorderSide(
          //                                                                                   color: Colors.black12,
          //                                                                                   width: 1,
          //                                                                                 ),
          //                                                                               ),
          //                                                                             ),
          //                                                                             padding: const EdgeInsets.all(2.0),
          //                                                                             // width: 200,
          //                                                                             child: Row(
          //                                                                               children: [
          //                                                                                 Translate.TranslateAndSetText('ยืนยันทั้งหมด( ${invoice_select_delete.length} ) : ', AccountScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
          //                                                                                 // Text(
          //                                                                                 //   'ยืนยันทั้งหมด( ${invoice_select_delete.length} ) : ',
          //                                                                                 //   style: const TextStyle(
          //                                                                                 //     fontSize: 14,
          //                                                                                 //     color: ReportScreen_Color.Colors_Text2_,
          //                                                                                 //     // fontWeight: FontWeight.bold,
          //                                                                                 //     fontFamily: Font_.Fonts_T,
          //                                                                                 //   ),
          //                                                                                 // ),
          //                                                                                 const Icon(Icons.check_box, color: AppBarColors.ABar_Colors)
          //                                                                               ],
          //                                                                             ),
          //                                                                           )),
          //                                                                       PopupMenuItem(
          //                                                                           onTap: () async {
          //                                                                             setState(() {
          //                                                                               invoice_select_delete.clear();
          //                                                                             });
          //                                                                           },
          //                                                                           child: Container(
          //                                                                             decoration: const BoxDecoration(
          //                                                                               // color: Colors.green[100]!
          //                                                                               //     .withOpacity(0.5),
          //                                                                               border: Border(
          //                                                                                 bottom: BorderSide(
          //                                                                                   color: Colors.black12,
          //                                                                                   width: 1,
          //                                                                                 ),
          //                                                                               ),
          //                                                                             ),
          //                                                                             padding: const EdgeInsets.all(2.0),
          //                                                                             // width: 200,
          //                                                                             child: Row(
          //                                                                               children: [
          //                                                                                 Translate.TranslateAndSetText('ยกเลิกทั้งหมด( ${invoice_select_delete.length} ) : ', AccountScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
          //                                                                                 // Text(
          //                                                                                 //   'ยกเลิกทั้งหมด( ${invoice_select_delete.length} ) : ',
          //                                                                                 //   style: const TextStyle(
          //                                                                                 //     fontSize: 14,
          //                                                                                 //     color: ReportScreen_Color.Colors_Text2_,
          //                                                                                 //     // fontWeight: FontWeight.bold,
          //                                                                                 //     fontFamily: Font_.Fonts_T,
          //                                                                                 //   ),
          //                                                                                 // ),
          //                                                                                 const Icon(
          //                                                                                   Icons.check_box_outline_blank,
          //                                                                                   color: Colors.red,
          //                                                                                   size: 22,
          //                                                                                 ),
          //                                                                               ],
          //                                                                             ),
          //                                                                           )),
          //                                                                     ],
          //                                                                   ),
          //                                                                   // Container(
          //                                                                   //   decoration:
          //                                                                   //       BoxDecoration(
          //                                                                   //     color:
          //                                                                   //         Colors.red,
          //                                                                   //     borderRadius: const BorderRadius.only(
          //                                                                   //         topLeft: Radius.circular(0),
          //                                                                   //         topRight: Radius.circular(8),
          //                                                                   //         bottomLeft: Radius.circular(0),
          //                                                                   //         bottomRight: Radius.circular(8)),
          //                                                                   //     border:
          //                                                                   //         Border.all(color: Colors.grey, width: 1),
          //                                                                   //   ),
          //                                                                   //   padding:
          //                                                                   //       const EdgeInsets.all(2),
          //                                                                   //   child:
          //                                                                   //       InkWell(
          //                                                                   //     onTap:
          //                                                                   //         () async {
          //                                                                   //       _showMyDialog_delete();
          //                                                                   //     },
          //                                                                   //     child:
          //                                                                   //         const Icon(
          //                                                                   //       Icons.delete,
          //                                                                   //       color: Colors.white,
          //                                                                   //       size: 22,
          //                                                                   //     ),
          //                                                                   //   ),
          //                                                                   // )
          //                                                                 ],
          //                                                               ),
          //                                                             )
          //                                                           : Container(
          //                                                               width:
          //                                                                   50,
          //                                                               child:
          //                                                                   const Text(
          //                                                                 '',
          //                                                                 textAlign:
          //                                                                     TextAlign.start,
          //                                                                 style:
          //                                                                     TextStyle(
          //                                                                   color:
          //                                                                       ManageScreen_Color.Colors_Text1_,
          //                                                                   fontWeight:
          //                                                                       FontWeight.bold,
          //                                                                   fontFamily:
          //                                                                       FontWeight_.Fonts_T,
          //                                                                 ),
          //                                                               ),
          //                                                             ),
          //                                                     ),
          //                                                   ],
          //                                                 ),
          //                                               ],
          //                                             ),
          //                                           ),
          //                                           Container(
          //                                               height: MediaQuery.of(
          //                                                           context)
          //                                                       .size
          //                                                       .height *
          //                                                   0.63,
          //                                               width: Responsive
          //                                                       .isDesktop(
          //                                                           context)
          //                                                   ?
          //                                                   // (rtser.toString() == '50' ||
          //                                                   //         rtser.toString() ==
          //                                                   //             '72' ||
          //                                                   //         rtser.toString() ==
          //                                                   //             '92' ||
          //                                                   //         rtser.toString() ==
          //                                                   //             '93' ||
          //                                                   //         rtser.toString() ==
          //                                                   //             '94')
          //                                                   //     ? MediaQuery.of(context)
          //                                                   //             .size
          //                                                   //             .width *
          //                                                   //         0.9
          //                                                   //     :
          //                                                   calculatedWidth
          //                                                   : 1200,
          //                                               decoration:
          //                                                   const BoxDecoration(
          //                                                 color:
          //                                                     AppbackgroundColor
          //                                                         .Sub_Abg_Colors,
          //                                                 borderRadius: BorderRadius.only(
          //                                                     topLeft: Radius
          //                                                         .circular(0),
          //                                                     topRight: Radius
          //                                                         .circular(0),
          //                                                     bottomLeft: Radius
          //                                                         .circular(0),
          //                                                     bottomRight:
          //                                                         Radius
          //                                                             .circular(
          //                                                                 0)),
          //                                                 // border: Border.all(color: Colors.grey, width: 1),
          //                                               ),
          //                                               child: InvoiceModels
          //                                                       .isEmpty
          //                                                   ? SizedBox(
          //                                                       child: Column(
          //                                                         mainAxisAlignment:
          //                                                             MainAxisAlignment
          //                                                                 .center,
          //                                                         children: [
          //                                                           const CircularProgressIndicator(),
          //                                                           StreamBuilder(
          //                                                             stream: Stream.periodic(
          //                                                                 const Duration(
          //                                                                     milliseconds:
          //                                                                         25),
          //                                                                 (i) =>
          //                                                                     i),
          //                                                             builder:
          //                                                                 (context,
          //                                                                     snapshot) {
          //                                                               if (!snapshot
          //                                                                   .hasData)
          //                                                                 return const Text(
          //                                                                     '');
          //                                                               double
          //                                                                   elapsed =
          //                                                                   double.parse(snapshot.data.toString()) *
          //                                                                       0.05;
          //                                                               return Padding(
          //                                                                 padding:
          //                                                                     const EdgeInsets.all(8.0),
          //                                                                 child: (elapsed > 8.00)
          //                                                                     ? Translate.TranslateAndSetText('ไม่พบข้อมูล', AccountScreen_Color.Colors_Text1_, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1)

          //                                                                     //  Text(
          //                                                                     //     'ไม่พบข้อมูล',
          //                                                                     //     style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
          //                                                                     //         //fontSize: 10.0
          //                                                                     //         ),
          //                                                                     //   )
          //                                                                     : Text(
          //                                                                         'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
          //                                                                         // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
          //                                                                         style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T
          //                                                                             //fontSize: 10.0
          //                                                                             ),
          //                                                                       ),
          //                                                               );
          //                                                             },
          //                                                           ),
          //                                                         ],
          //                                                       ),
          //                                                     )
          //                                                   : ListView.builder(
          //                                                       controller:
          //                                                           _scrollController2,
          //                                                       // itemExtent: 50,
          //                                                       physics:
          //                                                           const AlwaysScrollableScrollPhysics(),
          //                                                       shrinkWrap:
          //                                                           true,
          //                                                       itemCount:
          //                                                           InvoiceModels
          //                                                               .length,
          //                                                       itemBuilder:
          //                                                           (BuildContext
          //                                                                   context,
          //                                                               int index) {
          //                                                         return Column(
          //                                                           children: [
          //                                                             Material(
          //                                                               // color:
          //                                                               //(InvoiceModels[index].btype ==
          //                                                               //             null ||
          //                                                               //         InvoiceModels[index].btype.toString() ==
          //                                                               //             '')
          //                                                               //     ? Colors
          //                                                               //         .red[
          //                                                               //             50]!
          //                                                               //         .withOpacity(
          //                                                               //             0.4)
          //                                                               //     : AppbackgroundColor
          //                                                               //         .Sub_Abg_Colors,
          //                                                               child:
          //                                                                   Container(
          //                                                                 decoration:
          //                                                                     BoxDecoration(
          //                                                                   color: (InvoiceModels[index].date == null)
          //                                                                       ? null
          //                                                                       : (DateTime.parse('${InvoiceModels[index].date} 23:59:58').isBefore(DateTime.now()))
          //                                                                           ? Colors.deepOrange[200]!.withOpacity(0.3)
          //                                                                           : null,
          //                                                                   border:
          //                                                                       Border(
          //                                                                     bottom: BorderSide(
          //                                                                       color: Colors.black12,
          //                                                                       width: 1,
          //                                                                     ),
          //                                                                   ),
          //                                                                 ),
          //                                                                 child: ListTile(
          //                                                                     // onTap:
          //                                                                     //     () async {
          //                                                                     //   setState(() {
          //                                                                     //     tappedIndex_ =
          //                                                                     //         '${index}';
          //                                                                     //   });
          //                                                                     // },
          //                                                                     title: Container(
          //                                                                   child:
          //                                                                       Row(
          //                                                                     mainAxisAlignment: MainAxisAlignment.center,
          //                                                                     children: [
          //                                                                       (InvoiceModels[index].date == null || DateTime.parse('${InvoiceModels[index].date} 23:59:58').isBefore(DateTime.now()))
          //                                                                           ? SizedBox(
          //                                                                               width: 25,
          //                                                                               child: Padding(
          //                                                                                 padding: const EdgeInsets.all(0.0),
          //                                                                                 child: PopupMenuButton(
          //                                                                                   onOpened: () {},
          //                                                                                   child: Center(
          //                                                                                     child: InkWell(
          //                                                                                       child: Center(
          //                                                                                           child: Icon(
          //                                                                                         Icons.lock_clock,
          //                                                                                         size: 18,
          //                                                                                         color: Colors.blueGrey,
          //                                                                                       )),
          //                                                                                     ),
          //                                                                                   ),
          //                                                                                   itemBuilder: (BuildContext context) => [
          //                                                                                     PopupMenuItem(
          //                                                                                         child: Text(
          //                                                                                       (InvoiceModels[index].date == null) ? '' : '${InvoiceModels[index].docno} : เลยวันครบกำหนดชำระมาแล้ว ${DateTime.now().difference(DateTime.parse(InvoiceModels[index].date!)).inDays} วัน',
          //                                                                                       overflow: TextOverflow.ellipsis,
          //                                                                                       maxLines: 2,
          //                                                                                       style: const TextStyle(
          //                                                                                           color: PeopleChaoScreen_Color.Colors_Text2_,
          //                                                                                           //fontWeight: FontWeight.bold,
          //                                                                                           fontFamily: Font_.Fonts_T),
          //                                                                                     )),
          //                                                                                   ],
          //                                                                                 ),
          //                                                                               ),
          //                                                                             )
          //                                                                           : SizedBox(width: 25),
          //                                                                       (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
          //                                                                           ? Padding(
          //                                                                               padding: const EdgeInsets.all(4.0),
          //                                                                               child: Container(
          //                                                                                 width: 60,
          //                                                                               ),
          //                                                                             )
          //                                                                           : Padding(
          //                                                                               padding: const EdgeInsets.all(4.0),
          //                                                                               child: InkWell(
          //                                                                                 onTap: () async {
          //                                                                                   setState(() {
          //                                                                                     invoice_select_delete.clear();
          //                                                                                   });
          //                                                                                   if (invoice_select.length >= 50) {
          //                                                                                     setState(() {
          //                                                                                       invoice_select.remove('${InvoiceModels[index].docno}');
          //                                                                                     });
          //                                                                                     Dialog_notimax(50);
          //                                                                                   } else {
          //                                                                                     setState(() {
          //                                                                                       if (invoice_select.contains('${InvoiceModels[index].docno}') == true) {
          //                                                                                         invoice_select.remove('${InvoiceModels[index].docno}');
          //                                                                                       } else {
          //                                                                                         invoice_select.add('${InvoiceModels[index].docno}');
          //                                                                                       }
          //                                                                                     });
          //                                                                                   }
          //                                                                                 },
          //                                                                                 child: Container(
          //                                                                                   decoration: BoxDecoration(
          //                                                                                     color: Colors.blueGrey[50]!.withOpacity(0.5),
          //                                                                                     borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          //                                                                                     border: Border.all(color: Colors.grey, width: 1),
          //                                                                                   ),
          //                                                                                   width: 60,
          //                                                                                   padding: const EdgeInsets.all(2),
          //                                                                                   child: Row(
          //                                                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                                                                                     children: [
          //                                                                                       (invoice_select.contains('${InvoiceModels[index].docno}') == true) ? const Icon(Icons.check_box, color: AppBarColors.ABar_Colors) : const Icon(Icons.check_box_outline_blank, color: Colors.grey),

          //                                                                                       ///invoice_loade_Success
          //                                                                                       Icon(
          //                                                                                         Icons.download,
          //                                                                                         color: (invoice_loade_Success.contains('${InvoiceModels[index].docno}') == true) ? Colors.orange[600] : null,
          //                                                                                       )
          //                                                                                     ],
          //                                                                                   ),
          //                                                                                 ),
          //                                                                               ),
          //                                                                             ),
          //                                                                       if (where_ac4_1("0") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: Row(children: [
          //                                                                             Copy_Text(context, '${InvoiceModels[index].cid}'),
          //                                                                              Expanded(
          //                                                                               child: Padding(
          //                                                                                 padding: const EdgeInsets.all(0.0),
          //                                                                                 child: Tooltip(
          //                                                                                   richMessage: TextSpan(
          //                                                                                     text: '${InvoiceModels[index].cid}',
          //                                                                                     style: const TextStyle(
          //                                                                                       color: HomeScreen_Color.Colors_Text1_,
          //                                                                                       fontWeight: FontWeight.bold,
          //                                                                                       fontFamily: FontWeight_.Fonts_T,
          //                                                                                       //fontSize: 10.0
          //                                                                                     ),
          //                                                                                   ),
          //                                                                                   decoration: BoxDecoration(
          //                                                                                     borderRadius: BorderRadius.circular(5),
          //                                                                                     color: Colors.grey[200],
          //                                                                                   ),
          //                                                                                   child: AutoSizeText(
          //                                                                                     minFontSize: 10,
          //                                                                                     maxFontSize: 14,
          //                                                                                     maxLines: 1,
          //                                                                                     '${InvoiceModels[index].cid}',
          //                                                                                     textAlign: TextAlign.start,
          //                                                                                     overflow: TextOverflow.ellipsis,
          //                                                                                     style: const TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
          //                                                                                   ),
          //                                                                                 ),
          //                                                                               ),
          //                                                                             ),
          //                                                                           ]),
          //                                                                         ),
          //                                                                       if (where_ac4_1("1") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: Row(
          //                                                                             mainAxisAlignment: MainAxisAlignment.start,
          //                                                                             children: [
          //                                                                               Copy_Text(context, '${InvoiceModels[index].docno}'),
          //                                                                               // InkWell(
          //                                                                               //     onTap: () async {
          //                                                                               //       Future.delayed(const Duration(milliseconds: 500), () {
          //                                                                               //         Clipboard.setData(ClipboardData(text: '${InvoiceModels[index].docno}'));
          //                                                                               //         ScaffoldMessenger.of(context).showSnackBar(
          //                                                                               //           SnackBar(
          //                                                                               //               content: Row(
          //                                                                               //             children: [
          //                                                                               //               Icon(
          //                                                                               //                 Icons.content_copy,
          //                                                                               //                 color: Colors.white,
          //                                                                               //               ),
          //                                                                               //               SizedBox(width: 8.0),
          //                                                                               //               Text('Copy :${InvoiceModels[index].docno}', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
          //                                                                               //             ],
          //                                                                               //           )),
          //                                                                               //         );
          //                                                                               //       });
          //                                                                               //     },
          //                                                                               //     child: Icon(
          //                                                                               //       Icons.content_copy,
          //                                                                               //       size: 18,
          //                                                                               //     )),
          //                                                                               Expanded(
          //                                                                                 child: AutoSizeText(
          //                                                                                   minFontSize: 10,
          //                                                                                   maxFontSize: 16,
          //                                                                                   maxLines: 1,
          //                                                                                   (InvoiceModels[index].docno == null) ? '' : '${InvoiceModels[index].docno}',
          //                                                                                   textAlign: TextAlign.start,
          //                                                                                   overflow: TextOverflow.ellipsis,
          //                                                                                   style: TextStyle(
          //                                                                                     color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                                     // fontWeight: FontWeight.bold,
          //                                                                                     fontFamily: Font_.Fonts_T,
          //                                                                                     //fontSize: 10.0
          //                                                                                   ),
          //                                                                                 ),
          //                                                                               ),
          //                                                                             ],
          //                                                                           ),
          //                                                                         ),
          //                                                                       // Expanded(
          //                                                                       //   flex: 2,
          //                                                                       //   child: AutoSizeText(
          //                                                                       //     minFontSize: 10,
          //                                                                       //     maxFontSize: 25,
          //                                                                       //     maxLines: 1,
          //                                                                       //     '${InvoiceModels[index].docno}',
          //                                                                       //     textAlign: TextAlign.start,
          //                                                                       //     overflow: TextOverflow.ellipsis,
          //                                                                       //     style: TextStyle(
          //                                                                       //       color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                       //       // fontWeight: FontWeight.bold,
          //                                                                       //       fontFamily: Font_.Fonts_T,
          //                                                                       //       //fontSize: 10.0
          //                                                                       //     ),
          //                                                                       //   ),
          //                                                                       // ),
          //                                                                       if (where_ac4_1("2") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].daterec == null || InvoiceModels[index].daterec.toString() == '') ? '' : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec}'))}-${DateTime.parse('${InvoiceModels[index].daterec}').year + 0}',
          //                                                                             //'${DateFormat('dd-MM-yyyy').format(DateTime.parse('${InvoiceModels[index].daterec}'))}',
          //                                                                             textAlign: TextAlign.center,

          //                                                                             overflow: TextOverflow.ellipsis,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight: FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                               // fontSize: 12.0
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("3") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].date == null || InvoiceModels[index].date.toString() == '') ? '' : '${DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].date}'))}-${DateTime.parse('${InvoiceModels[index].date}').year + 0}',
          //                                                                             //'${DateFormat('dd-MM-yyyy').format(DateTime.parse('${InvoiceModels[index].daterec}'))}',
          //                                                                             textAlign: TextAlign.center,

          //                                                                             overflow: TextOverflow.ellipsis,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight: FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                               // fontSize: 12.0
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("4") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].scname == null) ? '' : '${InvoiceModels[index].scname}',
          //                                                                             // '${transMeterModels[index].ovalue}',
          //                                                                             textAlign: TextAlign.start,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight: FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                               //fontSize: 12.0
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("5") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1, (InvoiceModels[index].cname == null) ? '' : '${InvoiceModels[index].cname}',
          //                                                                             // '${transMeterModels[index].ovalue}',
          //                                                                             textAlign: TextAlign.start,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight: FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                               //fontSize: 12.0
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       // Expanded(
          //                                                                       //   flex: 1,
          //                                                                       //   child: AutoSizeText(
          //                                                                       //     minFontSize: 10,
          //                                                                       //     maxFontSize: 25,
          //                                                                       //     maxLines: 1,
          //                                                                       //     '${InvoiceModels[index].zn}',
          //                                                                       //     //'${transMeterModels[index].qty}',
          //                                                                       //     textAlign: TextAlign.start,
          //                                                                       //     style: TextStyle(
          //                                                                       //       color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                       //       // fontWeight:
          //                                                                       //       //     FontWeight.bold,
          //                                                                       //       fontFamily: Font_.Fonts_T,
          //                                                                       //     ),
          //                                                                       //   ),
          //                                                                       // ),
          //                                                                       if (where_ac4_1("6") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].zn == null) ? '' : '${InvoiceModels[index].zn}',
          //                                                                             //'${transMeterModels[index].qty}',
          //                                                                             textAlign: TextAlign.start,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("7") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].ln == null) ? '' : '${InvoiceModels[index].ln}',
          //                                                                             //'${transMeterModels[index].qty}',
          //                                                                             textAlign: TextAlign.start,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("8") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
          //                                                                               ? Container(
          //                                                                                   width: 40,
          //                                                                                   height: 30,
          //                                                                                   color: Colors.red[100],
          //                                                                                 )
          //                                                                               : AutoSizeText(
          //                                                                                   minFontSize: 10,
          //                                                                                   maxFontSize: 16,
          //                                                                                   maxLines: 1,
          //                                                                                   InvoiceModels[index].btype == null ? '' : '${InvoiceModels[index].btype}',
          //                                                                                   //'${transMeterModels[index].qty}',
          //                                                                                   textAlign: TextAlign.center,
          //                                                                                   style: const TextStyle(
          //                                                                                     color: ManageScreen_Color.Colors_Text2_,
          //                                                                                     // fontWeight:
          //                                                                                     //     FontWeight.bold,
          //                                                                                     fontFamily: Font_.Fonts_T,
          //                                                                                   ),
          //                                                                                 ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("9") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].amt_dis == null || InvoiceModels[index].amt_dis.toString() == '') ? '0.00' : '${nFormat.format(double.parse(InvoiceModels[index].amt_dis.toString()))}',
          //                                                                             // '${nFormat.format(double.parse(InvoiceModels[index].total_bill.toString()) - double.parse(InvoiceModels[index].total_dis.toString()))}',
          //                                                                             textAlign: TextAlign.end,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("10") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             //'${InvoiceModels[index].total_bill}',
          //                                                                             (InvoiceModels[index].total_bill == null || InvoiceModels[index].total_bill.toString() == '') ? '0.00' : '${nFormat.format(double.parse(InvoiceModels[index].total_bill.toString()))}',
          //                                                                             textAlign: TextAlign.end,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("11") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].total_dis == null || InvoiceModels[index].total_dis.toString() == '') ? '0.00' : '${nFormat.format(double.parse(InvoiceModels[index].total_dis.toString()))}',
          //                                                                             textAlign: TextAlign.end,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("12") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].refapi == null || InvoiceModels[index].refapi.toString() == '') ? '' : '${InvoiceModels[index].refapi}',
          //                                                                             textAlign: TextAlign.end,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].refapi == null || InvoiceModels[index].refapi.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("13") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].ref1 == null || InvoiceModels[index].ref1.toString() == '') ? '' : '${InvoiceModels[index].ref1}',
          //                                                                             textAlign: TextAlign.end,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].ref1 == null || InvoiceModels[index].ref1.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       if (where_ac4_1("14") == false)
          //                                                                         Expanded(
          //                                                                           flex: 1,
          //                                                                           child: AutoSizeText(
          //                                                                             minFontSize: 10,
          //                                                                             maxFontSize: 16,
          //                                                                             maxLines: 1,
          //                                                                             (InvoiceModels[index].ref2 == null || InvoiceModels[index].ref2.toString() == '') ? '' : '${InvoiceModels[index].ref2}',
          //                                                                             textAlign: TextAlign.end,
          //                                                                             style: TextStyle(
          //                                                                               color: (InvoiceModels[index].ref2 == null || InvoiceModels[index].ref2.toString() == '') ? Colors.red : ManageScreen_Color.Colors_Text2_,
          //                                                                               // fontWeight:
          //                                                                               //     FontWeight.bold,
          //                                                                               fontFamily: Font_.Fonts_T,
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       Padding(
          //                                                                         padding: const EdgeInsets.all(4.0),
          //                                                                         child: InkWell(
          //                                                                           onTap: () async {
          //                                                                             setState(() {
          //                                                                               invoice_select.clear();
          //                                                                             });
          //                                                                             if (invoice_select_delete.length >= 50) {
          //                                                                               setState(() {
          //                                                                                 invoice_select_delete.remove('${InvoiceModels[index].docno}');
          //                                                                               });
          //                                                                               Dialog_notimax(50);
          //                                                                             } else {
          //                                                                               setState(() {
          //                                                                                 if (invoice_select_delete.contains('${InvoiceModels[index].docno}') == true) {
          //                                                                                   invoice_select_delete.remove('${InvoiceModels[index].docno}');
          //                                                                                 } else {
          //                                                                                   invoice_select_delete.add('${InvoiceModels[index].docno}');
          //                                                                                 }
          //                                                                               });
          //                                                                             }
          //                                                                           },
          //                                                                           child: Container(
          //                                                                             decoration: BoxDecoration(
          //                                                                               color: Colors.blueGrey[50]!.withOpacity(0.5),
          //                                                                               borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          //                                                                               border: Border.all(color: Colors.grey, width: 1),
          //                                                                             ),
          //                                                                             width: 70,
          //                                                                             padding: const EdgeInsets.all(2),
          //                                                                             child: Row(
          //                                                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                                                                               children: [
          //                                                                                 (invoice_select_delete.contains('${InvoiceModels[index].docno}') == true) ? Icon(Icons.check_box, color: Colors.red[300]) : const Icon(Icons.check_box_outline_blank, color: Colors.grey),

          //                                                                                 ///invoice_loade_Success
          //                                                                                 Icon(
          //                                                                                   Icons.delete,
          //                                                                                   color: (invoice_loade_Success_delete.contains('${InvoiceModels[index].docno}') == true) ? Colors.red[600] : null,
          //                                                                                 )
          //                                                                               ],
          //                                                                             ),
          //                                                                           ),
          //                                                                         ),
          //                                                                       ),
          //                                                                       Padding(
          //                                                                         padding: const EdgeInsets.all(4.0),
          //                                                                         child: InkWell(
          //                                                                           onTap: () async {
          //                                                                             setState(() {
          //                                                                               bneme_check = InvoiceModels[index].ptname;
          //                                                                               bno_check = InvoiceModels[index].bno;
          //                                                                               bser_check = InvoiceModels[index].ptser;
          //                                                                             });
          //                                                                             red_Trans_selectPay(index).then((value) {
          //                                                                               _showMyDialog_pay(index);
          //                                                                             });
          //                                                                           },
          //                                                                           child: Container(
          //                                                                               width: 60,
          //                                                                               decoration: const BoxDecoration(
          //                                                                                 color: Colors.green,
          //                                                                                 borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          //                                                                               ),
          //                                                                               padding: const EdgeInsets.all(2.0),
          //                                                                               child: Translate.TranslateAndSetText('อนุมัติ', AccountScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 14, 1)

          //                                                                               //  const AutoSizeText(
          //                                                                               //   minFontSize: 10,
          //                                                                               //   maxFontSize: 25,
          //                                                                               //   maxLines: 1,
          //                                                                               //   'อนุมัติ',
          //                                                                               //   textAlign: TextAlign.center,
          //                                                                               //   overflow: TextOverflow.ellipsis,
          //                                                                               //   style: TextStyle(
          //                                                                               //       color: PeopleChaoScreen_Color.Colors_Text2_,
          //                                                                               //       // color: Colors.white,
          //                                                                               //       //fontWeight: FontWeight.bold,
          //                                                                               //       fontFamily: Font_.Fonts_T),
          //                                                                               // ),
          //                                                                               ),
          //                                                                         ),
          //                                                                       ),
          //                                                                       // if (rtser.toString() == '50' || rtser.toString() == '72' || rtser.toString() == '92' || rtser.toString() == '93' || rtser.toString() == '94')
          //                                                                       // Expanded(
          //                                                                       //   flex: 1,
          //                                                                       //   child: Row(
          //                                                                       //     mainAxisAlignment: MainAxisAlignment.end,
          //                                                                       //     children: [
          //                                                                       //       Padding(
          //                                                                       //         padding: const EdgeInsets.all(4.0),
          //                                                                       //         child: InkWell(
          //                                                                       //           onTap: () async {
          //                                                                       //             setState(() {
          //                                                                       //               bneme_check = InvoiceModels[index].ptname;
          //                                                                       //               bno_check = InvoiceModels[index].bno;
          //                                                                       //               bser_check = InvoiceModels[index].ptser;
          //                                                                       //             });
          //                                                                       //             red_Trans_selectPay(index).then((value) {
          //                                                                       //               _showMyDialog_pay(index);
          //                                                                       //             });
          //                                                                       //           },
          //                                                                       //           child: Container(
          //                                                                       //             width: 60,
          //                                                                       //             decoration: const BoxDecoration(
          //                                                                       //               color: Colors.green,
          //                                                                       //               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          //                                                                       //             ),
          //                                                                       //             padding: const EdgeInsets.all(2.0),
          //                                                                       //             child: const AutoSizeText(
          //                                                                       //               minFontSize: 10,
          //                                                                       //               maxFontSize: 25,
          //                                                                       //               maxLines: 1,
          //                                                                       //               'อนุมัติ',
          //                                                                       //               textAlign: TextAlign.center,
          //                                                                       //               overflow: TextOverflow.ellipsis,
          //                                                                       //               style: TextStyle(
          //                                                                       //                    color: PeopleChaoScreen_Color.Colors_Text2_,
          //                                                                       //                   // color: Colors.white,
          //                                                                       //                   //fontWeight: FontWeight.bold,
          //                                                                       //                   fontFamily: Font_.Fonts_T),
          //                                                                       //             ),
          //                                                                       //           ),
          //                                                                       //         ),
          //                                                                       //       ),
          //                                                                       //     ],
          //                                                                       //   ),
          //                                                                       // ),
          //                                                                       Padding(
          //                                                                         padding: const EdgeInsets.all(4.0),
          //                                                                         child: InkWell(
          //                                                                           onTap: () async {
          //                                                                             List newValuePDFimg = [];
          //                                                                             for (int index = 0; index < 1; index++) {
          //                                                                               if (renTalModels[0].imglogo!.trim() == '') {
          //                                                                                 // newValuePDFimg.add(
          //                                                                                 //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
          //                                                                               } else {
          //                                                                                 newValuePDFimg.add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
          //                                                                               }
          //                                                                             }
          //                                                                             var ciddoc = InvoiceModels[index].cid;
          //                                                                             var qutser = '1';
          //                                                                             var tser = InvoiceModels[index].total_dis;
          //                                                                             var docno = InvoiceModels[index].docno;

          //                                                                             setState(() {
          //                                                                               payment_Ptser1 = InvoiceModels[index].ptser;
          //                                                                               payment_Ptname1 = InvoiceModels[index].ptname;
          //                                                                               payment_Bno1 = InvoiceModels[index].bno;

          //                                                                               Datex_invoice = InvoiceModels[index].daterec;

          //                                                                               payment_type1 = InvoiceModels[index].btype;
          //                                                                               payment_bank1 = InvoiceModels[index].bank;
          //                                                                             });
          //                                                                             red_Trans_select(index, ciddoc, qutser, tser, docno, '0');
          //                                                                             // red_Trans_select(index, ciddoc, qutser, tser, docno);
          //                                                                           },
          //                                                                           child: Container(
          //                                                                               width: 80,
          //                                                                               decoration: const BoxDecoration(
          //                                                                                 color: Colors.blue,
          //                                                                                 borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          //                                                                               ),
          //                                                                               padding: const EdgeInsets.all(2.0),
          //                                                                               child: Translate.TranslateAndSetText('เรียกดู', AccountScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 14, 1)
          //                                                                               // const AutoSizeText(
          //                                                                               //   minFontSize: 10,
          //                                                                               //   maxFontSize: 25,
          //                                                                               //   maxLines: 1,
          //                                                                               //   'เรียกดู',
          //                                                                               //   textAlign: TextAlign.center,
          //                                                                               //   overflow: TextOverflow.ellipsis,
          //                                                                               //   style: TextStyle(
          //                                                                               //       color: PeopleChaoScreen_Color.Colors_Text2_,
          //                                                                               //       //fontWeight: FontWeight.bold,
          //                                                                               //       fontFamily: Font_.Fonts_T),
          //                                                                               // ),
          //                                                                               ),
          //                                                                         ),
          //                                                                       ),
          //                                                                       Padding(
          //                                                                         padding: const EdgeInsets.all(4.0),
          //                                                                         child: InvoiceModels[index].ser_noti != null
          //                                                                             ? CircleAvatar(
          //                                                                                 radius: 16,
          //                                                                                 backgroundColor: Colors.yellow.shade900.withOpacity(0.3),
          //                                                                                 child: IconButton(
          //                                                                                   onPressed: () async {
          //                                                                                     PanaraConfirmDialog.showAnimatedGrow(
          //                                                                                       context,
          //                                                                                       title: "Line Notification",
          //                                                                                       message: "แจ้งเตือนชำระค่าบริการผ่านไลน์",
          //                                                                                       confirmButtonText: "Confirm",
          //                                                                                       cancelButtonText: "Cancel",
          //                                                                                       onTapConfirm: () async {
          //                                                                                         if (InvoiceModels[index].ser_noti != null) {
          //                                                                                           var serregis = InvoiceModels[index].ser_noti;
          //                                                                                           var incid = InvoiceModels[index].cid;
          //                                                                                           var indocno = InvoiceModels[index].docno;
          //                                                                                           var insum = nFormat.format(double.parse(InvoiceModels[index].total_dis!));
          //                                                                                           SharedPreferences preferences = await SharedPreferences.getInstance();
          //                                                                                           var ren = preferences.getString('renTalSer');
          //                                                                                           String url = '${MyConstant().domain}/sent_line_noti.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
          //                                                                                           renTal_name = preferences.getString('renTalName');
          //                                                                                           try {
          //                                                                                             var response = await http.get(Uri.parse(url));

          //                                                                                             var result = json.decode(response.body);

          //                                                                                             if (result.toString() == 'Line Successfully') {
          //                                                                                               //print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
          //                                                                                               ScaffoldMessenger.of(context).showSnackBar(
          //                                                                                                 SnackBar(
          //                                                                                                   content: Translate.TranslateAndSetText('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
          //                                                                                                   // Text(
          //                                                                                                   //   'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
          //                                                                                                   //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                                                   // ),
          //                                                                                                 ),
          //                                                                                               );
          //                                                                                             } else {
          //                                                                                               // print('Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)');
          //                                                                                               ScaffoldMessenger.of(context).showSnackBar(
          //                                                                                                 SnackBar(
          //                                                                                                   content: Translate.TranslateAndSetText('Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
          //                                                                                                   // Text(
          //                                                                                                   //   'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
          //                                                                                                   //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                                                   // ),
          //                                                                                                 ),
          //                                                                                               );
          //                                                                                             }
          //                                                                                           } catch (e) {
          //                                                                                             print('Error-Dis(read_GC_rental) : ${e}');
          //                                                                                           }
          //                                                                                         }
          //                                                                                         Navigator.pop(context);
          //                                                                                       },
          //                                                                                       onTapCancel: () {
          //                                                                                         Navigator.pop(context);
          //                                                                                       },
          //                                                                                       panaraDialogType: PanaraDialogType.success,
          //                                                                                     );
          //                                                                                   },
          //                                                                                   icon: Center(
          //                                                                                     child: Icon(
          //                                                                                       Icons.notifications_none,
          //                                                                                       color: Colors.yellow.shade900,
          //                                                                                       size: 18,
          //                                                                                     ),
          //                                                                                   ),
          //                                                                                 ),
          //                                                                               )
          //                                                                             : SizedBox(
          //                                                                                 width: 33,
          //                                                                               ),
          //                                                                       ),
          //                                                                       // Expanded(
          //                                                                       //   flex: 1,
          //                                                                       //   child: Row(
          //                                                                       //     mainAxisAlignment: MainAxisAlignment.end,
          //                                                                       //     children: [
          //                                                                       //       Padding(
          //                                                                       //         padding: const EdgeInsets.all(4.0),
          //                                                                       //         child: InkWell(
          //                                                                       //           onTap: () async {
          //                                                                       //             List newValuePDFimg = [];
          //                                                                       //             for (int index = 0; index < 1; index++) {
          //                                                                       //               if (renTalModels[0].imglogo!.trim() == '') {
          //                                                                       //                 // newValuePDFimg.add(
          //                                                                       //                 //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
          //                                                                       //               } else {
          //                                                                       //                 newValuePDFimg.add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
          //                                                                       //               }
          //                                                                       //             }
          //                                                                       //             var ciddoc = InvoiceModels[index].cid;
          //                                                                       //             var qutser = '1';
          //                                                                       //             var tser = InvoiceModels[index].total_dis;
          //                                                                       //             var docno = InvoiceModels[index].docno;

          //                                                                       //             setState(() {
          //                                                                       //               payment_Ptser1 = InvoiceModels[index].ptser;
          //                                                                       //               payment_Ptname1 = InvoiceModels[index].ptname;
          //                                                                       //               payment_Bno1 = InvoiceModels[index].bno;

          //                                                                       //               Datex_invoice = InvoiceModels[index].daterec;

          //                                                                       //               payment_type1 = InvoiceModels[index].btype;
          //                                                                       //               payment_bank1 = InvoiceModels[index].bank;
          //                                                                       //             });
          //                                                                       //                     red_Trans_select(index, ciddoc, qutser, tser, docno, '0');
          //                                                                       //             // red_Trans_select(index, ciddoc, qutser, tser, docno);
          //                                                                       //           },
          //                                                                       //           child: Container(
          //                                                                       //             width: 80,
          //                                                                       //             decoration: const BoxDecoration(
          //                                                                       //               color: Colors.blue,
          //                                                                       //               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          //                                                                       //             ),
          //                                                                       //             padding: const EdgeInsets.all(2.0),
          //                                                                       //             child: const AutoSizeText(
          //                                                                       //               minFontSize: 10,
          //                                                                       //               maxFontSize: 25,
          //                                                                       //               maxLines: 1,
          //                                                                       //               'เรียกดู',
          //                                                                       //               textAlign: TextAlign.center,
          //                                                                       //               overflow: TextOverflow.ellipsis,
          //                                                                       //               style: TextStyle(
          //                                                                       //                   color: PeopleChaoScreen_Color.Colors_Text2_,
          //                                                                       //                   //fontWeight: FontWeight.bold,
          //                                                                       //                   fontFamily: Font_.Fonts_T),
          //                                                                       //             ),
          //                                                                       //           ),
          //                                                                       //         ),
          //                                                                       //       ),
          //                                                                       //     ],
          //                                                                       //   ),
          //                                                                       // ),
          //                                                                       // Expanded(
          //                                                                       //   flex: 1,
          //                                                                       //   child: Row(
          //                                                                       //     mainAxisAlignment: MainAxisAlignment.center,
          //                                                                       //     children: [
          //                                                                       //       Padding(
          //                                                                       //         padding: const EdgeInsets.all(4.0),
          //                                                                       //         child: InvoiceModels[index].ser_noti != null
          //                                                                       //             ? IconButton(
          //                                                                       //                 onPressed: () async {
          //                                                                       //                   var serregis = _InvoiceModels[index].ser_noti;
          //                                                                       //                   var incid = _InvoiceModels[index].cid;
          //                                                                       //                   var indocno = _InvoiceModels[index].docno;
          //                                                                       //                   var insum = _InvoiceModels[index].total_dis;
          //                                                                       //                   SharedPreferences preferences = await SharedPreferences.getInstance();
          //                                                                       //                   var ren = preferences.getString('renTalSer');
          //                                                                       //                   String url = '${MyConstant().domain}/sent_line_noti.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
          //                                                                       //                   renTal_name = preferences.getString('renTalName');
          //                                                                       //                   try {
          //                                                                       //                     var response = await http.get(Uri.parse(url));

          //                                                                       //                     var result = json.decode(response.body);

          //                                                                       //                     if (result.toString() == 'Line Successfully') {
          //                                                                       //                       print('Line Successfully');
          //                                                                       //                       ScaffoldMessenger.of(context).showSnackBar(
          //                                                                       //                         SnackBar(
          //                                                                       //                           content: Text(
          //                                                                       //                             'Line Successfully',
          //                                                                       //                             style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                       //                           ),
          //                                                                       //                         ),
          //                                                                       //                       );
          //                                                                       //                     } else {
          //                                                                       //                       print('Line No Successfully');
          //                                                                       //                       ScaffoldMessenger.of(context).showSnackBar(
          //                                                                       //                         SnackBar(
          //                                                                       //                           content: Text(
          //                                                                       //                             'Line No Successfully',
          //                                                                       //                             style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
          //                                                                       //                           ),
          //                                                                       //                         ),
          //                                                                       //                       );
          //                                                                       //                     }
          //                                                                       //                   } catch (e) {
          //                                                                       //                     print('Error-Dis(read_GC_rental) : ${e}');
          //                                                                       //                   }
          //                                                                       //                 },
          //                                                                       //                 icon: Icon(
          //                                                                       //                   Icons.notifications_none,
          //                                                                       //                   color: Colors.yellow.shade900,
          //                                                                       //                 ),
          //                                                                       //               )
          //                                                                       //             : SizedBox(),
          //                                                                       //       ),
          //                                                                       //     ],
          //                                                                       //   ),
          //                                                                       // ),
          //                                                                     ],
          //                                                                   ),
          //                                                                 )),
          //                                                               ),
          //                                                             ),
          //                                                             if (index + 1 ==
          //                                                                     InvoiceModels
          //                                                                         .length &&
          //                                                                 InvoiceModels.length !=
          //                                                                     0)
          //                                                               Padding(
          //                                                                 padding:
          //                                                                     const EdgeInsets.all(8.0),
          //                                                                 child:
          //                                                                     Row(
          //                                                                   children: [
          //                                                                     const AutoSizeText(
          //                                                                       minFontSize: 10,
          //                                                                       maxFontSize: 25,
          //                                                                       maxLines: 1,
          //                                                                       '<<- End ',
          //                                                                       textAlign: TextAlign.center,
          //                                                                       style: TextStyle(color: tappedIndex_Color.End_Colors, fontFamily: Font_.Fonts_T),
          //                                                                     ),
          //                                                                     Expanded(
          //                                                                       child: Container(
          //                                                                         decoration: BoxDecoration(
          //                                                                           // color: Colors
          //                                                                           //     .orange,
          //                                                                           border: Border.all(color: tappedIndex_Color.End_Colors, width: 1),
          //                                                                         ),
          //                                                                         height: 1,
          //                                                                       ),
          //                                                                     ),
          //                                                                     const AutoSizeText(
          //                                                                       minFontSize: 10,
          //                                                                       maxFontSize: 25,
          //                                                                       maxLines: 1,
          //                                                                       ' End ->>',
          //                                                                       textAlign: TextAlign.center,
          //                                                                       style: TextStyle(color: tappedIndex_Color.End_Colors, fontFamily: Font_.Fonts_T),
          //                                                                     ),
          //                                                                   ],
          //                                                                 ),
          //                                                               ),
          //                                                           ],
          //                                                         );
          //                                                       })),
          //                                         ],
          //                                       ),
          //                                     ),
          //                                   ],
          //                                 ),
          //                               ),
          //                             ),
          //                             Container(
          //                                 width: (Responsive.isDesktop(context))
          //                                     ? MediaQuery.of(context)
          //                                             .size
          //                                             .width *
          //                                         0.85
          //                                     : MediaQuery.of(context)
          //                                         .size
          //                                         .width,
          //                                 decoration: const BoxDecoration(
          //                                   color: AppbackgroundColor
          //                                       .Sub_Abg_Colors,
          //                                   borderRadius: BorderRadius.only(
          //                                       topLeft: Radius.circular(0),
          //                                       topRight: Radius.circular(0),
          //                                       bottomLeft: Radius.circular(10),
          //                                       bottomRight:
          //                                           Radius.circular(10)),
          //                                 ),
          //                                 child: Row(
          //                                   mainAxisAlignment:
          //                                       MainAxisAlignment.spaceBetween,
          //                                   children: [
          //                                     Align(
          //                                       alignment: Alignment.centerLeft,
          //                                       child: Row(
          //                                         children: [
          //                                           Padding(
          //                                             padding:
          //                                                 const EdgeInsets.all(
          //                                                     8.0),
          //                                             child: InkWell(
          //                                               onTap: () {
          //                                                 _scrollController2
          //                                                     .animateTo(
          //                                                   0,
          //                                                   duration:
          //                                                       const Duration(
          //                                                           seconds: 1),
          //                                                   curve:
          //                                                       Curves.easeOut,
          //                                                 );
          //                                               },
          //                                               child: Container(
          //                                                   decoration:
          //                                                       BoxDecoration(
          //                                                     // color: AppbackgroundColor
          //                                                     //     .TiTile_Colors,
          //                                                     borderRadius: const BorderRadius
          //                                                             .only(
          //                                                         topLeft: Radius
          //                                                             .circular(
          //                                                                 6),
          //                                                         topRight: Radius
          //                                                             .circular(
          //                                                                 6),
          //                                                         bottomLeft: Radius
          //                                                             .circular(
          //                                                                 6),
          //                                                         bottomRight: Radius
          //                                                             .circular(
          //                                                                 8)),
          //                                                     border: Border.all(
          //                                                         color: Colors
          //                                                             .grey,
          //                                                         width: 1),
          //                                                   ),
          //                                                   padding:
          //                                                       const EdgeInsets
          //                                                           .all(3.0),
          //                                                   child: const Text(
          //                                                     'Top',
          //                                                     style: TextStyle(
          //                                                       color:
          //                                                           Colors.grey,
          //                                                       fontSize: 10.0,
          //                                                       fontWeight:
          //                                                           FontWeight
          //                                                               .bold,
          //                                                     ),
          //                                                   )),
          //                                             ),
          //                                           ),
          //                                           InkWell(
          //                                             onTap: () {
          //                                               if (_scrollController2
          //                                                   .hasClients) {
          //                                                 final position =
          //                                                     _scrollController2
          //                                                         .position
          //                                                         .maxScrollExtent;
          //                                                 _scrollController2
          //                                                     .animateTo(
          //                                                   position,
          //                                                   duration:
          //                                                       const Duration(
          //                                                           seconds: 1),
          //                                                   curve:
          //                                                       Curves.easeOut,
          //                                                 );
          //                                               }
          //                                             },
          //                                             child: Container(
          //                                                 decoration:
          //                                                     BoxDecoration(
          //                                                   // color: AppbackgroundColor
          //                                                   //     .TiTile_Colors,
          //                                                   borderRadius: const BorderRadius
          //                                                           .only(
          //                                                       topLeft: Radius
          //                                                           .circular(
          //                                                               6),
          //                                                       topRight: Radius
          //                                                           .circular(
          //                                                               6),
          //                                                       bottomLeft: Radius
          //                                                           .circular(
          //                                                               6),
          //                                                       bottomRight:
          //                                                           Radius
          //                                                               .circular(
          //                                                                   6)),
          //                                                   border: Border.all(
          //                                                       color:
          //                                                           Colors.grey,
          //                                                       width: 1),
          //                                                 ),
          //                                                 padding:
          //                                                     const EdgeInsets
          //                                                         .all(3.0),
          //                                                 child: const Text(
          //                                                   'Down',
          //                                                   style: TextStyle(
          //                                                     color:
          //                                                         Colors.grey,
          //                                                     fontSize: 10.0,
          //                                                     fontWeight:
          //                                                         FontWeight
          //                                                             .bold,
          //                                                   ),
          //                                                 )),
          //                                           ),
          //                                         ],
          //                                       ),
          //                                     ),
          //                                     Align(
          //                                       alignment:
          //                                           Alignment.centerRight,
          //                                       child: Row(
          //                                         children: [
          //                                           InkWell(
          //                                             onTap: _moveUp2,
          //                                             child: const Padding(
          //                                                 padding:
          //                                                     EdgeInsets.all(
          //                                                         8.0),
          //                                                 child: Align(
          //                                                   alignment: Alignment
          //                                                       .centerLeft,
          //                                                   child: Icon(
          //                                                     Icons
          //                                                         .arrow_upward,
          //                                                     color:
          //                                                         Colors.grey,
          //                                                   ),
          //                                                 )),
          //                                           ),
          //                                           Container(
          //                                               decoration:
          //                                                   BoxDecoration(
          //                                                 // color: AppbackgroundColor
          //                                                 //     .TiTile_Colors,
          //                                                 borderRadius: const BorderRadius
          //                                                         .only(
          //                                                     topLeft: Radius
          //                                                         .circular(6),
          //                                                     topRight: Radius
          //                                                         .circular(6),
          //                                                     bottomLeft: Radius
          //                                                         .circular(6),
          //                                                     bottomRight:
          //                                                         Radius
          //                                                             .circular(
          //                                                                 6)),
          //                                                 border: Border.all(
          //                                                     color:
          //                                                         Colors.grey,
          //                                                     width: 1),
          //                                               ),
          //                                               padding:
          //                                                   const EdgeInsets
          //                                                       .all(3.0),
          //                                               child: const Text(
          //                                                 'Scroll',
          //                                                 style: TextStyle(
          //                                                   color: Colors.grey,
          //                                                   fontSize: 10.0,
          //                                                   fontWeight:
          //                                                       FontWeight.bold,
          //                                                 ),
          //                                               )),
          //                                           InkWell(
          //                                             onTap: _moveDown2,
          //                                             child: const Padding(
          //                                                 padding:
          //                                                     EdgeInsets.all(
          //                                                         8.0),
          //                                                 child: Align(
          //                                                   alignment: Alignment
          //                                                       .centerRight,
          //                                                   child: Icon(
          //                                                     Icons
          //                                                         .arrow_downward,
          //                                                     color:
          //                                                         Colors.grey,
          //                                                   ),
          //                                                 )),
          //                                           ),
          //                                         ],
          //                                       ),
          //                                     )
          //                                   ],
          //                                 )),
          //                           ],
          //                         )),
          //                   ],
          //                 ),
          //               ),
          //               const SizedBox(
          //                 height: 20,
          //               )
          //             ],
          //           ),
          //         ),
      ],
    );
  }

////////////////////////--------------------------------------->
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

  ////////////////////////--------------------------------------->
  Widget bill_pay() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Column(
        children: [
          Container(
            width: (Responsive.isDesktop(context))
                ? MediaQuery.of(context).size.width * 0.88
                : 1200,
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
                        ? MediaQuery.of(context).size.width * 0.88
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
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9
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
                                                                            0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        0),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            0)),
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

                                                          items: ac4_3
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
                                                                      int selectedIndex = ac4_3.indexWhere((items) =>
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
                                                                          ac4_3[selectedIndex]["st"] =
                                                                              '0';
                                                                        } else {
                                                                          ac4_3[selectedIndex]["st"] =
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
                                                      child: Next_page())
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
                                                                'เดือนที่ครบกำหนด :',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
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
                                                            // Text(
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
                                                                  //  Text(
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

                                                            onChanged:
                                                                (value) async {
                                                              MONTH_Now = value;
                                                              red_InvoiceMon_billPay();
                                                              // red_InvoiceMon_bill();

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
                                                                'ปีที่ครบกำหนด :',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),

                                                        // Text(
                                                        //   'ปีที่ครบกำหนด :',
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
                                                              red_InvoiceMon_billPay();
                                                              // red_InvoiceMon_bill();

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
                                                                'เรียงจาก :',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
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
                                                            hint: Translate
                                                                .TranslateAndSetText(
                                                                    'แจ้งที่ใบแจ้งหนี้',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),

                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              // Icons.sort_rounded,
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
                                                            buttonWidth: 160,
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
                                                                    'แจ้งที่ใบแจ้งหนี้',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '1',
                                                                child: Translate.TranslateAndSetText(
                                                                    'เลขที่สัญญา',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '2',
                                                                child: Translate.TranslateAndSetText(
                                                                    'วันที่ออกใบ',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: '3',
                                                                child: Translate.TranslateAndSetText(
                                                                    'วันที่ครบกำหนด',
                                                                    Colors.grey,
                                                                    TextAlign
                                                                        .start,
                                                                    null,
                                                                    Font_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1),
                                                              ),
                                                            ],

                                                            onChanged:
                                                                (value) async {
                                                              if (value
                                                                      .toString() ==
                                                                  '0') {
                                                                limitedList_InvoiceModels_
                                                                    .sort((a, b) => b
                                                                        .docno!
                                                                        .compareTo(
                                                                            a.docno!));
                                                              } else if (value
                                                                      .toString() ==
                                                                  '1') {
                                                                limitedList_InvoiceModels_
                                                                    .sort((a, b) => b
                                                                        .cid!
                                                                        .compareTo(
                                                                            a.cid!));
                                                              } else if (value
                                                                      .toString() ==
                                                                  '2') {
                                                                //DateFormat('dd-MM').format(DateTime.parse('${InvoiceModels[index].daterec}'))
                                                                limitedList_InvoiceModels_.sort((a, b) => DateTime
                                                                        .parse(b
                                                                            .daterec!)
                                                                    .compareTo(DateTime
                                                                        .parse(a
                                                                            .daterec!)));
                                                                // InvoiceModels.sort((a, b) => b.daterec!.compareTo(a.daterec!));
                                                              } else if (value
                                                                      .toString() ==
                                                                  '3') {
                                                                limitedList_InvoiceModels_.sort((a, b) => DateTime
                                                                        .parse(b
                                                                            .date!)
                                                                    .compareTo(DateTime
                                                                        .parse(a
                                                                            .date!)));
                                                                // InvoiceModels.sort((a, b) => b.date!.compareTo(a.date!));
                                                              } else {
                                                                limitedList_InvoiceModels_
                                                                    .sort((a, b) => b
                                                                        .docno!
                                                                        .compareTo(
                                                                            a.docno!));
                                                              }
                                                              //  limitedList_InvoiceModels_
                                                              setState(() {
                                                                _InvoiceModels =
                                                                    limitedList_InvoiceModels_;
                                                              });
                                                              read_Invoice_limit();
                                                              // print(value);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      // if (InvoiceModels
                                                      //         .length !=
                                                      //     0)
                                                      //   Container(
                                                      //       padding:
                                                      //           const EdgeInsets.all(
                                                      //               8.0),
                                                      //       // width: 130,
                                                      //       child:
                                                      //           Next_page_Save())
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: SizedBox(
                                                      // child: Next_page(),
                                                      ),
                                                )
                                              ],
                                            ),
                                            const Divider(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  flex: 12,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: ac4_3
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
                                                                        '9' ||
                                                                    item["ser"] ==
                                                                        '11')
                                                                ? TextAlign
                                                                    .center
                                                                : (item["ser"] == '8' ||
                                                                        item["ser"] ==
                                                                            '12' ||
                                                                        item["ser"] ==
                                                                            '13')
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
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'เลขสัญญา',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.start,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'เลขที่ใบแจ้งหนี้',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.start,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // // Expanded(
                                                // //   flex: 1,
                                                // //   child: Text(
                                                // //     'สถานะ',
                                                // //     textAlign: TextAlign.start,
                                                // //     style: TextStyle(
                                                // //       color: ManageScreen_Color
                                                // //           .Colors_Text1_,
                                                // //       fontWeight: FontWeight.bold,
                                                // //       fontFamily: FontWeight_.Fonts_T,
                                                // //     ),
                                                // //   ),
                                                // // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'วันที่ออกใบแจ้งหนี้',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.start,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'ครบกำหนดชำระ',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.start,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),

                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'ชื่อร้านค้า',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.start,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // // Expanded(
                                                // //   flex: 2,
                                                // //   child: Text(
                                                // //     'รอบการเช่า',
                                                // //     textAlign: TextAlign.start,
                                                // //     style: TextStyle(
                                                // //       color: ManageScreen_Color
                                                // //           .Colors_Text1_,
                                                // //       fontWeight: FontWeight.bold,
                                                // //       fontFamily: FontWeight_.Fonts_T,
                                                // //     ),
                                                // //   ),
                                                // // ),

                                                // const Expanded(
                                                //   flex: 1,
                                                //   child: Text(
                                                //     'รหัสพื้นที่',
                                                //     textAlign: TextAlign.start,
                                                //     style: TextStyle(
                                                //       color: ManageScreen_Color
                                                //           .Colors_Text1_,
                                                //       fontWeight:
                                                //           FontWeight.bold,
                                                //       fontFamily:
                                                //           FontWeight_.Fonts_T,
                                                //     ),
                                                //   ),
                                                // ),

                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'ยอดสุทธิ(วางบิล)',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.end,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'วันที่ชำระ',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.center,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // Expanded(
                                                //   flex: 2,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'เลขที่ใบเสร็จรับชำระ',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.start,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'สถานะ',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.start,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           14,
                                                //           1),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'ค่าปรับ(รับชำระ)',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.end,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           13,
                                                //           1),
                                                // ),
                                                // Expanded(
                                                //   flex: 1,
                                                //   child: Translate
                                                //       .TranslateAndSetText(
                                                //           'ยอดสุทธิ(รับชำระ)',
                                                //           AccountScreen_Color
                                                //               .Colors_Text1_,
                                                //           TextAlign.end,
                                                //           FontWeight.bold,
                                                //           FontWeight_.Fonts_T,
                                                //           13,
                                                //           1),
                                                // ),
                                                Container(
                                                  width: 120,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.63,
                                          width: Responsive.isDesktop(context)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.9
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
                                                                ? Translate.TranslateAndSetText(
                                                                    'ไม่พบข้อมูล',
                                                                    AccountScreen_Color
                                                                        .Colors_Text1_,
                                                                    TextAlign
                                                                        .center,
                                                                    FontWeight
                                                                        .bold,
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                    14,
                                                                    1)
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
                                                      InvoiceModels.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Column(
                                                      children: [
                                                        Material(
                                                          // color:
                                                          //(InvoiceModels[index].btype ==
                                                          //             null ||
                                                          //         InvoiceModels[index].btype.toString() ==
                                                          //             '')
                                                          //     ? Colors
                                                          //         .red[
                                                          //             50]!
                                                          //         .withOpacity(
                                                          //             0.4)
                                                          //     : AppbackgroundColor
                                                          //         .Sub_Abg_Colors,
                                                          child: Container(
                                                            child: ListTile(
                                                                // onTap:
                                                                //     () async {
                                                                //   setState(() {
                                                                //     tappedIndex_ =
                                                                //         '${index}';
                                                                //   });
                                                                // },
                                                                title:
                                                                    Container(
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
                                                                  if (where_ac4_3(
                                                                          "0") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
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
                                                                  if (where_ac4_3(
                                                                          "1") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Copy_Text(
                                                                              context,
                                                                              '${InvoiceModels[index].inv}'),
                                                                          Expanded(
                                                                            child:
                                                                                AutoSizeText(
                                                                              minFontSize: 10,
                                                                              maxFontSize: 25,
                                                                              maxLines: 1,
                                                                              (InvoiceModels[index].inv == null) ? '-' : '${InvoiceModels[index].inv}',
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
                                                                  //   flex: 1,
                                                                  //   child:
                                                                  //       AutoSizeText(
                                                                  //     minFontSize:
                                                                  //         10,
                                                                  //     maxFontSize:
                                                                  //         25,
                                                                  //     maxLines:
                                                                  //         1,
                                                                  //     '${InvoiceModels[index].inv}',
                                                                  //     textAlign:
                                                                  //         TextAlign
                                                                  //             .start,
                                                                  //     overflow:
                                                                  //         TextOverflow
                                                                  //             .ellipsis,
                                                                  //     style:
                                                                  //         TextStyle(
                                                                  //       color: (InvoiceModels[index].btype == null ||
                                                                  //               InvoiceModels[index].btype.toString() == '')
                                                                  //           ? Colors.red
                                                                  //           : ManageScreen_Color.Colors_Text2_,
                                                                  //       // fontWeight: FontWeight.bold,
                                                                  //       fontFamily:
                                                                  //           Font_.Fonts_T,
                                                                  //       //fontSize: 10.0
                                                                  //     ),
                                                                  //   ),
                                                                  // ),
                                                                  if (where_ac4_3(
                                                                          "2") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
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
                                                                  if (where_ac4_3(
                                                                          "3") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
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
                                                                  if (where_ac4_3(
                                                                          "4") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].cname ==
                                                                                null)
                                                                            ? '-'
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
                                                                  if (where_ac4_3(
                                                                          "5") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].scname ==
                                                                                null)
                                                                            ? '-'
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
                                                                  if (where_ac4_3(
                                                                          "6") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].zn ==
                                                                                null)
                                                                            ? '-'
                                                                            : '${InvoiceModels[index].zn}',
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
                                                                  if (where_ac4_3(
                                                                          "7") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].ln ==
                                                                                null)
                                                                            ? '-'
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
                                                                  if (where_ac4_3(
                                                                          "8") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].total_dis == null ||
                                                                                InvoiceModels[index].total_dis.toString() == '')
                                                                            ? ''
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
                                                                  if (where_ac4_3(
                                                                          "9") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].pdate == null ||
                                                                                InvoiceModels[index].pdate.toString() == '')
                                                                            ? ''
                                                                            : '${InvoiceModels[index].pdate}',
                                                                        //'${DateFormat('dd-MM-yyyy').format(DateTime.parse('${InvoiceModels[index].daterec}'))}',
                                                                        textAlign:
                                                                            TextAlign.center,

                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : (InvoiceModels[index].pos == '1')
                                                                                  ? Colors.orange
                                                                                  : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          // fontSize: 12.0
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac4_3(
                                                                          "10") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].doctax == null ||
                                                                                InvoiceModels[index].doctax! == '')
                                                                            ? '${InvoiceModels[index].docno}'
                                                                            : '${InvoiceModels[index].doctax}',
                                                                        //'${transMeterModels[index].qty}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : (InvoiceModels[index].pos == '1')
                                                                                  ? Colors.orange
                                                                                  : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac4_3(
                                                                          "11") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].pos ==
                                                                                '1')
                                                                            ? 'รอตรวจสอบ'
                                                                            : 'ชำระแล้ว',
                                                                        //'${transMeterModels[index].qty}',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].pos == '1')
                                                                              ? Colors.orange
                                                                              : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac4_3(
                                                                          "12") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].pay_fine == null ||
                                                                                InvoiceModels[index].pay_fine.toString() == '')
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(InvoiceModels[index].pay_fine.toString()))}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : (InvoiceModels[index].pos == '1')
                                                                                  ? Colors.orange
                                                                                  : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (where_ac4_3(
                                                                          "13") ==
                                                                      false)
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            25,
                                                                        maxLines:
                                                                            1,
                                                                        (InvoiceModels[index].paytotal_dis == null ||
                                                                                InvoiceModels[index].paytotal_dis.toString() == '')
                                                                            ? '0.00'
                                                                            : '${nFormat.format(double.parse(InvoiceModels[index].paytotal_dis.toString()))}',
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        style:
                                                                            TextStyle(
                                                                          color: (InvoiceModels[index].btype == null || InvoiceModels[index].btype.toString() == '')
                                                                              ? Colors.red
                                                                              : (InvoiceModels[index].pos == '1')
                                                                                  ? Colors.orange
                                                                                  : ManageScreen_Color.Colors_Text2_,
                                                                          // fontWeight:
                                                                          //     FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(4.0),
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              List newValuePDFimg = [];
                                                                              for (int index = 0; index < 1; index++) {
                                                                                if (renTalModels[0].imglogo!.trim() == '') {
                                                                                  // newValuePDFimg.add(
                                                                                  //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                                                                } else {
                                                                                  newValuePDFimg.add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                                                }
                                                                              }
                                                                              var ciddoc = InvoiceModels[index].cid;
                                                                              var qutser = '1';
                                                                              var tser = InvoiceModels[index].total_dis;
                                                                              var docno = InvoiceModels[index].inv;

                                                                              setState(() {
                                                                                payment_Ptser1 = InvoiceModels[index].ptser;
                                                                                payment_Ptname1 = InvoiceModels[index].ptname;
                                                                                payment_Bno1 = InvoiceModels[index].bno;

                                                                                Datex_invoice = InvoiceModels[index].daterec;

                                                                                payment_type1 = InvoiceModels[index].btype;
                                                                                payment_bank1 = InvoiceModels[index].bank;
                                                                              });
                                                                              red_Trans_select(index, ciddoc, qutser, tser, docno, '2');
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              width: 80,
                                                                              decoration: const BoxDecoration(
                                                                                color: Colors.green,
                                                                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                              ),
                                                                              padding: const EdgeInsets.all(2.0),
                                                                              child: Translate.TranslateAndSetText('เรียกดู', AccountScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 14, 1),

                                                                              // const AutoSizeText(
                                                                              //   minFontSize: 10,
                                                                              //   maxFontSize: 25,
                                                                              //   maxLines: 1,
                                                                              //   'เรียกดู',
                                                                              //   textAlign: TextAlign.center,
                                                                              //   overflow: TextOverflow.ellipsis,
                                                                              //   style: TextStyle(
                                                                              //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //       //fontWeight: FontWeight.bold,
                                                                              //       fontFamily: Font_.Fonts_T),
                                                                              // ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
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
                                                                const AutoSizeText(
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
                                                                const AutoSizeText(
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

  ///--------------------------------------------------------->
  Future<Null> read_GC_Line(index) async {
    if (regis_models.isNotEmpty) {
      setState(() {
        regis_models.clear();
      });
    }
    var custno = _InvoiceModels[index].custno;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_line_regis.php?isAdd=true&ren=$ren&custno=$custno';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result != null) {
        for (var map in result) {
          Regis_model regis_model = Regis_model.fromJson(map);
          setState(() {
            if (regis_model.userid != '') {
              regis_models.add(regis_model);
            }
          });
        }
      } else {}
    } catch (e) {
      print('Error-Dis(read_GC_rental) : ${e}');
    }
    // print('name>>>>>  $renname');
  }

  ///---------------------------------------------------------------------->
  Future<Null> checkshowDialog(index, docno, page) async {
    int selectedIndex = (page.toString() == '0')
        ? InvoiceModels.indexWhere(
            (item) => item.docno.toString() == docno.toString())
        : InvoiceModels.indexWhere(
            (item) => item.inv.toString() == docno.toString());
    try {
      setState(() {
        read_GC_Line(selectedIndex);
      });
    } catch (e) {}
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
                                              'รายละเอียดบิล ',
                                              AccountScreen_Color.Colors_Text1_,
                                              TextAlign.center,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
                                              1),

                                          // AutoSizeText(
                                          //   minFontSize: 8,
                                          //   maxFontSize: 14,
                                          //   'รายละเอียดบิล ', //numinvoice
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
                                          child: Center(
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'บิลเลขที่ ${docno} ',
                                                    AccountScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                            //  AutoSizeText(
                                            //   minFontSize: 8,
                                            //   maxFontSize: 12,
                                            //   'บิลเลขที่ ${docno} ',
                                            //   textAlign: TextAlign.center,
                                            //   style: const TextStyle(
                                            //       color: PeopleChaoScreen_Color
                                            //           .Colors_Text1_,
                                            //       fontWeight: FontWeight.bold,
                                            //       fontFamily:
                                            //           FontWeight_.Fonts_T
                                            //       //fontSize: 10.0
                                            //       //fontSize: 10.0
                                            //       ),
                                            // ),
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
                                      Expanded(
                                        flex: 1,
                                        child: Translate.TranslateAndSetText(
                                            'ส่วนลด',
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
                                                                null)
                                                            ? '-'
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
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .ln ==
                                                                null)
                                                            ? ''
                                                            : '${_InvoiceHistoryModels[index].ln}',
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
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        double.parse(_InvoiceHistoryModels[
                                                                        index]
                                                                    .tf!) ==
                                                                0.00
                                                            ? (_InvoiceHistoryModels[
                                                                            index]
                                                                        .qty ==
                                                                    null)
                                                                ? '0.00'
                                                                : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].qty!))}'
                                                            : 'ก่อน[Before]-หลัง[After] (${int.parse((_InvoiceHistoryModels[index].ovalue == null) ? '0' : _InvoiceHistoryModels[index].ovalue!)} - ${int.parse((_InvoiceHistoryModels[index].nvalue == null) ? '0' : _InvoiceHistoryModels[index].nvalue!)}) ${double.parse((_InvoiceHistoryModels[index].qty == null) ? '0' : _InvoiceHistoryModels[index].qty!)}',
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
                                                        double.parse(_InvoiceHistoryModels[
                                                                        index]
                                                                    .tf!) !=
                                                                0.00
                                                            ? '${nFormat.format(double.parse((_InvoiceHistoryModels[index].pri == null) ? '0' : _InvoiceHistoryModels[index].pri!))} (tf ${nFormat.format((double.parse((_InvoiceHistoryModels[index].amt == null) ? '0' : _InvoiceHistoryModels[index].amt!) - (double.parse((_InvoiceHistoryModels[index].vat == null) ? '0' : _InvoiceHistoryModels[index].vat!) + double.parse((_InvoiceHistoryModels[index].pvat == null) ? '0' : _InvoiceHistoryModels[index].pvat!))))})'
                                                            : (_InvoiceHistoryModels[
                                                                            index]
                                                                        .nvat ==
                                                                    null)
                                                                ? '0.00'
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
                                                            ? '0.00'
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
                                                            ? '0.00'
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
                                                    Expanded(
                                                      flex: 1,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (_InvoiceHistoryModels[
                                                                        index]
                                                                    .dis ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].dis!))}',
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
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(_InvoiceHistoryModels[index].total_t!) - double.parse(_InvoiceHistoryModels[index].dis!))}',
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
                                            width: 400,
                                            decoration: BoxDecoration(
                                              color: AppbackgroundColor
                                                  .Sub_Abg_Colors,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10)),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 6,
                                                  child: Column(
                                                    children: [
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Translate.TranslateAndSetText(
                                                            (Datex_invoice ==
                                                                    null)
                                                                ? 'วันที่ออกใบแจ้งหนี้/วางบิล : -'
                                                                : 'วันที่ออกใบแจ้งหนี้/วางบิล : ${DateFormat('dd-MM').format(DateTime.parse('${Datex_invoice}'))}-${DateTime.parse('${Datex_invoice}').year + 0}',
                                                            AccountScreen_Color
                                                                .Colors_Text1_,
                                                            TextAlign.end,
                                                            FontWeight.bold,
                                                            FontWeight_.Fonts_T,
                                                            14,
                                                            1),

                                                        // AutoSizeText(
                                                        //   minFontSize: 8,
                                                        //   maxFontSize: 13,
                                                        //   'วันที่ออกใบแจ้งหนี้/วางบิล : ${DateFormat('dd-MM').format(DateTime.parse('${Datex_invoice}'))}-${DateTime.parse('${Datex_invoice}').year + 543}',
                                                        //   textAlign:
                                                        //       TextAlign.end,
                                                        //   style: const TextStyle(
                                                        //       color: PeopleChaoScreen_Color.Colors_Text1_,
                                                        //       // fontWeight:
                                                        //       //     FontWeight
                                                        //       //         .bold,
                                                        //       fontFamily: Font_.Fonts_T
                                                        //       //fontSize: 10.0
                                                        //       ),
                                                        // ),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'รูปแบบชำระ : ',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.end,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                        //     const AutoSizeText(
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
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Translate.TranslateAndSetText(
                                                                '1. จำนวน ${nFormat.format(sum_amt - sum_disamt)} บาท (${payment_Ptname1})',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.start,
                                                                null,
                                                                Font_.Fonts_T,
                                                                12,
                                                                1),
                                                            // AutoSizeText(
                                                            //   minFontSize:
                                                            //       8,
                                                            //   maxFontSize:
                                                            //       13,
                                                            //   '1. จำนวน ${nFormat.format(sum_amt - sum_disamt)} บาท (${payment_Ptname1})',
                                                            //   style: const TextStyle(
                                                            //       color: PeopleChaoScreen_Color
                                                            //           .Colors_Text2_,
                                                            //       fontWeight:
                                                            //           FontWeight
                                                            //               .w500,
                                                            //       fontFamily:
                                                            //           Font_
                                                            //               .Fonts_T),
                                                            // ),
                                                            if (payment_Ptname1
                                                                        .toString() !=
                                                                    'CASH' ||
                                                                payment_Ptname1
                                                                        .toString() !=
                                                                    'null')
                                                              Translate.TranslateAndSetText(
                                                                  '  ** 1.1. ธนาคาร : ${payment_bank1} , เลขบช. : ${payment_Bno1}',
                                                                  AccountScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .start,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  12,
                                                                  1),
                                                            // AutoSizeText(
                                                            //   minFontSize:
                                                            //       8,
                                                            //   maxFontSize:
                                                            //       11,
                                                            //   '  ** 1.1. ธนาคาร : ${payment_bank1} , เลขบช. : ${payment_Bno1}',
                                                            //   style: TextStyle(
                                                            //       color: Colors.grey[800],
                                                            //       //fontWeight: FontWeight.bold,
                                                            //       fontFamily: Font_.Fonts_T),
                                                            // ),
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
                                                // payment_Ptser1 == '8'
                                                //     ? Expanded(
                                                //         flex: 2,
                                                //         child: IconButton(
                                                //             onPressed: () {
                                                //               showdialog_ComingQR(
                                                //                   index);
                                                //             },
                                                //             icon: Icon(
                                                //               Icons
                                                //                   .qr_code_sharp,
                                                //               size: 50,
                                                //             )))
                                                //     : SizedBox()
                                              ],
                                            )),
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
                    ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        }),
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                                padding: const EdgeInsets.all(8.0),
                                width: (Responsive.isDesktop(context))
                                    ? MediaQuery.of(context).size.width * 0.85
                                    : MediaQuery.of(context).size.width,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InvoiceModels[index].refapi == ''
                                          ? SizedBox()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple[400],
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: const Radius
                                                              .circular(10),
                                                          topRight: Radius
                                                              .circular(10),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10)),
                                                  // border: Border.all(color: Colors.white, width: 1),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    Gen_QRAPINEW(index);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Translate
                                                          .TranslateAndSetText(
                                                              'Show QR',
                                                              Colors.white,
                                                              TextAlign.start,
                                                              FontWeight.bold,
                                                              FontWeight_
                                                                  .Fonts_T,
                                                              14,
                                                              1),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Icon(
                                                        Icons.qr_code,
                                                        color: Colors.white,
                                                        size: 22,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: (Cancell_bill.toString() ==
                                                  '1')
                                              ? null
                                              : (DateTime.parse(
                                                              '${InvoiceModels[index].daterec} 00:00:00')
                                                          .add(Duration(
                                                              days: int.parse(
                                                                  '${Day_Cancell_bill}')))
                                                          .isBefore(datex) &&
                                                      Day_Cancell_bill
                                                              .toString() !=
                                                          '0')
                                                  ? null
                                                  : () {
                                                      if (numinvoice != null) {
                                                        showDialog<String>(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AlertDialog(
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            20.0))),
                                                            title: Center(
                                                              child: Translate.TranslateAndSetText(
                                                                  'ยืนยันการยกเลิกวางบิล',
                                                                  AccountScreen_Color
                                                                      .Colors_Text1_,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                              //             Text(
                                                              //   'ยืนยันการยกเลิกวางบิล',
                                                              //   style:
                                                              //       TextStyle(
                                                              //     color: PeopleChaoScreen_Color
                                                              //         .Colors_Text1_,
                                                              //     // fontWeight: FontWeight.bold,
                                                              //     fontFamily:
                                                              //         FontWeight_
                                                              //             .Fonts_T,
                                                              //     fontWeight:
                                                              //         FontWeight
                                                              //             .bold,
                                                              //   ),
                                                              // )
                                                            ),
                                                            content:
                                                                SingleChildScrollView(
                                                              child: Container(
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                          child: Translate.TranslateAndSetText(
                                                                              'เลขที่ใบเสร็จ',
                                                                              AccountScreen_Color.Colors_Text1_,
                                                                              TextAlign.center,
                                                                              FontWeight.bold,
                                                                              FontWeight_.Fonts_T,
                                                                              14,
                                                                              1),

                                                                          //  Text(
                                                                          //   'เลขที่ใบเสร็จ',
                                                                          //   textAlign: TextAlign.center,
                                                                          //   style: TextStyle(
                                                                          //       color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                          //       //fontWeight: FontWeight.bold,
                                                                          //       fontFamily: Font_.Fonts_T),
                                                                          // ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Text(
                                                                            '$numinvoice',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style: const TextStyle(
                                                                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                //fontWeight: FontWeight.bold,
                                                                                fontFamily: Font_.Fonts_T),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          TextFormField(
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        controller:
                                                                            Formbecause_,
                                                                        validator:
                                                                            (value) {
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
                                                                        decoration: InputDecoration(
                                                                            fillColor: Colors.white.withOpacity(0.3),
                                                                            filled: true,
                                                                            // prefixIcon: const Icon(Icons.water,
                                                                            //     color: Colors.blue),
                                                                            // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                            focusedBorder: const OutlineInputBorder(
                                                                              borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(15),
                                                                                topLeft: Radius.circular(15),
                                                                                bottomRight: Radius.circular(15),
                                                                                bottomLeft: Radius.circular(15),
                                                                              ),
                                                                              borderSide: BorderSide(
                                                                                width: 1,
                                                                                color: Colors.black,
                                                                              ),
                                                                            ),
                                                                            enabledBorder: const OutlineInputBorder(
                                                                              borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(15),
                                                                                topLeft: Radius.circular(15),
                                                                                bottomRight: Radius.circular(15),
                                                                                bottomLeft: Radius.circular(15),
                                                                              ),
                                                                              borderSide: BorderSide(
                                                                                width: 1,
                                                                                color: Colors.grey,
                                                                              ),
                                                                            ),
                                                                            labelText: 'หมายเหตุ-Note',
                                                                            labelStyle: const TextStyle(
                                                                              color: AccountScreen_Color.Colors_Text2_,
                                                                              // fontWeight:
                                                                              //     FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T,
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
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                if (numinvoice != null) {
                                                                                  Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>ประวัติวางบิล>>ยกเลิกการวางบิล(${numinvoice.toString()})');
                                                                                  // print(numinvoice);
                                                                                  de_invoice(numinvoice, '1');
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                  height: 50,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.green.shade500,
                                                                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                                                                    border: Border.all(color: Colors.grey, width: 1),
                                                                                  ),
                                                                                  padding: const EdgeInsets.all(3.0),
                                                                                  child: Center(
                                                                                    child: Translate.TranslateAndSetText('ตกลง', Colors.white, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),

                                                                                    // Text(
                                                                                    //   'ตกลง',
                                                                                    //   style: TextStyle(
                                                                                    //       color: Colors.white,
                                                                                    //       // fontSize: 10.0,
                                                                                    //       fontFamily: FontWeight_.Fonts_T),
                                                                                    // ),
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                InkWell(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Container(
                                                                                  height: 50,
                                                                                  decoration: BoxDecoration(
                                                                                    color: Colors.black,
                                                                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6), bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
                                                                                    border: Border.all(color: Colors.grey, width: 1),
                                                                                  ),
                                                                                  padding: const EdgeInsets.all(3.0),
                                                                                  child: Center(
                                                                                    child: Translate.TranslateAndSetText('ยกเลิก', Colors.white, TextAlign.center, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),

                                                                                    // Text(
                                                                                    //   'ยกเลิก',
                                                                                    //   style: TextStyle(
                                                                                    //       color: Colors.white,
                                                                                    //       // fontSize: 10.0,
                                                                                    //       fontFamily: FontWeight_.Fonts_T),
                                                                                    // ),
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: (Cancell_bill.toString() ==
                                                      '1')
                                                  ? Colors.grey[200]
                                                  : (DateTime.parse(
                                                                  '${InvoiceModels[index].daterec} 00:00:00')
                                                              .add(Duration(
                                                                  days: int.parse(
                                                                      '${Day_Cancell_bill}')))
                                                              .isBefore(
                                                                  datex) &&
                                                          Day_Cancell_bill
                                                                  .toString() !=
                                                              '0')
                                                      ? Colors.grey[200]
                                                      : Colors.orange[200],
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
                                            child: (Cancell_bill.toString() ==
                                                    '1')
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Icon(
                                                            Icons
                                                                .cancel_presentation,
                                                            color: Colors.grey),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.all(4.0),
                                                        child: Translate
                                                            .TranslateAndSetText(
                                                                'ไม่เปิด/อนุญาตให้ยกเลิก',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                        // Text(
                                                        //   'ไม่เปิด/อนุญาตให้ยกเลิก',
                                                        //   style:
                                                        //       TextStyle(
                                                        //     color: AccountScreen_Color
                                                        //         .Colors_Text2_,
                                                        //     // fontWeight:
                                                        //     //     FontWeight.bold,
                                                        //     fontFamily:
                                                        //         Font_
                                                        //             .Fonts_T,
                                                        //   ),
                                                        // )
                                                      ),
                                                    ],
                                                  )
                                                : (DateTime.parse(
                                                                '${InvoiceModels[index].daterec} 00:00:00')
                                                            .add(Duration(
                                                                days: int.parse(
                                                                    '${Day_Cancell_bill}')))
                                                            .isBefore(datex) &&
                                                        Day_Cancell_bill
                                                                .toString() !=
                                                            '0')
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
                                                                    .cancel_presentation,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Translate.TranslateAndSetText(
                                                                'เกินกำหนดยกเลิก$Day_Cancell_billวัน',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            //  Text(
                                                            //   'เกินกำหนดยกเลิก$Day_Cancell_billวัน',
                                                            //   style:
                                                            //       TextStyle(
                                                            //     color: AccountScreen_Color
                                                            //         .Colors_Text2_,
                                                            //     // fontWeight:
                                                            //     //     FontWeight.bold,
                                                            //     fontFamily:
                                                            //         Font_.Fonts_T,
                                                            //   ),
                                                            // )
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
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Icon(
                                                                Icons
                                                                    .cancel_presentation,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4.0),
                                                            child: Translate.TranslateAndSetText(
                                                                'ยกเลิกการวางบิล',
                                                                AccountScreen_Color
                                                                    .Colors_Text2_,
                                                                TextAlign
                                                                    .center,
                                                                null,
                                                                Font_.Fonts_T,
                                                                14,
                                                                1),
                                                            //  Text(
                                                            //   'ยกเลิกการวางบิล',
                                                            //   style:
                                                            //       TextStyle(
                                                            //     color: AccountScreen_Color
                                                            //         .Colors_Text2_,
                                                            //     // fontWeight:
                                                            //     //     FontWeight.bold,
                                                            //     fontFamily:
                                                            //         Font_
                                                            //             .Fonts_T,
                                                            //   ),
                                                            // ),
                                                          ),
                                                        ],
                                                      ),
                                          ),
                                        ),
                                      ),
                                      regis_models.length == 0
                                          ? const SizedBox()
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              width: 200,
                                              child: InkWell(
                                                onTap: () {
                                                  showdialog_Coming(index);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
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
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'แจ้งเตือนชำระ',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .center,
                                                                  null,
                                                                  Font_.Fonts_T,
                                                                  14,
                                                                  1),
                                                          //  Text(
                                                          //   'แจ้งเตือนชำระ',
                                                          //   style:
                                                          //       TextStyle(
                                                          //     color: Colors
                                                          //         .white,
                                                          //     // fontWeight:
                                                          //     //     FontWeight.bold,
                                                          //     fontFamily:
                                                          //         Font_
                                                          //             .Fonts_T,
                                                          //   ),
                                                          // ),
                                                        ),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Container(
                                                              decoration:
                                                                  const BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  image: AssetImage(
                                                                      "images/lineicon.png"),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              child:
                                                                  const SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                            )),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                      (InvoiceModels[index].btype == null ||
                                              InvoiceModels[index]
                                                      .btype
                                                      .toString() ==
                                                  '')
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                // color: Colors.green,
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
                                              child: Column(
                                                children: [
                                                  Translate.TranslateAndSetText(
                                                      '** พิมพ์ ไม่ได้ไม่พบช่องทางรับชำระ !!!',
                                                      Colors.orange,
                                                      TextAlign.start,
                                                      FontWeight.bold,
                                                      FontWeight_.Fonts_T,
                                                      14,
                                                      1),
                                                  // Text(
                                                  //   '** พิมพ์ ไม่ได้ไม่พบช่องทางรับชำระ !!!',
                                                  //   style: TextStyle(
                                                  //     color:
                                                  //         Colors.orange,
                                                  //     // fontWeight:
                                                  //     //     FontWeight.bold,
                                                  //     fontFamily:
                                                  //         Font_.Fonts_T,
                                                  //   ),
                                                  // ),
                                                  Translate.TranslateAndSetText(
                                                      '( โปรดตรวจสอบหรือยกเลิก )',
                                                      Colors.orange,
                                                      TextAlign.start,
                                                      FontWeight.bold,
                                                      FontWeight_.Fonts_T,
                                                      14,
                                                      1),
                                                  // Text(
                                                  //   '( โปรดตรวจสอบหรือยกเลิก )',
                                                  //   style: TextStyle(
                                                  //     color:
                                                  //         Colors.orange,
                                                  //     // fontWeight:
                                                  //     //     FontWeight.bold,
                                                  //     fontFamily:
                                                  //         Font_.Fonts_T,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            )
                                          : Container(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              width: 200,
                                              child: InkWell(
                                                onTap: () {
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
                                                  var docno =
                                                      _InvoiceModels[index]
                                                          .cname;
                                                  var namenew =
                                                      _InvoiceModels[index]
                                                          .cname;
                                                  _showMyDialog_SAVE(
                                                      newValuePDFimg,
                                                      docno,
                                                      namenew);
                                                },
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
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
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Icon(
                                                              Icons.print,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: Translate
                                                              .TranslateAndSetText(
                                                                  'พิมพ์',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .center,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                          //  Text(
                                                          //   'พิมพ์',
                                                          //   style:
                                                          //       TextStyle(
                                                          //     color: Colors
                                                          //         .white,
                                                          //     // fontWeight:
                                                          //     //     FontWeight.bold,
                                                          //     fontFamily:
                                                          //         Font_
                                                          //             .Fonts_T,
                                                          //   ),
                                                          // ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                    ]))))
                  ])
                ],
              ),
            ));
  }

  Future<Null> Gen_QRAPINEW(int index) async {
    var total_QRsend = (sum_amt - sum_disamt).toStringAsFixed(2);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
            insetPadding: EdgeInsets.all(5),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context, 'OK');
                          },
                          child: Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 22,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 1),
                  Divider(),
                  SizedBox(height: 1),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Online Standard QR',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T),
                                ),
                              ),
                            ),
                            Divider(),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ref1 : ${InvoiceModels[index].ref1}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'ref2 : ${InvoiceModels[index].ref2}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Total : ${total_QRsend} ',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ],
                        );
                      }),
                  SizedBox(height: 1),
                  Divider(),
                  SizedBox(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'SCAN ME',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                    ),
                  ),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Container(
                              width: 500,
                              height: 500,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${MyConstant().domain}/gen_qr_img.php?ren=$ren&ref_id=${InvoiceModels[index].refapi}&incid=${InvoiceModels[index].cid}&sum=$total_QRsend&extension=.png'),
                                ),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(0),
                                    bottomRight: Radius.circular(0)),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InvoiceModels[index].ser_noti != null
                                    ? Container(
                                        width: 200,
                                        decoration: BoxDecoration(
                                          color: Colors.green[400],
                                          borderRadius: BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          // border: Border.all(color: Colors.white, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () {
                                            PanaraConfirmDialog
                                                .showAnimatedGrow(
                                              context,
                                              title: "Line Notification",
                                              message:
                                                  "แจ้งเตือนชำระค่าบริการผ่านไลน์",
                                              confirmButtonText: "Confirm",
                                              cancelButtonText: "Cancel",
                                              onTapConfirm: () async {
                                                if (InvoiceModels[index]
                                                        .ser_noti !=
                                                    null) {
                                                  var serregis =
                                                      InvoiceModels[index]
                                                          .ser_noti;
                                                  var incid =
                                                      InvoiceModels[index].cid;
                                                  var indocno =
                                                      InvoiceModels[index]
                                                          .docno;
                                                  var insum = nFormat.format(
                                                      double.parse(
                                                          InvoiceModels[index]
                                                              .total_dis!));
                                                  SharedPreferences
                                                      preferences =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  var ren = preferences
                                                      .getString('renTalSer');
                                                  String url =
                                                      '${MyConstant().domain}/sent_line_noti_image.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
                                                  renTal_name = preferences
                                                      .getString('renTalName');
                                                  try {
                                                    var response = await http
                                                        .get(Uri.parse(url));

                                                    var result = json
                                                        .decode(response.body);

                                                    if (result.toString() ==
                                                        'Line Successfully') {
                                                      //print('Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Translate
                                                              .TranslateAndSetText(
                                                                  'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                          // Text(
                                                          //   'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)',
                                                          //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                          // ),
                                                        ),
                                                      );
                                                    } else {
                                                      // print('Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)');
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Translate
                                                              .TranslateAndSetText(
                                                                  'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                                  Colors.white,
                                                                  TextAlign
                                                                      .start,
                                                                  FontWeight
                                                                      .bold,
                                                                  FontWeight_
                                                                      .Fonts_T,
                                                                  14,
                                                                  1),
                                                          // Text(
                                                          //   'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)',
                                                          //   style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T),
                                                          // ),
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    print(
                                                        'Error-Dis(read_GC_rental) : ${e}');
                                                  }
                                                }
                                                Navigator.pop(context);
                                              },
                                              onTapCancel: () {
                                                Navigator.pop(context);
                                              },
                                              panaraDialogType:
                                                  PanaraDialogType.success,
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Send Line ',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Icon(
                                                Icons.send_outlined,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            )
                          ],
                        );
                      }),
                ],
              ),
            ));
      },
    );
  }

  showdialog_Coming(int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              height: 700, // MediaQuery.of(context).size.width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // payment_Ptser1 == '8'
                  //     ? Container(
                  //         width: 500,
                  //         height: 500,
                  //         decoration: BoxDecoration(
                  //           image: DecorationImage(
                  //             image: NetworkImage(
                  //                 '${MyConstant().domain}/gen_qr_img.php?ren=$ren&ref_id=${_InvoiceModels[index].refapi}&incid=${_InvoiceModels[index].cid}&sum=${(sum_amt - sum_disamt)}&extension=.png'),
                  //           ),
                  //           borderRadius: BorderRadius.only(
                  //               topLeft: Radius.circular(10),
                  //               topRight: Radius.circular(10),
                  //               bottomLeft: Radius.circular(0),
                  //               bottomRight: Radius.circular(0)),
                  //         ),
                  //       )
                  //     : SizedBox(),
                  for (int inregis = 0;
                      inregis < regis_models.length;
                      inregis++)
                    // if(regis_models[inregis].cid ==_InvoiceModels[index].cid)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Line UserName : ${regis_models[inregis].username}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              )),
                        ),
                        Expanded(
                          flex: 4,
                          child: GestureDetector(
                            onTap: () async {
                              var serregis = regis_models[inregis].ser;
                              var incid = _InvoiceModels[index].cid;
                              var indocno = _InvoiceModels[index].docno;
                              var insum = nFormat.format(sum_amt - sum_disamt);
                              SharedPreferences preferences =
                                  await SharedPreferences.getInstance();
                              var ren = preferences.getString('renTalSer');
                              String url =
                                  '${MyConstant().domain}/sent_line_noti.php?isAdd=true&ren=$ren&serregis=$serregis&incid=$incid&indocno=$indocno&insum=$insum';
                              renTal_name = preferences.getString('renTalName');
                              try {
                                var response = await http.get(Uri.parse(url));

                                var result = json.decode(response.body);

                                if (result.toString() == 'Line Successfully') {
                                  print(
                                      'Line Notify Successful (ส่งแจ้งเตือนทางไลน์ สำเร็จ)');
                                } else {
                                  print(
                                      'Line Notify Unsuccessful (ส่งแจ้งเตือนทางไลน์ ไม่สำเร็จ กรุณาทำรายการใหม่)');
                                }
                              } catch (e) {
                                print('Error-Dis(read_GC_rental) : ${e}');
                              }
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        'Send Line >>> ',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      )),
                                  Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(
                                                "images/lineicon.png"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: const SizedBox(
                                          width: 20,
                                          height: 20,
                                        ),
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Divider(),
                ],
              ),
            ),
          );
        });
  }

  showdialog_ComingQR(int index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              height: 600, // MediaQuery.of(context).size.width * 0.1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  payment_Ptser1 == '8'
                      ? Container(
                          width: 500,
                          height: 500,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  '${MyConstant().domain}/gen_qr_img.php?ren=$ren&ref_id=${_InvoiceModels[index].refapi}&incid=${_InvoiceModels[index].cid}&sum=${sum_amt - sum_disamt}&extension=.png'),
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(0)),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          );
        });
  }

////////////------------------------------------------------------>(Export file)
  Future<void> _showMyDialog_SAVE(newValuePDFimg, cid, namenew) async {
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    // String? TitleType_Default_Receipt_Name;
    final _formKey = GlobalKey<FormState>();
    final FormNameFile_text = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Form(
          key: _formKey,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Center(
                    child: Translate.TranslateAndSetText(
                        'หัวบิล :',
                        AccountScreen_Color.Colors_Text1_,
                        TextAlign.center,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        1),
                  ),

                  //  Text(
                  //   'หัวบิล :',
                  //   style: TextStyle(
                  //     color: ReportScreen_Color.Colors_Text2_,
                  //     // fontWeight: FontWeight.bold,
                  //     fontFamily: Font_.Fonts_T,
                  //   ),
                  // ),
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Container(
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
                            direction: Axis.vertical,
                            groupValue: _ReportValue_type,
                            horizontalAlignment: MainAxisAlignment.center,
                            onChanged: (value) {
                              // setState(() {
                              //   FormNameFile_text.clear();
                              // });
                              setState(() {
                                _ReportValue_type = value ?? '';
                              });

                              if (value == 'ไม่ระบุ') {
                                setState(() {
                                  TitleType_Default_Receipt_Name = null;
                                });
                              } else {
                                setState(() {
                                  TitleType_Default_Receipt_Name = value;
                                });
                              }
                            },
                            items: <String>[
                              for (int index = 0;
                                  index < TitleType_Default_Receipt_.length;
                                  index++)
                                '${TitleType_Default_Receipt_[index]}',
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
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 3, 2, 2),
                    child: Text(
                      '🖨 พิมพ์แล้ว : ${(paper_run == null) ? 0 : paper_run} ครั้ง',
                      style: TextStyle(
                        fontSize: 14,
                        color: ReportScreen_Color.Colors_Text2_,
                        // fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      onTap: () {
                        BillingNoteInvlice_History_Tempage(
                            newValuePDFimg,
                            renTal_name,
                            cid,
                            namenew,
                            '0',
                            TitleType_Default_Receipt_Name);
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
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              'พิมพ์',
                              Colors.white,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
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
                        child: Center(
                          child: Translate.TranslateAndSetText(
                              'ปิด',
                              Colors.white,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
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
  }

  /////////------------------------>
  Future<void> _showMyDialog_SAVE2(newValuePDFimg, Folder_File) async {
    int invoice_select_Ser = 0;
    String invoice_Now = '';
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    String? TitleType_Default_Receipt_Name;
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
                                      invoice_select.clear();
                                    });
                                    Future.delayed(const Duration(seconds: 2));
                                    Deleted_foder(context).then((value) {
                                      Future.delayed(
                                          const Duration(seconds: 2));
                                      Navigator.pop(context, 'OK');
                                    });
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
                              child:
                                  // Translate.TranslateAndSetText(
                                  //     (innerloop == false)
                                  //         ? 'กำลังหยุดดำเนินการ...'
                                  //         : '${invoice_Now} ',
                                  //     (innerloop == false)
                                  //         ? Colors.red
                                  //         : Colors.blue,
                                  //     TextAlign.center,
                                  //     null,
                                  //     Font_.Fonts_T,
                                  //     14,
                                  //     1),
                                  Text(
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
                            // Translate.TranslateAndSetText(
                            //     'ดำเนินการ ทั้งหมด : ${invoice_select.length} รายการ',
                            //     AccountScreen_Color.Colors_Text1_,
                            //     TextAlign.center,
                            //     null,
                            //     Font_.Fonts_T,
                            //     14,
                            //     1),
                            Text(
                              'ดำเนินการ ทั้งหมด : ${invoice_select.length} รายการ',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ReportScreen_Color.Colors_Text2_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                              ),
                            ),
                            // Translate.TranslateAndSetText(
                            //     'หัวบิล :',
                            //     AccountScreen_Color.Colors_Text1_,
                            //     TextAlign.center,
                            //     null,
                            //     Font_.Fonts_T,
                            //     14,
                            //     1),
                            const Text(
                              'หัวบิล :',
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
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              padding: const EdgeInsets.all(8.0),
                              child: RadioGroup<String>.builder(
                                direction: Axis.horizontal,
                                groupValue: _ReportValue_type,
                                horizontalAlignment:
                                    MainAxisAlignment.spaceAround,
                                onChanged: (value) {
                                  // setState(() {
                                  //   FormNameFile_text.clear();
                                  // });
                                  setState(() {
                                    _ReportValue_type = value ?? '';
                                  });

                                  if (value == 'ไม่ระบุ') {
                                    setState(() {
                                      TitleType_Default_Receipt_Name = null;
                                    });
                                  } else {
                                    setState(() {
                                      TitleType_Default_Receipt_Name = value;
                                    });
                                  }
                                  // print(TitleType_Default_Receipt_Name);
                                },
                                items: const <String>[
                                  'ไม่ระบุ',
                                  'ต้นฉบับ',
                                  'สำเนา',
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
                                        index < invoice_select.length;
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
                                                '${(endIndex / limit)}/${(limitedList_InvoiceModels_.length / limit).ceil()}');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            invoice_select.clear();
                                          });
                                          // Future.delayed(
                                          //     const Duration(seconds: 1), () {
                                          //   Navigator.pop(context, 'OK');
                                          // });
                                          break innerloop_for;
                                        }
                                        var docno =
                                            invoice_select[index].toString();
                                        setState(() {
                                          numinvoice = invoice_select[index];
                                          invoice_Now =
                                              'กำลังดำเนินการ (${index + 1} / ${invoice_select.length}) : ${invoice_select[index]}';
                                        });
                                        var namenew = '';
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));

                                        BillingNoteInvlice_History_Tempage(
                                            newValuePDFimg,
                                            renTal_name,
                                            docno,
                                            namenew,
                                            '$Folder_File',
                                            TitleType_Default_Receipt_Name);

                                        setState(() {
                                          invoice_loade_Success.add(
                                              invoice_select[index].toString());
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        if (index + 1 ==
                                            invoice_select.length) {
                                          await Future.delayed(const Duration(
                                              milliseconds: 400));
                                          setState(() {
                                            preferences.setString('name_page',
                                                'ใบวางบิล/ใบแจ้งหนี้_${(endIndex / limit)}of${(limitedList_InvoiceModels_.length / limit).ceil()}($MONTH_Now-$YEAR_Now)');
                                            preferences.setString(
                                                'Select_UP_Success', 'OK');
                                            invoice_select.clear();
                                          });
                                          Future.delayed(
                                              const Duration(seconds: 3), () {
                                            // print('')

                                            Navigator.pop(context, 'OK');
                                            if (Folder_File! == 'Folder') {
                                              Dialog_Download_Foder(context);
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
                                  child: Center(
                                    child:
                                        // Translate.TranslateAndSetText(
                                        //     'ปิด',
                                        //     Colors.white,
                                        //     TextAlign.center,
                                        //     null,
                                        //     Font_.Fonts_T,
                                        //     14,
                                        //     1),

                                        Text(
                                      'close',
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

  Future<void> _showMyDialog_delete() async {
    int invoice_select_Ser = 0;
    String invoice_Now = '';
    setState(() {
      generateRandomString();
    });
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
            return Form(
              // key: _formKey,
              child: AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                content: SingleChildScrollView(
                  child: (invoice_select_Ser == 1)
                      ? ListBody(children: <Widget>[
                          const Center(
                              child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator())),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                '${invoice_Now} ',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                        ])
                      : ListBody(
                          children: <Widget>[
                            Translate.TranslateAndSetText(
                                'ลบ ทั้งหมด : ${invoice_select_delete.length} รายการ',
                                AccountScreen_Color.Colors_Text1_,
                                TextAlign.center,
                                null,
                                Font_.Fonts_T,
                                14,
                                1),
                            // Text(
                            //   'ลบ ทั้งหมด : ${invoice_select_delete.length} รายการ',
                            //   textAlign: TextAlign.center,
                            //   style: const TextStyle(
                            //     color: ReportScreen_Color.Colors_Text2_,
                            //     fontWeight: FontWeight.bold,
                            //     fontFamily: FontWeight_.Fonts_T,
                            //   ),
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
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Translate.TranslateAndSetText(
                                  'ผู้ดำเนินการ',
                                  AccountScreen_Color.Colors_Text1_,
                                  TextAlign.center,
                                  null,
                                  Font_.Fonts_T,
                                  14,
                                  1),

                              // Text(
                              //   'ผู้ดำเนินการ',
                              //   style: TextStyle(
                              //       color: AccountScreen_Color.Colors_Text2_,
                              //       fontWeight: FontWeight.bold,
                              //       fontFamily: Font_.Fonts_T),
                              // ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                              child: Text(
                                '- ${email_login}($seremail_login)',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AccountScreen_Color.Colors_Text2_,
                                    // fontWeight:
                                    //     FontWeight.bold,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'CODE : ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          color: Color.fromARGB(
                                              255, 179, 177, 170),
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
                                            style: TextStyle(
                                                color: Colors.red[800],
                                                fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
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
                            const SizedBox(
                              height: 5.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: Formbecause_,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'ใส่ข้อมูลให้ครบถ้วน ';
                                  }
                                  // if (int.parse(value.toString()) < 13) {
                                  //   return '< 13';
                                  // }
                                  return null;
                                },
                                // maxLength: 13,
                                cursorColor: Colors.green,
                                decoration: InputDecoration(
                                    fillColor: Colors.white.withOpacity(0.3),
                                    filled: true,
                                    // prefixIcon: const Icon(Icons.water,
                                    //     color: Colors.blue),
                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(15),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.black,
                                      ),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(15),
                                        topLeft: Radius.circular(15),
                                        bottomRight: Radius.circular(15),
                                        bottomLeft: Radius.circular(15),
                                      ),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    labelText: 'หมายเหตุ-Note',
                                    labelStyle: const TextStyle(
                                      color: AccountScreen_Color.Colors_Text2_,
                                      // fontWeight:
                                      //     FontWeight.bold,
                                      fontFamily: Font_.Fonts_T,
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
                              height: 10,
                            ),
                            const Divider(
                              color: Colors.grey,
                              height: 1.0,
                            ),
                            const SizedBox(
                              height: 5.0,
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
                                onTap: (Pincontroller.text != "$randomString")
                                    ? null
                                    : () async {
                                        setState(() {
                                          invoice_select_Ser = 1;
                                        });
                                        try {
                                          for (int index = 0;
                                              index <
                                                  invoice_select_delete.length;
                                              index++) {
                                            var docno =
                                                invoice_select_delete[index]
                                                    .toString();
                                            setState(() {
                                              numinvoice =
                                                  invoice_select_delete[index];
                                              invoice_Now =
                                                  'delete (${index + 1} / ${invoice_select_delete.length}) : ${invoice_select_delete[index]}';
                                            });
                                            var namenew = '';
                                            de_invoice2(numinvoice, '1');
                                            await Future.delayed(const Duration(
                                                milliseconds: 800));
                                            setState(() {
                                              invoice_loade_Success_delete.add(
                                                  invoice_select_delete[index]
                                                      .toString());
                                            });
                                            await Future.delayed(const Duration(
                                                milliseconds: 500));
                                            if (index + 1 ==
                                                invoice_select_delete.length) {
                                              setState(() {
                                                invoice_select_delete.clear();
                                              });
                                              Navigator.pop(context, 'OK');
                                            }
                                          }
                                        } catch (e) {
                                          Navigator.pop(context, 'OK');
                                        }
                                      },
                                child: Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color:
                                        (Pincontroller.text != "$randomString")
                                            ? Colors.grey
                                            : Colors.green,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'ลบ',
                                        Colors.white,
                                        TextAlign.center,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),

                                    //  Text(
                                    //   'ลบ',
                                    //   style: TextStyle(
                                    //     color: Colors.white,
                                    //     //fontWeight: FontWeight.bold, color:

                                    //     // fontWeight: FontWeight.bold,
                                    //     fontFamily: Font_.Fonts_T,
                                    //   ),
                                    // ),
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
                                  child: Center(
                                    child: Translate.TranslateAndSetText(
                                        'ปิด',
                                        Colors.white,
                                        TextAlign.center,
                                        null,
                                        Font_.Fonts_T,
                                        14,
                                        1),
                                    // Text(
                                    //   'ปิด',
                                    //   style: TextStyle(
                                    //     color: Colors.white,
                                    //     //fontWeight: FontWeight.bold, color:

                                    //     // fontWeight: FontWeight.bold,
                                    //     fontFamily: Font_.Fonts_T,
                                    //   ),
                                    // ),
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

  //////////////////////////------------------------------>
  Future<Null> de_invoice(Get_Value_cid, Get_Value_NameShop_index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = Get_Value_cid;
    var qutser = Get_Value_NameShop_index;
    var because = Formbecause_.text?.toString() ?? '';
    // print('numinvoice 1 $numinvoice');
    String url =
        '${MyConstant().domain}/UPC_Invoice_history.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&numinvoice=$numinvoice&remark=$because';
    try {
      print('numinvoice 2 $numinvoice');
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result>>>>>>> $result');
      // print('numinvoice 3 $numinvoice');

      if (result.toString() == 'true') {
        setState(() async {
          // print('numinvoice 4 $numinvoice');
          red_InvoiceMon_bill();
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
    Navigator.pop(context, 'OK');
  }

  Future<Null> de_invoice2(Get_Value_cid, Get_Value_NameShop_index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = Get_Value_cid;
    var qutser = Get_Value_NameShop_index;
    var because = Formbecause_.text.toString() ?? '';
    // print('numinvoice 1 $numinvoice');
    String url =
        '${MyConstant().domain}/UPC_Invoice_history.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&numinvoice=$numinvoice&remark=$because';
    try {
      // print('numinvoice 2 $numinvoice');
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result>>>>>>> $result');
      // print('numinvoice 3 $numinvoice');

      if (result.toString() == 'true') {
        setState(() async {
          // print('numinvoice 4 $numinvoice');
          red_InvoiceMon_bill();
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Dialog_notimax(max) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Translate.TranslateAndSetText(
            'เลือกได้สูงสุด $max รายการ...!!',
            Colors.white,
            TextAlign.center,
            null,
            Font_.Fonts_T,
            14,
            1),
        // Text('เลือกได้สูงสุด $max รายการ...!!',
        //     style: const TextStyle(
        //         color: Colors.white,
        //         fontWeight: FontWeight.bold,
        //         fontFamily: FontWeight_.Fonts_T)
        //         )
      ),
    );
  }
  //////////////////////////------------------------------>

  Future<Null> BillingNoteInvlice_History_Tempage(newValuePDFimg, renTal_name,
      cid, namenew, Preview_ser, TitleType_Default_Receipt_Name) async {
    // String? TitleType_Default_Receipt_Name;
    // if (TitleType_Default_Receipt == 0) {
    // } else {
    //   setState(() {
    //     TitleType_Default_Receipt_Name =
    //         '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}';
    //   });
    // }
    Man_BillingNoteInvlice_PDF.ManBillingNoteInvlice_PDF(
        TitleType_Default_Receipt_Name,
        foder,
        '1',
        tem_page_ser,
        context,
        '${cid}',
        '${namenew}',
        '${renTalModels[0].bill_addr}',
        '${renTalModels[0].bill_email}',
        '${renTalModels[0].bill_tel}',
        '${renTalModels[0].bill_tax}',
        '${renTalModels[0].bill_name}',
        newValuePDFimg,
        numinvoice,
        Preview_ser);
  }

///////////////-------------------------------------------->
  double sum_Pakan = 0,
      sum_Pakan_KF = 0,
      dis_Pakan = 0,
      dis_matjum = 0,
      dis_sum_Pakan = 0.00,
      dis_sum_Matjum = 0.00,
      sum_Matjum_KF = 0,
      sum_tran_dis = 0,
      sum_matjum = 0.00,
      sum_tran_fine = 0,
      fine_total = 0,
      fine_total2 = 0,
      sum_fine = 0;
  String? cFinn,
      doctax,
      paymentSer1,
      paymentSer2,
      paymentName1,
      selectedValue,
      bname1;
  String? bneme_check, bno_check, bser_check;
  List Default_ = [
    'บิลธรรมดา',
  ];
  List Default2_ = [
    'บิลธรรมดา',
    'ใบกำกับภาษี',
  ];

  /////////----------------------------------------------------------->
/////////----------------------------------------------------------->
  Future<Null> red_Trans_selectPay(index) async {
    // print(
    //     'Ser : ${InvoiceModels[index].ser} // docno :  ${InvoiceModels[index].docno} ///total : ${InvoiceModels[index].total_dis}');
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
    var ciddoc = InvoiceModels[index].cid;
    var qutser = '1';
    var docnoin = InvoiceModels[index].docno;

    String url =
        '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
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

            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      } else if (result.toString() == 'false') {
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

            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Translate.TranslateAndSetText(
                'มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                Colors.white,
                TextAlign.start,
                null,
                Font_.Fonts_T,
                14,
                1),

            // Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
            //     style: TextStyle(
            //         color: Colors.white, fontFamily: Font_.Fonts_T))
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Translate.TranslateAndSetText(
              'มีผู้ใช้อื่นกำลังทำรายการอยู่....',
              Colors.white,
              TextAlign.start,
              null,
              Font_.Fonts_T,
              14,
              1),
          //  Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
          //     style:
          //         TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))
        ),
      );
    }
  }

  Future<Null> red_Trans_selectPay_check(index) async {
    setState(() {
      sum_pvat = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
      sum_disamt = 0;
      sum_disp = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = _InvoiceModels[index].cid;
    var qutser = '1';
    var docnoin = _InvoiceModels[index].docno;

    String url =
        '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
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
          });
        }
      } else if (result.toString() == 'false') {
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
          });
        }
      } else {}
    } catch (e) {}
  }

  /////////----------------------------------------------------------->
  Future<void> _showMyDialog_pay(index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();

        DateTime datexDialog = DateTime.now();
        String Value_newDatepay = '${InvoiceModels[index].date}';
        String Value_newDateY1 =
            '${DateFormat('yyyy-MM-dd').format(datexDialog)}';
        //  '${DateFormat('yyyy-MM-dd').format(datexDialog)}';

        return Form(
          key: _formKey,
          child: AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            content: Container(
              width: 220,
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Text(
                          '${InvoiceModels[index].docno}',
                          style: const TextStyle(
                            color: ReportScreen_Color.Colors_Text2_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Translate.TranslateAndSetText(
                            'เลขที่สัญญา : ${InvoiceModels[index].cid} ',
                            Colors.grey,
                            TextAlign.start,
                            null,
                            Font_.Fonts_T,
                            14,
                            1),
                        //  Text(
                        //   'เลขที่สัญญา : ${InvoiceModels[index].cid} ',
                        //   style: const TextStyle(
                        //     color: Colors.grey,
                        //     fontFamily: Font_.Fonts_T,
                        //   ),
                        // ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Text(
                          'ชื่อร้าน-Shop  : ${InvoiceModels[index].scname} ',
                          maxLines: 2,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Center(
                        child: Text(
                          'รหัสพื้นที่-Area : ${InvoiceModels[index].ln} ',
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 0.5),
                    const Divider(),
                    const SizedBox(height: 0.5),
                    Container(
                      // width: 200,
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'วันที่รับชำระ',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.start,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'วันที่รับชำระ',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 0)),
                              builder: (context, snapshot) {
                                return Container(
                                    width: 200,
                                    height: 35,
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              // color: Colors.green[50],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(2.0),
                                            child: AutoSizeText(
                                              Value_newDatepay == ''
                                                  ? 'เลือกวันที่-Select'
                                                  : '$Value_newDatepay',
                                              minFontSize: 10,
                                              maxFontSize: 16,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              DateTime? newDate =
                                                  await showDatePicker(
                                                locale:
                                                    const Locale('th', 'TH'),
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now().add(
                                                    const Duration(days: -50)),
                                                lastDate: DateTime.now().add(
                                                    const Duration(days: 365)),
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          const ColorScheme
                                                              .light(
                                                        primary: AppBarColors
                                                            .ABar_Colors, // header background color
                                                        onPrimary: Colors
                                                            .white, // header text color
                                                        onSurface: Colors
                                                            .black, // body text color
                                                      ),
                                                      textButtonTheme:
                                                          TextButtonThemeData(
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary: Colors
                                                              .black, // button text color
                                                        ),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                },
                                              );

                                              if (newDate == null) {
                                                return;
                                              } else {
                                                String start =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(newDate);

                                                setState(() {
                                                  Value_newDatepay = start;
                                                });
                                              }
                                            },
                                            child: Container(
                                                decoration: BoxDecoration(
                                                  // color: Colors.green[50],
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(0),
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                                  border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: const Icon(Icons.edit)))
                                      ],
                                    ));
                              }),
                          // Container(
                          //     height: 35,
                          //     width: 200,
                          //     color: AppbackgroundColor.Sub_Abg_Colors,
                          //     padding: const EdgeInsets.all(4.0),
                          //     child: Row(
                          //       children: [
                          //         Expanded(
                          //           child: Container(
                          //             height: 35,
                          //             decoration: BoxDecoration(
                          //               color: Colors.grey[100],
                          //               borderRadius:
                          //                   const BorderRadius.only(
                          //                 topLeft: Radius.circular(8),
                          //                 topRight: Radius.circular(8),
                          //                 bottomLeft: Radius.circular(8),
                          //                 bottomRight: Radius.circular(8),
                          //               ),
                          //               border: Border.all(
                          //                   color: Colors.grey, width: 1),
                          //             ),
                          //             padding: const EdgeInsets.all(2.0),
                          //             child: AutoSizeText(
                          //               '$Value_newDatepay',
                          //               // '${bankExcBilling.where((model) => model.ref1.toString() == InvoiceModels[index].docno.toString() && model.amount.toString() == result.toString()).map((model) => model.payment_date).join(', ')}',
                          //               minFontSize: 10,
                          //               maxFontSize: 16,
                          //               textAlign: TextAlign.center,
                          //               style: const TextStyle(
                          //                   color: PeopleChaoScreen_Color
                          //                       .Colors_Text2_,
                          //                   // fontWeight: FontWeight.bold,
                          //                   fontFamily: Font_.Fonts_T),
                          //               maxLines: 1,
                          //               overflow: TextOverflow.ellipsis,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     )),
                        ],
                      ),
                    ),
                    Container(
                      // width: 200,
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'ยอดรวมสุทธิ',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'ยอดรวมสุทธิ',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          Container(
                              height: 35,
                              width: 200,
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                        border: Border.all(
                                            color: Colors.grey, width: 1),
                                      ),
                                      padding: const EdgeInsets.all(2.0),
                                      child: AutoSizeText(
                                        '${InvoiceModels[index].total_dis}',
                                        minFontSize: 10,
                                        maxFontSize: 16,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 0.5),
                    const Divider(),
                    const SizedBox(height: 0.5),
                    Container(
                      // width: 200,
                      // color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'รูปแบบบิล',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'รูปแบบบิล',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 0)),
                              builder: (context, snapshot) {
                                return Container(
                                  width: 200,
                                  height: 35,
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  padding: const EdgeInsets.all(8.0),
                                  child: DropdownButtonFormField2(
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    isExpanded: true,

                                    hint: Text(
                                      bills_name_.toString(),
                                      maxLines: 1,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                    ),
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontFamily: Font_.Fonts_T),
                                    iconSize: 30,
                                    buttonHeight: 40,
                                    // buttonPadding: const EdgeInsets.only(left: 20, right: 10),
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    items: bill_tser == '1'
                                        ? Default_.map((item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            )).toList()
                                        : Default2_.map((item) =>
                                            DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text2_,
                                                    //fontWeight: FontWeight.bold,
                                                    fontFamily: Font_.Fonts_T),
                                              ),
                                            )).toList(),

                                    onChanged: (value) async {
                                      var bill_set =
                                          value == 'บิลธรรมดา' ? 'P' : 'F';
                                      setState(() {
                                        bills_name_ = bill_set;
                                      });
                                      // print(bills_name_);
                                    },
                                    // onSaved: (value) {
                                    //   // selectedValue = value.toString();
                                    // },
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                    Container(
                      // width: 200,
                      // color: AppbackgroundColor.Sub_Abg_Colors,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Translate.TranslateAndSetText(
                              'วันที่ทำรายการ',
                              PeopleChaoScreen_Color.Colors_Text1_,
                              TextAlign.center,
                              null,
                              Font_.Fonts_T,
                              14,
                              1),
                          // const Text(
                          //   'วันที่ทำรายการ',
                          //   textAlign: TextAlign.center,
                          //   style: TextStyle(
                          //       color: PeopleChaoScreen_Color.Colors_Text1_,
                          //       fontWeight: FontWeight.bold,
                          //       fontFamily: FontWeight_.Fonts_T
                          //       //fontSize: 10.0
                          //       ),
                          // ),
                          StreamBuilder(
                              stream:
                                  Stream.periodic(const Duration(seconds: 0)),
                              builder: (context, snapshot) {
                                return Container(
                                    width: 200,
                                    height: 35,
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              // color: Colors.green[50],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                              ),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(2.0),
                                            child: AutoSizeText(
                                              Value_newDateY1 == ''
                                                  ? 'เลือกวันที่-Select'
                                                  : '$Value_newDateY1',
                                              minFontSize: 10,
                                              maxFontSize: 16,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  // fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        // InkWell(
                                        //     onTap: () async {
                                        //       DateTime? newDate =
                                        //           await showDatePicker(
                                        //         locale: const Locale('th', 'TH'),
                                        //         context: context,
                                        //         initialDate: DateTime.now(),
                                        //         firstDate: DateTime.now().add(
                                        //             const Duration(days: -50)),
                                        //         lastDate: DateTime.now().add(
                                        //             const Duration(days: 365)),
                                        //         builder: (context, child) {
                                        //           return Theme(
                                        //             data: Theme.of(context)
                                        //                 .copyWith(
                                        //               colorScheme:
                                        //                   const ColorScheme.light(
                                        //                 primary: AppBarColors
                                        //                     .ABar_Colors, // header background color
                                        //                 onPrimary: Colors
                                        //                     .white, // header text color
                                        //                 onSurface: Colors
                                        //                     .black, // body text color
                                        //               ),
                                        //               textButtonTheme:
                                        //                   TextButtonThemeData(
                                        //                 style:
                                        //                     TextButton.styleFrom(
                                        //                   primary: Colors
                                        //                       .black, // button text color
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //             child: child!,
                                        //           );
                                        //         },
                                        //       );

                                        //       if (newDate == null) {
                                        //         return;
                                        //       } else {
                                        //         String start =
                                        //             DateFormat('yyyy-MM-dd')
                                        //                 .format(newDate);

                                        //         setState(() {
                                        //           Value_newDateY1 = start;
                                        //         });
                                        //       }
                                        //     },
                                        //     child: Container(
                                        //         decoration: BoxDecoration(
                                        //           // color: Colors.green[50],
                                        //           borderRadius:
                                        //               const BorderRadius.only(
                                        //             topLeft: Radius.circular(0),
                                        //             topRight: Radius.circular(8),
                                        //             bottomLeft:
                                        //                 Radius.circular(0),
                                        //             bottomRight:
                                        //                 Radius.circular(8),
                                        //           ),
                                        //           border: Border.all(
                                        //               color: Colors.grey,
                                        //               width: 1),
                                        //         ),
                                        //         padding:
                                        //             const EdgeInsets.all(2.0),
                                        //         child: const Icon(Icons.edit)))
                                      ],
                                    ));
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Column(
                children: [
                  const SizedBox(height: 0.5),
                  const Divider(),
                  const SizedBox(height: 0.5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () async {
                            // print(
                            //     'Docno InvoiceModels1 >>>>> ${InvoiceModels[index].docno}');
                            in_Trans_invoice_refnoPay(index, Value_newDateY1,
                                    Value_newDatepay, '0')
                                .then((value) {
                              setState(() {
                                Future.delayed(
                                    const Duration(milliseconds: 800));
                                red_InvoiceMon_bill();
                              });
                            });

                            // Pay_Invoice(
                            //     index, Value_newDateY1, Value_newDatepay);
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
                            child: Center(
                              child: Translate.TranslateAndSetText(
                                  'ยืนยัน',
                                  Colors.white,
                                  TextAlign.center,
                                  null,
                                  Font_.Fonts_T,
                                  14,
                                  1),
                              //  Text(
                              //   'ยืนยัน',
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     //fontWeight: FontWeight.bold, color:

                              //     // fontWeight: FontWeight.bold,
                              //     fontFamily: Font_.Fonts_T,
                              //   ),
                              // ),
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
                            child: Center(
                              child: Translate.TranslateAndSetText(
                                  'ปิด',
                                  Colors.white,
                                  TextAlign.center,
                                  null,
                                  Font_.Fonts_T,
                                  14,
                                  1),

                              //  Text(
                              //   'ปิด',
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     //fontWeight: FontWeight.bold, color:

                              //     // fontWeight: FontWeight.bold,
                              //     fontFamily: Font_.Fonts_T,
                              //   ),
                              // ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

/////////----------------------------------------------------------->
  /////////----------------------------------------------------------->
  Future<Null> in_Trans_invoice_refnoPay(
      index, Value_newDateY1, Value_newDatepay, serpay_all) async {
    var Times = DateFormat('HH:mm:ss').format(datex).toString();
    String? fileName_Slip_ = '';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = InvoiceModels[index].cid;
    var qutser = '1';
    var sumdis = sum_disamt.toString();
    var sumdisp = sum_disp.toString();
    var dateY = Value_newDatepay;
    var dateY1 = Value_newDateY1;
    var time = Times;
    //pamentpage == 0
    var dis_akan = dis_sum_Pakan.toString();
    var dis_Matjum = dis_sum_Matjum.toString();
    var payment1 = InvoiceModels[index].total_dis.toString();
    var payment2 = '';
    var pSer1 = InvoiceModels[index].payment_ser.toString();
    var pSer2 = paymentSer2;
    var ref = InvoiceModels[index].docno;
    var sum_whta = sum_wht.toString();
    var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    var comment = '';
    var sum_fine = sum_tran_fine;
    var fine_total_amt = (fine_total + fine_total2);
    // var ren = preferences.getString('renTalSer');
    // var user = preferences.getString('ser');
    // var ciddoc = InvoiceModels[index].cid;
    // var qutser = '1';
    // var sumdis = '0';
    // var sumdisp = '0';
    // var dateY = Value_newDatepay;
    // var dateY1 = Value_newDateY1;
    // var time = Times;
    // //pamentpage == 0
    // var dis_akan = '0';
    // var dis_Matjum = '0';
    // var payment1 = InvoiceModels[index].total_dis.toString();
    // var payment2 = '0';
    // var pSer1 = InvoiceModels[index].payment_ser.toString();
    // var pSer2 = '0';
    // var ref = InvoiceModels[index].docno;
    // var sum_whta = '0';
    // var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    // var comment = '0';
    // var sum_fine = '0';
    // var fine_total_amt = (fine_total + fine_total2);
    // print('in_Trans_invoice_refno()///$fileName_Slip_');
    // print('in_Trans_invoice_refno >>> $payment1  $payment2  $bill ');
    // print('Docno InvoiceModels 2 >>>>> ${InvoiceModels[index].docno}');
    String url =
        '${MyConstant().domain}/In_tran_finanref1.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&ref=$ref&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&dis_Matjum=$dis_Matjum&sum_fine=$sum_fine&fine_total_amt=$fine_total_amt';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'No') {
        // print('result.toString() != No');
        for (var map in result) {
          CFinnancetransModel cFinnancetransModel =
              CFinnancetransModel.fromJson(map);
          setState(() {
            cFinn = cFinnancetransModel.docno;

            doctax = cFinnancetransModel.doctax;
          });
          // print('zzzzasaaa123454>>>>  $cFinn');
        }
        // setState(() {
        //   Invoic_selectAllSuccess.add(InvoiceModels[index].docno.toString());
        // });

        Insert_log.Insert_logs(
            'บัญชี', 'ประวัติวางบิล -->Excel อนุมัติ:$cFinn ');
        if (serpay_all == '0') {
          Navigator.pop(context, 'OK');
        } else {}

        setState(() async {
          dis_sum_Pakan = 0.00;
          dis_Pakan = 0;
          dis_matjum = 0;
          sum_matjum = 0.00;
          dis_sum_Matjum = 0.00;
          sum_tran_fine = 0;
          fine_total = 0;
          fine_total2 = 0;
          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          sum_disp = 0;

          _InvoiceModels.clear();
          _InvoiceHistoryModels.clear();
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> in_Trans_invoice_refnoPay_chack(
      index, Value_newDateY1, Value_newDatepay, serpay_all) async {
    var Times = DateFormat('HH:mm:ss').format(datex).toString();
    String? fileName_Slip_ = '';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = _InvoiceModels[index].cid;
    var qutser = '1';
    var sumdis = _InvoiceModels[index].amt_dis.toString();
    var sumdisp = 0.toString();
    var dateY = Value_newDatepay;
    var dateY1 = Value_newDateY1;
    var time = Times;
    //pamentpage == 0
    var dis_akan = dis_sum_Pakan.toString();
    var dis_Matjum = dis_sum_Matjum.toString();
    var payment1 = _InvoiceModels[index].total_dis.toString();
    var payment2 = '';
    var pSer1 = _InvoiceModels[index].payment_ser.toString();
    var pSer2 = paymentSer2;
    var ref = _InvoiceModels[index].docno;
    var sum_whta = sum_wht.toString();
    var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    var comment = '';
    var sum_fine = sum_tran_fine;
    var fine_total_amt = (fine_total + fine_total2);
    // var ren = preferences.getString('renTalSer');
    // var user = preferences.getString('ser');
    // var ciddoc = InvoiceModels[index].cid;
    // var qutser = '1';
    // var sumdis = '0';
    // var sumdisp = '0';
    // var dateY = Value_newDatepay;
    // var dateY1 = Value_newDateY1;
    // var time = Times;
    // //pamentpage == 0
    // var dis_akan = '0';
    // var dis_Matjum = '0';
    // var payment1 = InvoiceModels[index].total_dis.toString();
    // var payment2 = '0';
    // var pSer1 = InvoiceModels[index].payment_ser.toString();
    // var pSer2 = '0';
    // var ref = InvoiceModels[index].docno;
    // var sum_whta = '0';
    // var bill = bills_name_ == 'บิลธรรมดา' ? 'P' : 'F';
    // var comment = '0';
    // var sum_fine = '0';
    // var fine_total_amt = (fine_total + fine_total2);
    // print('in_Trans_invoice_refno()///$fileName_Slip_');
    // print('in_Trans_invoice_refno >>> $payment1  $payment2  $bill ');
    // print('Docno InvoiceModels 2 >>>>> ${InvoiceModels[index].docno}');
    String url =
        '${MyConstant().domain}/In_tran_finanref1.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&dateY=$dateY&dateY1=$dateY1&time=$time&payment1=$payment1&payment2=$payment2&pSer1=$pSer1&pSer2=$pSer2&ref=$ref&sum_whta=$sum_whta&bill=$bill&fileNameSlip=$fileName_Slip_&comment=$comment&dis_Pakan=$dis_akan&dis_Matjum=$dis_Matjum&sum_fine=$sum_fine&fine_total_amt=$fine_total_amt';

    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'No') {
        // print('result.toString() != No');
        for (var map in result) {
          CFinnancetransModel cFinnancetransModel =
              CFinnancetransModel.fromJson(map);
          setState(() {
            cFinn = cFinnancetransModel.docno;

            doctax = cFinnancetransModel.doctax;
          });
          // print('zzzzasaaa123454>>>>  $cFinn');
        }
        // setState(() {
        //   Invoic_selectAllSuccess.add(InvoiceModels[index].docno.toString());
        // });

        Insert_log.Insert_logs(
            'บัญชี', 'ประวัติวางบิล -->Excel อนุมัติ:$cFinn ');
        // if (serpay_all == '0') {
        //   Navigator.pop(context, 'OK');
        // } else {}

        // setState(() async {
        //   dis_sum_Pakan = 0.00;
        //   dis_Pakan = 0;
        //   dis_matjum = 0;
        //   sum_matjum = 0.00;
        //   dis_sum_Matjum = 0.00;
        //   sum_tran_fine = 0;
        //   fine_total = 0;
        //   fine_total2 = 0;
        //   sum_pvat = 0.00;
        //   sum_vat = 0.00;
        //   sum_wht = 0.00;
        //   sum_amt = 0.00;
        //   sum_dis = 0.00;
        //   sum_disamt = 0.00;
        //   sum_disp = 0;

        //   _InvoiceModels.clear();
        //   _InvoiceHistoryModels.clear();
        // });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }
}
