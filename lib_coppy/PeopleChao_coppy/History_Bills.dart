// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, duplicate_import, must_be_immutable, body_might_complete_normally_nullable
import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/PeopleChao/Pays_.dart';
import 'package:chaoperty/main.dart';
import 'package:chaoperty_floating_loader/chaoperty_floating_loader.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_multi_formatter/formatters/masked_input_formatter.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../Beam/webviewPay_beamcheckout.dart';
import '../ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../PDF/PDF_Receipt/pdf_AC_his_statusbill.dart';
import '../PDF_TP2/PDF_Receipt_TP2/pdf_AC_his_statusbill_TP2.dart';
import '../PDF_TP3/PDF_Receipt_TP3/pdf_AC_his_statusbill_TP3.dart';
import '../PDF_TP4/PDF_Receipt_TP4/pdf_AC_his_statusbill_TP4.dart';
import '../PDF_TP5/PDF_Receipt_TP5/pdf_AC_his_statusbill_TP5.dart';
import '../PDF_TP6/PDF_Receipt_TP6/pdf_AC_his_statusbill_TP6.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'package:provider/provider.dart';

import '../Style/downloadImage.dart';

class HistoryBills extends StatefulWidget {
  final Get_Value_NameShop_index;
  final Get_Value_cid;
  const HistoryBills({
    super.key,
    this.Get_Value_NameShop_index,
    this.Get_Value_cid,
  });

  @override
  State<HistoryBills> createState() => _HistoryBillsState();
}

class _HistoryBillsState extends State<HistoryBills> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<TransBillModel> _TransBillModels = [];
  List<TransModel> _TransModels = [];
  List<TransReBillModel> _TransReBillModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<InvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<TransReBillHistoryModel> _TransReBillHistoryModels = [];
  List<PayMentModel> _PayMentModels = [];
  List<FinnancetransModel> finnancetransModels = [];
  List<RenTalModel> renTalModels = [];
  List<TeNantModel> teNantModels = [];
  // final sum_disamtx = TextEditingController();
  // final sum_dispx = TextEditingController();
  final Form_payment1 = TextEditingController();
  final Form_payment2 = TextEditingController();
  final Form_time = TextEditingController();

  final new_dereee = TextEditingController();
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      total_amt = 0.00,
      sum_disp = 0,
      dis_sum_Matjum = 0.00,
      sum_vat_up = 0.00,
      sum_pvat_up = 0.00,
      sum_duesbill = 0.00,
      sum_dislist = 0;

  int select_page = 0,
      pamentpage = 0,
      renTal_lavel = 0; // = 0 _TransModels : = 1 _InvoiceHistoryModels
  int? Cancell_bill = 0, Day_Cancell_bill = 0;
  String? dtypeselect,
      round_p,
      fin_datex,
      rental_ser,
      rental_degree_up,
      ciddoc_up,
      qutser_up,
      docnoin_up;
  String? numinvoice,
      Slip_history,
      numdoctax,
      paymentSer1,
      paymentName1,
      paymentSer2,
      paymentName2,
      Value_newDateY = '',
      Value_newDateD = '',
      Value_newDateY1 = '',
      Value_newDateD1 = '';
  DateTime newDatetime = DateTime.now();
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
      renTal_name,
      tem_page_ser,
      room_number_BillHistory,
      pdate;
  String? Form_nameshop,
      Form_typeshop,
      Form_bussshop,
      Form_bussscontact,
      Form_address,
      Form_tel,
      Form_email,
      Form_tax;
  String? ref1, ref2, ref_id;

  ///------------------------>
  int indexbill = 0, select_meter = 0, open_dislis = 0;

  ///------------------------>
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'คู่ฉบับ',
    'สำเนา',
    'สำเนาคู่ฉบับ',
  ];
  int TitleType_Default_Receipt = 0;
  String? dtype_tep = 'KP';
  @override
  void initState() {
    super.initState();
    red_Trans_bill();
    read_GC_rental();
    read_data();
    // sum_disamtx.text = '0.00';
    Value_newDateY1 = DateFormat('yyyy-MM-dd').format(newDatetime);
    Value_newDateD1 = DateFormat('dd-MM-yyyy').format(newDatetime);
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
          var serx = renTalModel.ser;
          var degree_upx = renTalModel.degree_up;
          setState(() {
            rental_degree_up = degree_upx;
            renTal_lavel = int.parse(preferences.getString('lavel').toString());
            rental_ser = serx;
            Cancell_bill = int.parse(renTalModel.cancell_bill!);
            Day_Cancell_bill = int.parse(renTalModel.day_cancell_bill!);
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
    } catch (e) {}
    //print('name>>>>>  $renname');
  }

  Future<Null> read_data() async {
    if (teNantModels.length != 0) {
      setState(() {
        teNantModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      if (result != null) {
        for (var map in result) {
          TeNantModel teNantModel = TeNantModel.fromJson(map);
          setState(() {
            teNantModels.add(teNantModel);

            Form_nameshop = teNantModel.sname.toString();
            Form_typeshop = teNantModel.stype.toString();
            Form_bussshop = teNantModel.cname.toString();
            Form_bussscontact = teNantModel.attn.toString();
            Form_address = teNantModel.addr.toString();
            Form_tel = teNantModel.tel.toString();
            Form_email = teNantModel.email.toString();
            Form_tax =
                teNantModel.tax == null ? "-" : teNantModel.tax.toString();
          });
        }
      }
    } catch (e) {}
  }

  ///---------------------------------------------------------------------->
  double getTotalByField(
    List<TransReBillHistoryModel> trans,
    String? Function(TransReBillHistoryModel item) getter,
  ) {
    return trans.fold(0.0, (sum, item) {
      final value = double.tryParse(getter(item) ?? '0.00') ?? 0.00;
      return sum + value;
    });
  }

  ///---------------------------------------------------------------------->
  Future<void> red_Trans_bill() async {
    if (_TransReBillModels.isNotEmpty) {
      setState(() {
        _TransReBillModels.clear();
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer');
    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;

    final url =
        '${MyConstant().domain}/GC_bill_pay.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    // //print('📥 Fetching bills from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        //print('📌 Loaded result for cid: $result');

        if (result != null && result is List) {
          final List<TransReBillModel> loadedBills = [];

          for (var map in result) {
            final transReBillModel = TransReBillModel.fromJson(map);

            // ✅ เงื่อนไข filter dtype ถ้าต้องการใช้
            if (transReBillModel.dtype.toString() == dtype_tep) {
              loadedBills.add(transReBillModel);
            }
          }

          setState(() {
            _TransReBillModels.addAll(loadedBills);
          });

          //print('✅ Total loaded: ${_TransReBillModels.length}');
        } else {
          //print('⚠️ ไม่มีข้อมูล result หรือไม่ใช่ List');
        }
      } else {
        //print('❌ HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      //print('❌ Exception in red_Trans_bill: $e');
    }
  }

  String Remark_ = '';

  Future<Null> red_Invoice(index) async {
    if (finnancetransModels.length != 0) {
      setState(() {
        finnancetransModels.clear();
        sum_disamt = 0;
        sum_disp = 0;
        dis_sum_Matjum = 0.00;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = _TransReBillModels[index].ser;
    var qutser = _TransReBillModels[index].ser_in;
    var docnoin = _TransReBillModels[index].docno; //.toString().trim()
    //print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      //print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
            ref_id = finnancetransModel.ref1;
            ref1 = finnancetransModel.ref2;
            ref2 = finnancetransModel.ref4;

            Slip_history = finnancetransModel.slip.toString();
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
          if (finnancetransModel.dtype! == 'MM') {
            setState(() {
              dis_sum_Matjum =
                  dis_sum_Matjum + double.parse(finnancetransModel.amt!);
            });
          }
          if (finnancetransModel.dtype! == 'FTA') {
            setState(() {
              sum_duesbill = double.parse(finnancetransModel.amt!);
            });
          }
          //print(
          //'>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
  }

  // Future<Null> red_Invoice_up() async {
  //   if (finnancetransModels.length != 0) {
  //     setState(() {
  //       finnancetransModels.clear();
  //       sum_disamt = 0;
  //       sum_disp = 0;
  //       dis_sum_Matjum = 0.00;
  //     });
  //   }

  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var ciddoc = ciddoc_up;
  //   var qutser = qutser_up;
  //   var docnoin = docnoin_up; //.toString().trim()
  //   //print('>>>>>>>>>>>dd>>> in d  $docnoin');

  //   String url =
  //       '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
  //   try {
  //     var response = await http.get(Uri.parse(url));
  //     var result = json.decode(response.body);
  //     //print('BBBBBBBBBBBBBBBB>>>> $result');
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         FinnancetransModel finnancetransModel =
  //             FinnancetransModel.fromJson(map);

  //         var sidamt = double.parse(finnancetransModel.amt!);
  //         var siddisper = double.parse(finnancetransModel.disper!);
  //         var pdatex = finnancetransModel.pdate;

  //         setState(() {
  //           Slip_history = finnancetransModel.slip.toString();
  //           if (int.parse(finnancetransModel.receiptSer!) != 0) {
  //             finnancetransModels.add(finnancetransModel);
  //             pdate = pdatex;
  //           } else {
  //             if (finnancetransModel.type!.trim() == 'DISCOUNT') {
  //               sum_disamt = sidamt;
  //               sum_disp = siddisper;
  //             }
  //           }
  //         });
  //         if (finnancetransModel.dtype! == 'MM') {
  //           setState(() {
  //             dis_sum_Matjum =
  //                 dis_sum_Matjum + double.parse(finnancetransModel.amt!);
  //           });
  //         }
  //         //print(
  //             '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
  //       }
  //     }
  //   } catch (e) {}
  // }

  // Future<Null> red_Invoice(index) async {
  //   if (finnancetransModels.length != 0) {
  //     setState(() {
  //       finnancetransModels.clear();
  //       sum_disamt = 0;
  //       sum_disp = 0;
  //     });
  //   }

  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;
  //   var docnoin = _TransReBillModels[index].docno;
  //   //print('>>>>>>>>>>>dd>>> in d  $docnoin');

  //   String url =
  //       '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
  //   try {
  //     var response = await http.get(Uri.parse(url));
  //     var result = json.decode(response.body);
  //     //print('BBBBBBBBBBBBBBBB>>>> $result');
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         FinnancetransModel finnancetransModel =
  //             FinnancetransModel.fromJson(map);

  //         var sidamt = double.parse(finnancetransModel.amt!);
  //         var siddisper = double.parse(finnancetransModel.disper!);
  //         //print('>>>>>>>>>>>dd>>> in $sidamt $siddisper');
  //         setState(() {
  //           Slip_history = finnancetransModel.slip;
  //           if (int.parse(finnancetransModel.receiptSer!) != 0) {
  //             finnancetransModels.add(finnancetransModel);
  //           } else {
  //             if (finnancetransModel.type!.trim() == 'DISCOUNT') {
  //               sum_disamt = sidamt;
  //               sum_disp = siddisper;
  //             }
  //           }
  //         });
  //       }
  //     }
  //   } catch (e) {}
  // }

  // Future<Null> red_InvoiceC() async {
  //   if (_TransReBillModels.length != 0) {
  //     setState(() {
  //       _TransReBillModels.clear();
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;

  //   String url =
  //       '${MyConstant().domain}/GC_re_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser}';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(result);
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         TransReBillModel _TransReBillModel = TransReBillModel.fromJson(map);
  //         setState(() {
  //           _TransReBillModels.add(_TransReBillModel);
  //         });
  //       }
  //     }
  //   } catch (e) {}
  // }

  // Future<Null> in_Trans_select(index) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;

  //   var tser = _TransBillModels[index].ser;
  //   var tdocno = _TransBillModels[index].docno;

  //   //print('object $tdocno');
  //   String url =
  //       '${MyConstant().domain}/In_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(result);
  //     if (result.toString() == 'true') {
  //       setState(() {
  //         red_Trans_select2();
  //       });
  //       //print('rrrrrrrrrrrrrr');
  //     }
  //   } catch (e) {}
  // }

  // Future<Null> deall_Trans_select() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;

  //   String url =
  //       '${MyConstant().domain}/D_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(result);
  //     if (result.toString() == 'true') {
  //       setState(() {
  //         red_Trans_select2();
  //       });
  //       //print('rrrrrrrrrrrrrr');
  //     }
  //   } catch (e) {}
  // }

  // Future<Null> red_Trans_select2() async {
  //   if (_TransModels.length != 0) {
  //     setState(() {
  //       _TransModels.clear();
  //       sum_pvat = 0;
  //       sum_vat = 0;
  //       sum_wht = 0;
  //       sum_amt = 0;
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;

  //   String url =
  //       '${MyConstant().domain}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(result);
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         TransModel _TransModel = TransModel.fromJson(map);

  //         var sum_pvatx = double.parse(_TransModel.pvat!);
  //         var sum_vatx = double.parse(_TransModel.vat!);
  //         var sum_whtx = double.parse(_TransModel.wht!);
  //         var sum_amtx = double.parse(_TransModel.total!);
  //         setState(() {
  //           sum_pvat = sum_pvat + sum_pvatx;
  //           sum_vat = sum_vat + sum_vatx;
  //           sum_wht = sum_wht + sum_whtx;
  //           sum_amt = sum_amt + sum_amtx;
  //           _TransModels.add(_TransModel);
  //         });
  //       }
  //     }
  //   } catch (e) {}
  // }

  // Future<Null> red_Trans_select_re(index) async {
  //   if (_TransReBillHistoryModels.length != 0) {
  //     setState(() {
  //       _TransReBillHistoryModels.clear();
  //       sum_pvat = 0;
  //       sum_vat = 0;
  //       sum_wht = 0;
  //       sum_amt = 0;
  //       sum_disamt = 0;
  //       sum_disp = 0; //_TransReBillModels
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;
  //   var docnoin = _TransReBillModels[index].docno;

  //   //print(
  //       'BBBBBBBBBBBB/... $docnoin == $ciddoc  ${_TransReBillHistoryModels.length}');

  //   String url =
  //       '${MyConstant().domain}/GC_re_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // //print(result);
  //     if (result.toString() != 'null') {
  //       //print('result1111');
  //       for (var map in result) {
  //         //print('result2222');
  //         TransReBillHistoryModel _TransReBillHistoryModel =
  //             TransReBillHistoryModel.fromJson(map);

  //         var sum_pvatx = double.parse(_TransReBillHistoryModel.pvat!);
  //         var sum_vatx = double.parse(_TransReBillHistoryModel.vat!);
  //         var sum_whtx = double.parse(_TransReBillHistoryModel.wht!);
  //         var sum_amtx = double.parse(_TransReBillHistoryModel.total!);
  //         var sum_disamtx = _TransReBillHistoryModel.disend == null
  //             ? 0.00
  //             : double.parse(_TransReBillHistoryModel.disend!);
  //         var sum_dispx = _TransReBillHistoryModel.disendbillper == null
  //             ? 0.00
  //             : double.parse(_TransReBillHistoryModel.disendbillper!);
  //         //print('${_TransReBillHistoryModel.name}');
  //         setState(() {
  //           sum_pvat = sum_pvat + sum_pvatx;
  //           sum_vat = sum_vat + sum_vatx;
  //           sum_wht = sum_wht + sum_whtx;
  //           sum_amt = sum_amt + sum_amtx;
  //           sum_disamt = sum_disamtx;
  //           sum_disp = sum_dispx;
  //           numinvoice = _TransReBillHistoryModel.docno;
  //           _TransReBillHistoryModels.add(_TransReBillHistoryModel);
  //         });
  //       }
  //       //print(_TransReBillHistoryModels.length);
  //     }
  //   } catch (e) {}
  // }
/////////////------------------------------------------------>
  //-------------------------------------->
  Future<void> red_Trans_select(int index_x, {required String dtype}) async {
    if (_TransReBillHistoryModels.isNotEmpty) {
      if (mounted) {
        setState(() {
          _TransReBillHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
        });
      }
    }

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var ren = preferences.getString('renTalSer');
      var user = preferences.getString('ser');
      var ciddoc = widget.Get_Value_cid;
      // var ciddocs = _TransReBillModels[index_x].cid;
      var docnoins = _TransReBillModels[index_x].docno;
      var doctaxs = _TransReBillModels[index_x].doctax;
      var dType = dtype ?? "KP";
      setState(() {
        numinvoice = docnoins;
        numdoctax = doctaxs;
      });
      String url =
          '${MyConstant().domain}/GC_billPay_history_v2.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoins&dtype=$dType';
      // //print('📥 red_Trans_select URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result.toString() != 'null') {
          List<TransReBillHistoryModel> tempHistory = [];

          for (var map in result) {
            final model = TransReBillHistoryModel.fromJson(map);
            tempHistory.add(model);
            // paper_run = model.paper_run;
          }

          if (mounted) {
            setState(() {
              _TransReBillHistoryModels.addAll(tempHistory);
            });
          }
        } else {
          //print('⚠️ ไม่พบข้อมูลใบเสร็จ');
        }
      } else {
        //print('❌ HTTP Error: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      //print('❌ Exception in red_Trans_select2: $e');
      // //print('🧱 Stack: $stackTrace'); // Uncomment ถ้าต้องการ debug เพิ่มเติม
    }

    //print(
    //   '✅ red_Trans_select Loaded: ${_TransReBillHistoryModels.length} รายการ');

    // _ReportValue_type =
    //     TitleType_Default_Receipt_[int.tryParse(paper.toString()) ?? 0];
    // TitleType_Default_Receipt_Name = _ReportValue_type;
  }

  // Future<Null> red_Trans_select(index) async {
  //   if (_TransReBillHistoryModels.length != 0) {
  //     setState(() {
  //       _TransReBillHistoryModels.clear();
  //       sum_pvat = 0;
  //       sum_vat = 0;
  //       sum_wht = 0;
  //       sum_amt = 0;
  //       total_amt = 0.00;
  //       // sum_disamt = 0;
  //       // sum_disp = 0;
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;
  //   var docnoin = _TransReBillModels[index].docno;

  //   String url =
  //       '${MyConstant().domain}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
  //   //print(url);
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print('GC_bill_pay_history>>>> $result');
  //     if (result.toString() != 'null') {
  //       for (var map in result) {
  //         TransReBillHistoryModel _TransReBillHistoryModel =
  //             TransReBillHistoryModel.fromJson(map);
  //         var dtypeinvoiceent = _TransReBillHistoryModel.dtype;
  //         var sum_pvatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
  //             ? double.parse(_TransReBillHistoryModel.dis!) != 0
  //                 ? double.parse(_TransReBillHistoryModel.pvat!) -
  //                     double.parse(_TransReBillHistoryModel.dis!)
  //                 : double.parse(_TransReBillHistoryModel.pvat!)
  //             : 0.0;
  //         var sum_vatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
  //             ? double.parse(_TransReBillHistoryModel.vat!)
  //             : 0.0;
  //         var sum_whtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
  //             ? double.parse(_TransReBillHistoryModel.wht!)
  //             : 0.0;
  //         var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
  //             ? double.parse(_TransReBillHistoryModel.dis!) != 0
  //                 ? double.parse(_TransReBillHistoryModel.total!) -
  //                     double.parse(_TransReBillHistoryModel.vat!)
  //                 : double.parse(_TransReBillHistoryModel.total!)
  //             : 0.0;

  //         var total_amtx = dtypeinvoiceent != 'KP' || dtypeinvoiceent != '!Z'
  //             ? double.parse(_TransReBillHistoryModel.total!)
  //             : 0.0;
  //         // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
  //         // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
  //         var numinvoiceent = _TransReBillHistoryModel.docno;
  //         var round_px = _TransReBillHistoryModel.round_p;
  //         var sum_vat_upx = double.parse(_TransReBillHistoryModel.vat_up!);
  //         var sum_pvat_upx = double.parse(_TransReBillHistoryModel.amt_up!);
  //         var fin_datexx = _TransReBillHistoryModel.datex;

  //         setState(() {
  //           round_p = round_px;
  //           fin_datex = fin_datexx;
  //           sum_vat_up = sum_vat_upx;
  //           sum_pvat_up = sum_pvat_upx;
  //           if (dtypeinvoiceent == 'KP') {
  //             sum_pvat = sum_pvat + sum_pvatx;
  //             sum_vat = sum_vat + sum_vatx;
  //             sum_wht = sum_wht + sum_whtx;
  //             sum_amt = sum_amt + sum_amtx;
  //             // sum_disamt = sum_disamtx;
  //             // sum_disp = sum_dispx;
  //             numinvoice = _TransReBillHistoryModel.docno;
  //             numdoctax = _TransReBillHistoryModel.doctax;

  //             _TransReBillHistoryModels.add(_TransReBillHistoryModel);
  //           } else if (dtypeinvoiceent == '!Z') {
  //             sum_pvat = sum_pvat + sum_pvatx;
  //             sum_vat = sum_vat + sum_vatx;
  //             sum_wht = sum_wht + sum_whtx;
  //             sum_amt = sum_amt + sum_amtx;
  //             // sum_disamt = sum_disamtx;
  //             // sum_disp = sum_dispx;
  //             numinvoice = _TransReBillHistoryModel.docno;
  //             numdoctax = _TransReBillHistoryModel.doctax;

  //             _TransReBillHistoryModels.add(_TransReBillHistoryModel);
  //           } else {
  //             total_amt = total_amt + total_amtx;

  //             _TransReBillHistoryModels.add(_TransReBillHistoryModel);
  //           }
  //         });
  //       }
  //     }
  //     // //print('fin_datex>>>>  $fin_datex $round_p $sum_vat_up $sum_pvat_up');
  //     // setState(() {
  //     //   red_Invoice();
  //     // });
  //   } catch (e) {}
  //   //print(
  //       '_TransReBillHistoryModels.length >>>> ${_TransReBillHistoryModels.length}');
  // }

  Future<Null> red_Trans_select_up() async {
    if (_TransReBillHistoryModels.length != 0) {
      setState(() {
        _TransReBillHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        total_amt = 0.00;
        // sum_disamt = 0;
        // sum_disp = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    var docnoin = docnoin_up;

    String url =
        '${MyConstant().domain}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    //print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      //print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillHistoryModel _TransReBillHistoryModel =
              TransReBillHistoryModel.fromJson(map);
          var dtypeinvoiceent = _TransReBillHistoryModel.dtype;
          var sum_pvatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.dis!) != 0
                  ? double.parse(_TransReBillHistoryModel.pvat!) -
                      double.parse(_TransReBillHistoryModel.dis!)
                  : double.parse(_TransReBillHistoryModel.pvat!)
              : 0.0;
          var sum_vatx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.vat!)
              : 0.0;
          var sum_whtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.wht!)
              : 0.0;
          // var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
          //     ? double.parse(_TransReBillHistoryModel.dis!) != 0
          //         ? double.parse(_TransReBillHistoryModel.total!) -
          //             double.parse(_TransReBillHistoryModel.vat!)
          //         : double.parse(_TransReBillHistoryModel.total!)
          //     : 0.0;

          var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.dis!) != 0
                  ? double.parse(_TransReBillHistoryModel.pvat!) +
                      double.parse(_TransReBillHistoryModel.vat!) -
                      double.parse(_TransReBillHistoryModel.wht!) -
                      double.parse(_TransReBillHistoryModel.disendbill!)
                  : double.parse(_TransReBillHistoryModel.total!)
              : 0.0;

          var total_amtx = dtypeinvoiceent != 'KP' || dtypeinvoiceent != '!Z'
              ? double.parse(_TransReBillHistoryModel.total!)
              : 0.0;
          // var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          // var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          var numinvoiceent = _TransReBillHistoryModel.docno;
          var round_px = _TransReBillHistoryModel.round_p;
          var sum_vat_upx = double.parse(_TransReBillHistoryModel.vat_up!);
          var sum_pvat_upx = double.parse(_TransReBillHistoryModel.amt_up!);
          var fin_datexx = _TransReBillHistoryModel.datex;

          setState(() {
            round_p = round_px;
            fin_datex = fin_datexx;
            sum_vat_up = sum_vat_upx;
            sum_pvat_up = sum_pvat_upx;
            if (dtypeinvoiceent == 'KP') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;

              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else if (dtypeinvoiceent == '!Z') {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              // sum_disamt = sum_disamtx;
              // sum_disp = sum_dispx;
              numinvoice = _TransReBillHistoryModel.docno;
              numdoctax = _TransReBillHistoryModel.doctax;

              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            } else {
              total_amt = total_amt + total_amtx;

              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            }
          });
        }
      }
      // //print('fin_datex>>>>  $fin_datex $round_p $sum_vat_up $sum_pvat_up');
      // setState(() {
      //   red_Invoice();
      // });
    } catch (e) {}
  }
///////////------------------------------------------->
  // Future<Null> red_Trans_selectde() async {
  //   if (_InvoiceHistoryModels.length != 0) {
  //     setState(() {
  //       _InvoiceHistoryModels.clear();
  //       sum_pvat = 0;
  //       sum_vat = 0;
  //       sum_wht = 0;
  //       sum_amt = 0;
  //       sum_disamt = 0;
  //       sum_disp = 0;
  //     });
  //   }
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;
  //   var docnoin = numinvoice;

  //   //print('object11');

  //   String url =
  //       '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(result);
  //     //print('object22');
  //     if (result.toString() != 'null') {
  //       //print('object33');
  //       for (var map in result) {
  //         //print('object44');
  //         InvoiceHistoryModel _InvoiceHistoryModel =
  //             InvoiceHistoryModel.fromJson(map);

  //         var sum_pvatx = double.parse(_InvoiceHistoryModel.pvat_t!);
  //         var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
  //         var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
  //         var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
  //         var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
  //         var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
  //         setState(() {
  //           sum_pvat = sum_pvat + sum_pvatx;
  //           sum_vat = sum_vat + sum_vatx;
  //           sum_wht = sum_wht + sum_whtx;
  //           sum_amt = sum_amt + sum_amtx;
  //           sum_disamt = sum_disamtx;
  //           sum_disp = sum_dispx;
  //           numinvoice = _InvoiceHistoryModel.docno;
  //           _InvoiceHistoryModels.add(_InvoiceHistoryModel);
  //         });
  //       }
  //     }
  //   } catch (e) {}
  // }

  String bills_name_ = '';
  List bills_name = [
    'บิลปกติ',
    'บิลเต็มรูปแบบ',
  ];
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();

  ///----------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 150,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 150,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 150,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 150,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  final Set<int> _pressedIndices = Set();

  ///----------------->
  Widget _segmentTab({
    required BuildContext context,
    required bool active,
    required Color activeColor,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: active
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      activeColor.withOpacity(.95),
                      activeColor.withOpacity(.80),
                      activeColor.withOpacity(.60),
                    ],
                  )
                : null,
            color: active ? null : Colors.white,
            boxShadow: active
                ? [
                    BoxShadow(
                        color: activeColor.withOpacity(.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6))
                  ]
                : [
                    BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
            border: Border.all(
                color: active ? Colors.transparent : const Color(0xFFE6E6E6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: active ? Colors.white : Colors.black87),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : PeopleChaoScreen_Color.Colors_Text1_,
                  fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- ตัวช่วยเล็กๆ (ไม่ใช่ class) ----------
  Widget _hdrCell(
    String text, {
    int flex = 1,
    double? width,
    TextAlign align = TextAlign.center,
    bool rightBorder = true,
    VoidCallback? onTap, // เผื่อคลิก sort ได้ในอนาคต
  }) {
    final label = AutoSizeText(
      text,
      minFontSize: 11,
      maxFontSize: 16,
      maxLines: 1,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: PeopleChaoScreen_Color.Colors_Text1_,
        fontWeight: FontWeight.w700,
        fontFamily: FontWeight_.Fonts_T,
        letterSpacing: .2,
      ),
    );

    final box = Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade200, Colors.brown.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: const BorderSide(color: Colors.black12, width: .8),
          right: rightBorder
              ? const BorderSide(color: Colors.white30, width: .8)
              : BorderSide.none,
        ),
      ),
      child: Center(child: label),
    );

    final child = onTap == null
        ? box
        : InkWell(
            onTap: onTap,
            hoverColor: Colors.black12,
            child: box,
          );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

// ---------- หัวตารางแบบสวยขึ้น ----------
  Widget billHeaderTable(BuildContext context, {required String docno}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0)),
        // borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Colors.black12),
        ],
      ),
      clipBehavior: Clip.antiAlias, // ให้มุมมนทำงานกับ ripple
      child: Column(
        children: [
          // แถบหัว "รายละเอียดบิล" — โค้งมน + เงาเบาๆ

          Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[100]!, Colors.orange[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // SizedBox(width: 12),
                // Icon(Icons.receipt_long,
                //     size: 20, color: PeopleChaoScreen_Color.Colors_Text1_),
                // SizedBox(width: 8),
                Expanded(
                  child: AutoSizeText(
                    (docno == null || docno == 'null' || docno == '')
                        ? 'รายละเอียดบิล'
                        : dtypeselect == '!Z'
                            ? 'รายละเอียดบิล (ยกเลิก) ${docno ?? ''}'
                            : 'รายละเอียดบิล ${docno ?? ''}', //numinvoice
                    // invoice == ''
                    //     ? 'รายละเอียดบิล'
                    //     : 'รายละเอียดใบแจ้งหนี้ ${numinvoice ?? ''}',
                    // 'รายละเอียดบิล',
                    minFontSize: 12,
                    maxFontSize: 18,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: PeopleChaoScreen_Color.Colors_Text1_,
                      fontWeight: FontWeight.bold,
                      fontFamily: FontWeight_.Fonts_T,
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
            ),
          ),

          // หัวคอลัมน์ (ใช้ gradient อ่อน + เส้นแบ่ง)
          Row(
            children: [
              // _hdrCell('ลำดับ', width: 56),
              _hdrCell('วันที่ตั้งหนี้', flex: 1, align: TextAlign.left),
              _hdrCell('เลขที่ตั้งหนี้', flex: 1, align: TextAlign.left),
              _hdrCell('รายการ', flex: 2),
              _hdrCell('จำนวน', flex: 1, align: TextAlign.right),
              // _hdrCell('หน่วย', flex: 1, align: TextAlign.right),
              _hdrCell('ก่อนVAT', flex: 1, align: TextAlign.right),
              _hdrCell('VAT', flex: 1, align: TextAlign.right),
              _hdrCell('WHT', flex: 1, align: TextAlign.right),
              _hdrCell('ยอดสุทธิ',
                  flex: 1, align: TextAlign.right, rightBorder: false),
              // if (invoice == '')
              //   _hdrIconCell(
              //     icon: Icons.close_rounded,
              //     width: 44,
              //     tooltip: 'ล้างการเลือก',
              //     onTap: () {
              //       deall_Trans_select();
              //       setState(() {
              //         dis_sum_Pakan = 0.00;
              //         dis_Pakan = 0;
              //         dis_matjum = 0;
              //         sum_matjum = 0.00;
              //         dis_sum_Matjum = 0.00;
              //       });
              //     },
              //   ),
            ],
          ),
        ],
      ),
    );
  }

  ///----------------->
  @override
  Widget build(BuildContext context) {
    final isOpen =
        context.watch<SidebarController>().isOpen; // ← อ่านสถานะข้ามหน้า
    // final w = MediaQuery.of(context).size.width;
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          // ถ้า AdminScaffold "ไม่ตัด sidebar ให้" ต้องลบเอง
          final viewportW = Responsive.isDesktop(context)
              ? (isOpen
                  ? constraints.maxWidth - 295
                  : constraints.maxWidth - 260)
              : 1200.00;

          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            }),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              dragStartBehavior: DragStartBehavior.start,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: viewportW),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: SizedBox(
                    width: viewportW *
                        1.2, // 👈 บังคับให้ Row มีความกว้างแน่นอน (มากกว่าจอ → เลื่อนได้)
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              constraints: BoxConstraints(
                                maxWidth: (Responsive.isDesktop(context))
                                    ? MediaQuery.of(context).size.width / 3.5
                                    : MediaQuery.of(context).size.width / 2.2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 18,
                                      color: Colors.black.withOpacity(.06),
                                      offset: const Offset(0, 2))
                                ],
                                border: Border.all(
                                    color: Colors.grey.shade400, width: 0.5),
                              ),
                              child: Column(children: [
                                Container(
                                  height: 52,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    // color: Color(0xFFF7F7F7),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange[100]!,
                                        Colors.orange[300]!
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(14)),
                                  ),
                                  child: Row(
                                    children: [
                                      _segmentTab(
                                        context: context,
                                        active: select_meter == 0,
                                        activeColor: Colors.brown.shade800,
                                        // activeColor: Colors.grey.shade800,
                                        icon: Icons.payments,
                                        label: 'รายการรับชำระ',
                                        onTap: () async {
                                          if (select_meter == 0) return;
                                          setState(() => select_meter = 0);
                                          setState(() {
                                            _InvoiceModels.clear();
                                            _InvoiceHistoryModels.clear();
                                            _TransReBillHistoryModels.clear();
                                            numinvoice = null;
                                            numdoctax = null;
                                            // sum_disamtx.text = '0.00';
                                            // sum_dispx.text = '0.00';
                                            sum_pvat = 0.00;
                                            sum_vat = 0.00;
                                            sum_wht = 0.00;
                                            sum_amt = 0.00;
                                            sum_dis = 0.00;
                                            sum_disamt = 0.00;
                                            sum_disp = 0;
                                            select_page = 0;
                                            dtype_tep = 'KP';
                                          });
                                          red_Trans_bill();
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      _segmentTab(
                                        context: context,
                                        active: select_meter == 1,
                                        activeColor: Colors.brown.shade800,
                                        // activeColor: Colors.lightBlue.shade500,
                                        icon: Icons.stop_circle,
                                        label: 'รายการยกเลิกรับชำระ',
                                        onTap: () async {
                                          if (select_meter == 1) return;
                                          setState(() => select_meter = 1);
                                          setState(() {
                                            _InvoiceModels.clear();
                                            _InvoiceHistoryModels.clear();
                                            _TransReBillHistoryModels.clear();
                                            numinvoice = null;
                                            numdoctax = null;
                                            // sum_disamtx.text = '0.00';
                                            // sum_dispx.text = '0.00';
                                            sum_pvat = 0.00;
                                            sum_vat = 0.00;
                                            sum_wht = 0.00;
                                            sum_amt = 0.00;
                                            sum_dis = 0.00;
                                            sum_disamt = 0.00;
                                            sum_disp = 0;
                                            select_page = 0;
                                            dtype_tep = '!Z';
                                          });
                                          red_Trans_bill();
                                        },
                                      ),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(0.0),
                                      //     child: GestureDetector(
                                      //       onTap: () async {
                                      //         setState(() {
                                      //           _InvoiceModels.clear();
                                      //           _InvoiceHistoryModels.clear();
                                      //           _TransReBillHistoryModels.clear();
                                      //           numinvoice = null;
                                      //           numdoctax = null;
                                      //           // sum_disamtx.text = '0.00';
                                      //           // sum_dispx.text = '0.00';
                                      //           sum_pvat = 0.00;
                                      //           sum_vat = 0.00;
                                      //           sum_wht = 0.00;
                                      //           sum_amt = 0.00;
                                      //           sum_dis = 0.00;
                                      //           sum_disamt = 0.00;
                                      //           sum_disp = 0;
                                      //           select_page = 0;
                                      //           dtype_tep = 'KP';
                                      //         });
                                      //         red_Trans_bill();
                                      //       },
                                      //       child: Container(
                                      //         height: 50,
                                      //         decoration: BoxDecoration(
                                      //           color: Colors.yellow[200],
                                      //           borderRadius:
                                      //               const BorderRadius.only(
                                      //             topLeft: Radius.circular(6),
                                      //             topRight: Radius.circular(0),
                                      //             bottomLeft: Radius.circular(0),
                                      //             bottomRight: Radius.circular(0),
                                      //           ),
                                      //           border: dtype_tep != 'KP'
                                      //               ? null
                                      //               : Border.all(
                                      //                   color: Colors.grey,
                                      //                   width: 1),
                                      //         ),
                                      //         padding: const EdgeInsets.all(8.0),
                                      //         child: Center(
                                      //           child: Text(
                                      //             'รายการรับชำระ',
                                      //             textAlign: TextAlign.center,
                                      //             style: TextStyle(
                                      //                 color:
                                      //                     PeopleChaoScreen_Color
                                      //                         .Colors_Text1_,
                                      //                 fontWeight: FontWeight.bold,
                                      //                 fontFamily:
                                      //                     FontWeight_.Fonts_T
                                      //                 //fontSize: 10.0
                                      //                 ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(0.0),
                                      //     child: GestureDetector(
                                      //       onTap: () async {
                                      //         setState(() {
                                      //           _InvoiceModels.clear();
                                      //           _InvoiceHistoryModels.clear();
                                      //           _TransReBillHistoryModels.clear();
                                      //           numinvoice = null;
                                      //           numdoctax = null;
                                      //           // sum_disamtx.text = '0.00';
                                      //           // sum_dispx.text = '0.00';
                                      //           sum_pvat = 0.00;
                                      //           sum_vat = 0.00;
                                      //           sum_wht = 0.00;
                                      //           sum_amt = 0.00;
                                      //           sum_dis = 0.00;
                                      //           sum_disamt = 0.00;
                                      //           sum_disp = 0;
                                      //           select_page = 0;
                                      //           dtype_tep = '!Z';
                                      //         });
                                      //         red_Trans_bill();
                                      //       },
                                      //       child: Container(
                                      //         height: 50,
                                      //         decoration: BoxDecoration(
                                      //           color: Colors.orange[200],
                                      //           borderRadius:
                                      //               const BorderRadius.only(
                                      //             topLeft: Radius.circular(0),
                                      //             topRight: Radius.circular(6),
                                      //             bottomLeft: Radius.circular(0),
                                      //             bottomRight: Radius.circular(0),
                                      //           ),
                                      //           border: dtype_tep != '!Z'
                                      //               ? null
                                      //               : Border.all(
                                      //                   color: Colors.grey,
                                      //                   width: 1),
                                      //         ),
                                      //         padding: const EdgeInsets.all(8.0),
                                      //         child: Center(
                                      //           child: Text(
                                      //             'รายการยกเลิกรับชำระ',
                                      //             textAlign: TextAlign.center,
                                      //             style: TextStyle(
                                      //                 color:
                                      //                     PeopleChaoScreen_Color
                                      //                         .Colors_Text1_,
                                      //                 fontWeight: FontWeight.bold,
                                      //                 fontFamily:
                                      //                     FontWeight_.Fonts_T
                                      //                 //fontSize: 10.0
                                      //                 ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.brown.shade200,
                                        Colors.brown.shade100
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    border: Border(
                                      bottom: const BorderSide(
                                          color: Colors.black12, width: .8),
                                      // right: rightBorder
                                      //     ? const BorderSide(color: Colors.white30, width: .8)
                                      //     : BorderSide.none,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Center(
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'วันที่ทำรายการ',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Center(
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'วันที่ชำระ',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
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
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Center(
                                            child:
                                                Translate.TranslateAndSetText(
                                                    'เลขที่ใบเสร็จ',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Center(
                                            child:
                                                Translate.TranslateAndSetText(
                                                    dtype_tep != '!Z'
                                                        ? 'จำนวนเงิน'
                                                        : 'สถานะ',
                                                    PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    FontWeight_.Fonts_T,
                                                    14,
                                                    1),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    height: 545,
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
                                    child:
                                        // select_page == 0
                                        //     ?
                                        ListView.builder(
                                      controller: _scrollController1,
                                      // itemExtent: 50,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _TransReBillModels.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        String _fmtDate(String? d) {
                                          if (d == null || d.isEmpty) return '';
                                          try {
                                            return DateFormat('dd-MM-yyyy')
                                                .format(DateTime.parse(
                                                    '$d 00:00:00'));
                                          } catch (_) {
                                            return '';
                                          }
                                        }

                                        Color _rowBg(TransReBillModel m,
                                            String? numinvoice) {
                                          final sel = (m.docno?.toString() ==
                                                  numinvoice) ||
                                              (m.doctax?.toString() ==
                                                  numinvoice);
                                          if (sel)
                                            return tappedIndex_Color
                                                .tappedIndex_Colors;
                                          if (m.dtype == '!Z')
                                            return Colors.red.shade100
                                                .withOpacity(0.5);
                                          return AppbackgroundColor
                                              .Sub_Abg_Colors;
                                        }

                                        final m = _TransReBillModels[index];
                                        final docDisp = (m.doctax == null ||
                                                m.doctax!.isEmpty)
                                            ? (m.docno ?? '')
                                            : (m.doctax ?? '');

                                        return Material(
                                          color:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: _rowBg(
                                                  m, numinvoice?.toString()),
                                              border: const Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.3),
                                              ),
                                            ),
                                            child: ListTile(
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              onTap: () async {
                                                final dtype = (m.dtype == '!Z')
                                                    ? '!Z'
                                                    : 'KP';
                                                await red_Trans_select(index,
                                                    dtype: dtype);

                                                setState(() {
                                                  Remark_ = (m.dtype == '!Z')
                                                      ? (m.remark ?? '')
                                                      : (m.descr ?? '');
                                                  room_number_BillHistory = m
                                                          .room_number
                                                          ?.toString() ??
                                                      '';
                                                  ciddoc_up = m.ser;
                                                  qutser_up = m.ser_in;
                                                  docnoin_up = m.docno;
                                                  dtypeselect = m.dtype;
                                                });

                                                red_Invoice(index);
                                              },
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      _fmtDate(m.daterec),
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
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
                                                      _fmtDate(m.dateacc),
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Copy_Text(
                                                            context,
                                                            m.docno?.toString() ??
                                                                ''),
                                                        Expanded(
                                                          child: Tooltip(
                                                            richMessage:
                                                                TextSpan(
                                                              text: docDisp,
                                                              style:
                                                                  const TextStyle(
                                                                color: HomeScreen_Color
                                                                    .Colors_Text1_,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                                //fontSize: 10.0
                                                              ),
                                                            ),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: Colors
                                                                  .grey[200],
                                                            ),
                                                            child: AutoSizeText(
                                                              minFontSize: 10,
                                                              maxFontSize: 25,
                                                              maxLines: 1,
                                                              docDisp,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      (m.dtype != 'KP')
                                                          ? 'ยกเลิก'
                                                          : nFormat.format(
                                                              double.tryParse(
                                                                      m.total_bill ??
                                                                          '0') ??
                                                                  0),
                                                      textAlign: TextAlign.end,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )),
                                Container(
                                    width: (Responsive.isDesktop(context))
                                        ? MediaQuery.of(context).size.width /
                                            3.5
                                        : 400,
                                    decoration: const BoxDecoration(
                                      color: AppbackgroundColor.Sub_Abg_Colors,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(0),
                                          topRight: Radius.circular(0),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Container(
                                            // color: Colors.grey,
                                            // height: 80,
                                            // width: 300,
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ],
                                    ))
                              ])),
                        ),
                        // select_page == 0
                        //     ?
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(14),
                                      topRight: Radius.circular(14),
                                      bottomLeft: Radius.circular(14),
                                      bottomRight: Radius.circular(14)),
                                  // borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 8,
                                        color: Colors.black12),
                                  ],
                                ),
                                clipBehavior:
                                    Clip.antiAlias, // ให้มุมมนทำงานกับ ripple
                                child: Column(children: [
                                  billHeaderTable(
                                    context,
                                    docno: numdoctax == ''
                                        ? '$numinvoice'
                                        : '$numdoctax',
                                  ),
                                  Container(
                                    height: 330,
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
                                    child: ListView.builder(
                                      controller: _scrollController2,
                                      // itemExtent: 50,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount:
                                          _TransReBillHistoryModels.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final TransHis =
                                            _TransReBillHistoryModels[index];
                                        return Container(
                                          padding: EdgeInsets.all(4.0),
                                          // padding: const EdgeInsets.symmetric(
                                          //     vertical: 8, horizontal: 16),
                                          decoration: BoxDecoration(
                                            border: const Border(
                                              bottom: BorderSide(
                                                color: Colors.black12,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              if ((double.tryParse(
                                                          TransHis.dis_list ??
                                                              '0') ??
                                                      0) >
                                                  0)
                                                Row(
                                                  children: [
                                                    // Container(
                                                    //   width: 50,
                                                    //   child: AutoSizeText(
                                                    //     minFontSize: 8,
                                                    //     maxFontSize: 13,
                                                    //     maxLines: 1,
                                                    //     '${index + 1}',
                                                    //     textAlign: TextAlign.center,
                                                    //     overflow: TextOverflow.ellipsis,
                                                    //     style: const TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text2_,
                                                    //         //fontWeight: FontWeight.bold,
                                                    //         fontFamily: Font_.Fonts_T),
                                                    //   ),
                                                    // ),
                                                    Container(
                                                      width: 85,
                                                      child: AutoSizeText(
                                                        minFontSize: 8,
                                                        maxFontSize: 14,
                                                        maxLines: 1,
                                                        (TransHis.daterec ==
                                                                null)
                                                            ? ''
                                                            : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${TransHis.daterec} 00:00:00'))}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                        '${TransHis.refno}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
                                                        (TransHis.fine.toString() ==
                                                                    '1.00' &&
                                                                TransHis.expname
                                                                        .toString()
                                                                        .trim() ==
                                                                    'null')
                                                            ? 'ค่าปรับ [${TransHis.inv}]'
                                                            : '${TransHis.expname}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
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
                                                        (TransHis.qty == null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(TransHis.qty!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
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
                                                        (TransHis.pvat_original ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(TransHis.pvat_original!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                Colors.red,
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
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
                                                        (TransHis.vat_original ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(TransHis.vat_original!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                Colors.red,
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
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

                                                        (TransHis.wht_original ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(TransHis.wht_original!))}',
                                                        // '${_TransReBillHistoryModels[index].wht}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                Colors.red,
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
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
                                                        (TransHis.amount_original ==
                                                                null)
                                                            ? '0.00'
                                                            : '${nFormat.format(double.parse(TransHis.amount_original!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            decorationColor:
                                                                Colors.red,
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 85,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      ((double.tryParse(TransHis
                                                                          .dis_list ??
                                                                      '0') ??
                                                                  0) >
                                                              0)
                                                          ? ''
                                                          : (TransHis.daterec ==
                                                                  null)
                                                              ? ''
                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${TransHis.daterec} 00:00:00'))}',
                                                      textAlign: TextAlign.left,
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
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      ((double.tryParse(TransHis
                                                                          .dis_list ??
                                                                      '0') ??
                                                                  0) >
                                                              0)
                                                          ? ''
                                                          : '${TransHis.refno}',
                                                      textAlign: TextAlign.left,
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
                                                  ((double.tryParse(TransHis
                                                                      .dis_list ??
                                                                  '0') ??
                                                              0) >
                                                          0)
                                                      ? Expanded(
                                                          flex: 2,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .subdirectory_arrow_right,
                                                                color:
                                                                    Colors.grey,
                                                                size: 16,
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      12,
                                                                  'discount ${nFormat.format(double.parse(TransHis.dis_list!))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : Expanded(
                                                          flex: 2,
                                                          child: AutoSizeText(
                                                            minFontSize: 8,
                                                            maxFontSize: 14,
                                                            maxLines: 1,
                                                            (TransHis.fine.toString() ==
                                                                        '1.00' &&
                                                                    TransHis.expname
                                                                            .toString()
                                                                            .trim() ==
                                                                        'null')
                                                                ? 'ค่าปรับ [${TransHis.inv}]'
                                                                : '${TransHis.expname}',
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                        ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      ((double.tryParse(TransHis
                                                                          .dis_list ??
                                                                      '0') ??
                                                                  0) >
                                                              0)
                                                          ? '-'
                                                          : (TransHis.qty ==
                                                                  null)
                                                              ? '0.00'
                                                              : '${nFormat.format(double.parse(TransHis.qty!))}',
                                                      textAlign: TextAlign.end,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
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
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      (TransHis.pvat == null)
                                                          ? '0.00'
                                                          : '${nFormat.format(double.parse(TransHis.pvat!))}',
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
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      (TransHis.vat == null)
                                                          ? '0.00'
                                                          : '${nFormat.format(double.parse(TransHis.vat!))}',
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
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,

                                                      (TransHis.wht == null)
                                                          ? '0.00'
                                                          : '${nFormat.format(double.parse(TransHis.wht!))}',
                                                      // '${_TransReBillHistoryModels[index].wht}',
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
                                                  // Expanded(
                                                  //   flex: 1,
                                                  //   child: AutoSizeText(
                                                  //     minFontSize: 10,
                                                  //     maxFontSize: 15,
                                                  //     maxLines: 1,
                                                  //     '${_TransReBillHistoryModels[index].vtype}',
                                                  //     textAlign: TextAlign.end,
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
                                                  //     maxFontSize: 15,
                                                  //     maxLines: 1,
                                                  //     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].vat!))}',
                                                  //     textAlign: TextAlign.end,
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
                                                  //     maxFontSize: 15,
                                                  //     maxLines: 1,
                                                  //     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                                  //     textAlign: TextAlign.end,
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
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      (TransHis.total == null)
                                                          ? '0.00'
                                                          : '${nFormat.format(double.parse(TransHis.total!))}',
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
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    height: 250,
                                    child: Row(children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          // color: Colors.grey.shade300,
                                          // shape: RoundedRectangleBorder(
                                          //     borderRadius:
                                          //         BorderRadius.circular(8)),
                                          // clipBehavior: Clip.antiAlias,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Padding(
                                                //   padding:
                                                //       const EdgeInsets.all(2.0),
                                                //   child: Row(
                                                //     mainAxisAlignment:
                                                //         MainAxisAlignment.start,
                                                //     children: [
                                                //       Text(
                                                //         'รายละเอียดการชำระ',
                                                //         textAlign:
                                                //             TextAlign.start,
                                                //         style: TextStyle(
                                                //             color: PeopleChaoScreen_Color
                                                //                 .Colors_Text1_,
                                                //             fontWeight:
                                                //                 FontWeight.bold,
                                                //             fontFamily:
                                                //                 FontWeight_
                                                //                     .Fonts_T
                                                //             //fontSize: 10.0
                                                //             ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                                if (numinvoice != null)
                                                  Container(
                                                    // decoration: BoxDecoration(
                                                    //   borderRadius:
                                                    //       BorderRadius.all(
                                                    //     Radius.circular(6),
                                                    //   ),
                                                    //   border: Border.all(
                                                    //       color: Colors.grey,
                                                    //       width: 1),
                                                    // ),
                                                    // padding:
                                                    //     const EdgeInsets.all(2.0),
                                                    child: Text(
                                                      (dtype_tep == 'KP')
                                                          ? 'หมายเหตุ : ${Remark_}'
                                                          : 'หมายเหตุยกเลิก : ${Remark_}',
                                                      textAlign:
                                                          TextAlign.start,
                                                      maxLines: 2,
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
                                                if (dtype_tep == 'KP' &&
                                                    numinvoice != null)
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Container(
                                                      width: 360,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
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
                                                        // border: Border.all(
                                                        //     color: Colors.grey,
                                                        //     width: 1),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Divider(),
                                                          if (ref_id == null ||
                                                              ref_id.toString() ==
                                                                  'null')
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 8,
                                                                maxFontSize: 12,
                                                                (ref_id == null ||
                                                                        ref_id.toString() ==
                                                                            'null')
                                                                    ? 'อ้างอิง : -'
                                                                    : 'อ้างอิง : ${ref_id.toString()}',
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T
                                                                    //fontSize: 10.0
                                                                    ),
                                                              ),
                                                            ),
                                                          if (ref1 == null ||
                                                              ref1.toString() ==
                                                                  'null')
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 8,
                                                                maxFontSize: 12,
                                                                (ref1 == null ||
                                                                        ref1.toString() ==
                                                                            'null')
                                                                    ? 'Ref1 : -'
                                                                    : 'Ref1 : ${ref1}',
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T
                                                                    //fontSize: 10.0
                                                                    ),
                                                              ),
                                                            ),
                                                          if (ref2 == null ||
                                                              ref2.toString() ==
                                                                  'null')
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 8,
                                                                maxFontSize: 12,
                                                                (ref2 == null ||
                                                                        ref2.toString() ==
                                                                            'null')
                                                                    ? 'Ref2 : -'
                                                                    : 'Ref2 : ${ref2}',
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text1_,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T
                                                                    //fontSize: 10.0
                                                                    ),
                                                              ),
                                                            ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Translate.TranslateAndSetText(
                                                                (pdate == null ||
                                                                        pdate.toString() ==
                                                                            'null')
                                                                    ? 'รูปแบบการชำระ ( วันที่ชำระ : ?? )'
                                                                    : 'รูปแบบการชำระ ( วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 0} )',
                                                                AccountScreen_Color
                                                                    .Colors_Text1_,
                                                                TextAlign.end,
                                                                FontWeight.bold,
                                                                FontWeight_
                                                                    .Fonts_T,
                                                                14,
                                                                1),
                                                          ),
                                                          for (var i = 0;
                                                              i <
                                                                  finnancetransModels
                                                                      .length;
                                                              i++)
                                                            if (finnancetransModels[
                                                                        i]
                                                                    .dtype
                                                                    .toString() !=
                                                                'FTA')
                                                              Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topLeft,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Translate.TranslateAndSetText(
                                                                        '${i + 1}. Total : ${nFormat.format(double.parse(finnancetransModels[i].amt!))}  (${finnancetransModels[i].ptname})',
                                                                        AccountScreen_Color
                                                                            .Colors_Text1_,
                                                                        TextAlign
                                                                            .end,
                                                                        null,
                                                                        Font_
                                                                            .Fonts_T,
                                                                        14,
                                                                        1),
                                                                    if (finnancetransModels[i]
                                                                            .type
                                                                            .toString() !=
                                                                        'CASH')
                                                                      AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            13,
                                                                        '  ** ${i + 1}.1. Bank : ${finnancetransModels[i].bank} , No. : ${finnancetransModels[i].bno}',
                                                                        style: TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text1_,
                                                                            // fontWeight: FontWeight
                                                                            //     .bold,
                                                                            fontFamily: FontWeight_.Fonts_T
                                                                            //fontSize: 10.0
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
                                        ),
                                      ),
                                      Expanded(
                                          flex: 2,
                                          child: Card(
                                            color: Colors.grey.shade300,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            clipBehavior: Clip.antiAlias,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: AutoSizeText(
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                        'รวม(บาท)',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format(getTotalByField(_TransReBillHistoryModels, (item) => item.pvat))}',
                                                        // round_p ==
                                                        //         '1'
                                                        //     ? '${nFormat.format(sum_pvat_up)}'
                                                        //     : '${nFormat.format(sum_pvat)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Text(
                                                    //     'บาท',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text1_,
                                                    //         // fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T
                                                    //         //fontSize: 10.0
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Row(
                                                    //     mainAxisAlignment:
                                                    //         MainAxisAlignment
                                                    //             .end,
                                                    //     crossAxisAlignment:
                                                    //         CrossAxisAlignment
                                                    //             .center,
                                                    //     children: [
                                                    //       rental_ser !=
                                                    //               '106'
                                                    //           ? SizedBox()
                                                    //           : IconButton(
                                                    //               onPressed: () async {
                                                    //                 // //print(_TransReBillModels[
                                                    //                 //         index]
                                                    //                 //     .docno);
                                                    //                 if (renTal_lavel > 3) {
                                                    //                   if (rental_degree_up == '1') {
                                                    //                     new_dereee.text = round_p == '1' ? sum_pvat_up.toString().substring(sum_pvat_up.toString().indexOf('.') + 1) : sum_pvat.toString().substring(sum_pvat.toString().indexOf('.') + 1);
                                                    //                     showDialog(
                                                    //                       context: context,
                                                    //                       builder: (context) => AlertDialog(
                                                    //                           title: Center(
                                                    //                             child: Text(
                                                    //                               'ปรับจุดทศนิยม',
                                                    //                               maxLines: 1,
                                                    //                               textAlign: TextAlign.start,
                                                    //                               style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 20),
                                                    //                             ),
                                                    //                           ),
                                                    //                           content: Stack(
                                                    //                             alignment: Alignment.center,
                                                    //                             children: <Widget>[
                                                    //                               Container(
                                                    //                                   width: 250,
                                                    //                                   decoration: const BoxDecoration(
                                                    //                                     // color: Colors.black,
                                                    //                                     borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                    //                                   ),
                                                    //                                   padding: const EdgeInsets.all(8.0),
                                                    //                                   child: Row(
                                                    //                                     children: [
                                                    //                                       Expanded(
                                                    //                                         flex: 3,
                                                    //                                         child: Row(
                                                    //                                           mainAxisAlignment: MainAxisAlignment.end,
                                                    //                                           children: [
                                                    //                                             Padding(
                                                    //                                               padding: const EdgeInsets.all(8.0),
                                                    //                                               child: Text(
                                                    //                                                 round_p == '1' ? '${sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1)}' : '${sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1)}',
                                                    //                                               ),
                                                    //                                             ),
                                                    //                                           ],
                                                    //                                         ),
                                                    //                                       ),
                                                    //                                       Expanded(
                                                    //                                         flex: 2,
                                                    //                                         child: TextFormField(
                                                    //                                           //keyboardType: TextInputType.none,
                                                    //                                           controller: new_dereee,
                                                    //                                           // onChanged: (value) => value.trim(),
                                                    //                                           onFieldSubmitted: (value) async {
                                                    //                                             var new_amt = round_p == '1' ? sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1) + value : sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1) + value;

                                                    //                                             //print(docnoin_up);
                                                    //                                             SharedPreferences preferences = await SharedPreferences.getInstance();
                                                    //                                             var ren = preferences.getString('renTalSer');
                                                    //                                             var docno = docnoin_up;
                                                    //                                             var sum_amt_up = double.parse(new_amt);
                                                    //                                             var sum_vat_up = double.parse(new_amt.toString()) * 7 / 100;

                                                    //                                             String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                    //                                             try {
                                                    //                                               var response = await http.get(Uri.parse(url));

                                                    //                                               var result = json.decode(response.body);
                                                    //                                               if (result.toString() == 'true') {
                                                    //                                                 setState(() {
                                                    //                                                   red_Trans_select_up();
                                                    //                                                   red_Invoice_up();

                                                    //                                                   // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum).toStringAsFixed(2).toString();
                                                    //                                                 });
                                                    //                                               }
                                                    //                                             } catch (e) {}

                                                    //                                             Navigator.pop(context, 'OK');
                                                    //                                           },
                                                    //                                           // maxLength: 13,
                                                    //                                           cursorColor: Colors.green,
                                                    //                                           decoration: InputDecoration(
                                                    //                                             fillColor: Colors.white.withOpacity(0.3),
                                                    //                                             filled: true,
                                                    //                                             // prefixIcon: const Icon(Icons.person, color: Colors.black),
                                                    //                                             // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                    //                                             focusedBorder: const OutlineInputBorder(
                                                    //                                               borderRadius: BorderRadius.only(
                                                    //                                                 topRight: Radius.circular(15),
                                                    //                                                 topLeft: Radius.circular(15),
                                                    //                                                 bottomRight: Radius.circular(15),
                                                    //                                                 bottomLeft: Radius.circular(15),
                                                    //                                               ),
                                                    //                                               borderSide: BorderSide(
                                                    //                                                 width: 1,
                                                    //                                                 color: Colors.black,
                                                    //                                               ),
                                                    //                                             ),
                                                    //                                             errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
                                                    //                                             enabledBorder: const OutlineInputBorder(
                                                    //                                               borderRadius: BorderRadius.only(
                                                    //                                                 topRight: Radius.circular(15),
                                                    //                                                 topLeft: Radius.circular(15),
                                                    //                                                 bottomRight: Radius.circular(15),
                                                    //                                                 bottomLeft: Radius.circular(15),
                                                    //                                               ),
                                                    //                                               borderSide: BorderSide(
                                                    //                                                 width: 1,
                                                    //                                                 color: Colors.black,
                                                    //                                               ),
                                                    //                                             ),
                                                    //                                             // labelText: 'USERNAME',
                                                    //                                             labelStyle: const TextStyle(
                                                    //                                               fontSize: 14,
                                                    //                                               color: Colors.black54,
                                                    //                                               fontFamily: Font_.Fonts_T,
                                                    //                                             ),
                                                    //                                           ),
                                                    //                                           inputFormatters: <TextInputFormatter>[
                                                    //                                             //   // for below version 2 use this
                                                    //                                             //   FilteringTextInputFormatter(RegExp("[a-zA-Z1-9@.]"),
                                                    //                                             //       allow: true),
                                                    //                                             FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                    //                                             //for version 2 and greater youcan also use this
                                                    //                                             FilteringTextInputFormatter.digitsOnly
                                                    //                                           ],
                                                    //                                         ),
                                                    //                                       )
                                                    //                                     ],
                                                    //                                   ))
                                                    //                             ],
                                                    //                           ),
                                                    //                           actions: <Widget>[
                                                    //                             Row(
                                                    //                               mainAxisAlignment: MainAxisAlignment.center,
                                                    //                               children: [
                                                    //                                 Padding(
                                                    //                                   padding: const EdgeInsets.all(8.0),
                                                    //                                   child: Container(
                                                    //                                     width: 100,
                                                    //                                     decoration: const BoxDecoration(
                                                    //                                       color: Colors.black,
                                                    //                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                    //                                     ),
                                                    //                                     padding: const EdgeInsets.all(8.0),
                                                    //                                     child: TextButton(
                                                    //                                       onPressed: () => Navigator.pop(context, 'OK'),
                                                    //                                       child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                    //                                     ),
                                                    //                                   ),
                                                    //                                 ),
                                                    //                               ],
                                                    //                             ),
                                                    //                           ]),
                                                    //                     );
                                                    //                   } else if (rental_degree_up == '2') {
                                                    //                     //print(docnoin_up);
                                                    //                     SharedPreferences preferences = await SharedPreferences.getInstance();
                                                    //                     var ren = preferences.getString('renTalSer');
                                                    //                     var docno = docnoin_up;
                                                    //                     var sum_amt_up = round_p == '1' ? sum_pvat_up.toPrecision(1) : sum_pvat.toPrecision(1);
                                                    //                     var sum_vat_up = round_p == '1' ? sum_pvat_up.toPrecision(1) * 7 / 100 : sum_pvat.toPrecision(1) * 7 / 100;

                                                    //                     String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                    //                     try {
                                                    //                       var response = await http.get(Uri.parse(url));

                                                    //                       var result = json.decode(response.body);
                                                    //                       if (result.toString() == 'true') {
                                                    //                         setState(() {
                                                    //                           red_Trans_select_up();
                                                    //                           red_Invoice_up();
                                                    //                         });
                                                    //                       }
                                                    //                     } catch (e) {}
                                                    //                   }
                                                    //                 } else {
                                                    //                   Dialog_updegree();
                                                    //                 }
                                                    //               },
                                                    //               icon: Icon(
                                                    //                 Icons.unfold_more,
                                                    //               ),
                                                    //             ),
                                                    //       Text(
                                                    //         'บาท',
                                                    //         textAlign:
                                                    //             TextAlign.end,
                                                    //         style: TextStyle(
                                                    //             color: PeopleChaoScreen_Color.Colors_Text1_,
                                                    //             // fontWeight: FontWeight.bold,
                                                    //             fontFamily: Font_.Fonts_T
                                                    //             //fontSize: 10.0
                                                    //             ),
                                                    //       ),
                                                    //     ],
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: AutoSizeText(
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                        'ภาษีมูลค่าเพิ่ม(vat)',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format(getTotalByField(_TransReBillHistoryModels, (item) => item.vat))}',
                                                        // round_p ==
                                                        //         '1'
                                                        //     ? '${nFormat.format(sum_vat_up)}'
                                                        //     : '${nFormat.format(sum_vat)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Text(
                                                    //     'บาท',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text1_,
                                                    //         // fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T
                                                    //         //fontSize: 10.0
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: AutoSizeText(
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                        'หัก ณ ที่จ่าย',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format(getTotalByField(_TransReBillHistoryModels, (item) => item.wht))}',
                                                        // '${nFormat.format(sum_wht)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Text(
                                                    //     'บาท',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text1_,
                                                    //         // fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T
                                                    //         //fontSize: 10.0
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: AutoSizeText(
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                        'ค่าทำเนียม',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format(sum_duesbill)}',
                                                        // '${nFormat.format(sum_wht)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Text(
                                                    //     'บาท',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text1_,
                                                    //         // fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T
                                                    //         //fontSize: 10.0
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: AutoSizeText(
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                        'ยอดรวม',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format((getTotalByField(_TransReBillHistoryModels, (item) => item.total) + sum_duesbill))}',
                                                        // '${nFormat.format(sum_amt)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Text(
                                                    //     'บาท',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text1_,
                                                    //         // fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T
                                                    //         //fontSize: 10.0
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Row(
                                                        children: [
                                                          AutoSizeText(
                                                            minFontSize: 12,
                                                            maxFontSize: 14,
                                                            'ส่วนลด',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text2_,
                                                                //fontWeight: FontWeight.bold,
                                                                fontFamily: Font_
                                                                    .Fonts_T),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            '$sum_disp  %',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format(sum_disamt)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Text(
                                                    //     'บาท',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text1_,
                                                    //         // fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T
                                                    //         //fontSize: 10.0
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                // total_amt == 0.00
                                                //     ? SizedBox()
                                                //     : Row(
                                                //         children: [
                                                //           Expanded(
                                                //             flex: 4,
                                                //             child:
                                                //                 Text(
                                                //               'หักชำระ',
                                                //               textAlign:
                                                //                   TextAlign.start,
                                                //               style: TextStyle(
                                                //                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                                //                   fontWeight: FontWeight.bold,
                                                //                   fontFamily: FontWeight_.Fonts_T
                                                //                   //fontSize: 10.0
                                                //                   ),
                                                //             ),
                                                //           ),
                                                //           Expanded(
                                                //             flex: 2,
                                                //             child:
                                                //                 Text(
                                                //               '${nFormat.format(total_amt)}',
                                                //               textAlign:
                                                //                   TextAlign.end,
                                                //               style: TextStyle(
                                                //                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                                //                   fontWeight: FontWeight.bold,
                                                //                   fontFamily: FontWeight_.Fonts_T
                                                //                   //fontSize: 10.0
                                                //                   ),
                                                //             ),
                                                //           ),
                                                //           Expanded(
                                                //             flex: 1,
                                                //             child:
                                                //                 Text(
                                                //               'บาท',
                                                //               textAlign:
                                                //                   TextAlign.end,
                                                //               style: TextStyle(
                                                //                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                                //                   // fontWeight: FontWeight.bold,
                                                //                   fontFamily: Font_.Fonts_T
                                                //                   //fontSize: 10.0
                                                //                   ),
                                                //             ),
                                                //           ),
                                                //         ],
                                                //       ),

                                                if (nFormat
                                                        .format(dis_sum_Matjum)
                                                        .toString() !=
                                                    '0.00')
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 4,
                                                        child: AutoSizeText(
                                                          minFontSize: 12,
                                                          maxFontSize: 14,
                                                          'เงินมัดจำ(ตัดมัดจำ)',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              //fontWeight: FontWeight.bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          '${nFormat.format(dis_sum_Matjum)}',
                                                          // '${nFormat.format(sum_amt)}',r
                                                          textAlign:
                                                              TextAlign.end,
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T
                                                              //fontSize: 10.0
                                                              ),
                                                        ),
                                                      ),
                                                      // Expanded(
                                                      //   flex: 1,
                                                      //   child: Text(
                                                      //     'บาท',
                                                      //     textAlign:
                                                      //         TextAlign.end,
                                                      //     style: TextStyle(
                                                      //         color: PeopleChaoScreen_Color
                                                      //             .Colors_Text1_,
                                                      //         // fontWeight: FontWeight.bold,
                                                      //         fontFamily:
                                                      //             Font_.Fonts_T
                                                      //         //fontSize: 10.0
                                                      //         ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: AutoSizeText(
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                        'ยอดชำระรวม',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format((getTotalByField(_TransReBillHistoryModels, (item) => item.total) + sum_duesbill) - sum_disamt)}',
                                                        // '${nFormat.format((getTotalByField(_TransReBillHistoryModels, (item) => item.total) + 0) - sum_disamt)}',
                                                        // '${nFormat.format(sum_amt - sum_disamt - total_amt)}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T
                                                            //fontSize: 10.0
                                                            ),
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 1,
                                                    //   child: Text(
                                                    //     'บาท',
                                                    //     textAlign:
                                                    //         TextAlign.end,
                                                    //     style: TextStyle(
                                                    //         color: PeopleChaoScreen_Color
                                                    //             .Colors_Text1_,
                                                    //         // fontWeight: FontWeight.bold,
                                                    //         fontFamily:
                                                    //             Font_.Fonts_T
                                                    //         //fontSize: 10.0
                                                    //         ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                if (dtypeselect != '!Z') ...[
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  const Divider(),
                                                  SizedBox(
                                                    height: 2,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 12,
                                                          maxFontSize: 14,
                                                          'รายการทั้งหมด : ${_TransReBillHistoryModels.length}',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child:
                                                            ElevatedButton.icon(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .deepOrange
                                                                    .shade600,
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                          ),
                                                          icon: const Icon(
                                                              Icons
                                                                  .receipt_outlined,
                                                              size: 18),
                                                          label: const Text(
                                                              'รายละเอียด',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      FontWeight_
                                                                          .Fonts_T)),
                                                          onPressed:
                                                              _TransReBillHistoryModels
                                                                          .length <
                                                                      1
                                                                  ? null
                                                                  : () async {
                                                                      dialogOk(
                                                                          context);
                                                                    },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ] else ...[
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 12,
                                                          maxFontSize: 14,
                                                          'รายการทั้งหมด : ${_TransReBillHistoryModels.length}',
                                                          style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child:
                                                            ElevatedButton.icon(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors
                                                                    .deepOrange
                                                                    .shade600,
                                                            foregroundColor:
                                                                Colors.white,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                            ),
                                                          ),
                                                          icon: const Icon(
                                                              Icons
                                                                  .receipt_outlined,
                                                              size: 18),
                                                          label: Text(
                                                              (Slip_history
                                                                              .toString() ==
                                                                          null ||
                                                                      Slip_history ==
                                                                          null ||
                                                                      Slip_history
                                                                              .toString() ==
                                                                          'null' ||
                                                                      Slip_history
                                                                              .toString() ==
                                                                          '')
                                                                  ? 'ไม่พบหลักฐาน'
                                                                  : 'หลักฐาน',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      FontWeight_
                                                                          .Fonts_T)),
                                                          onPressed: _TransReBillHistoryModels
                                                                      .length <
                                                                  1
                                                              ? null
                                                              : (Slip_history
                                                                              .toString() ==
                                                                          null ||
                                                                      Slip_history ==
                                                                          null ||
                                                                      Slip_history
                                                                              .toString() ==
                                                                          'null' ||
                                                                      Slip_history
                                                                              .toString() ==
                                                                          '')
                                                                  ? null
                                                                  : () async {
                                                                      bool
                                                                          hasNonCashTransaction =
                                                                          finnancetransModels
                                                                              .any((transaction) {
                                                                        return transaction.ptser.toString().trim() ==
                                                                            '7';
                                                                      });

                                                                      ///finnancetransModels
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) =>
                                                                                AlertDialog(
                                                                          shape:
                                                                              const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                          backgroundColor:
                                                                              AppbackgroundColor.Sub_Abg_Colors,
                                                                          titlePadding:
                                                                              const EdgeInsets.all(0.0),
                                                                          contentPadding:
                                                                              const EdgeInsets.all(10.0),
                                                                          actionsPadding:
                                                                              const EdgeInsets.all(6.0),
                                                                          title:
                                                                              Center(
                                                                            child:
                                                                                Column(
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
                                                                                        child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Text(
                                                                                  '${numinvoice} ',
                                                                                  maxLines: 1,
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                                                                ),
                                                                                (hasNonCashTransaction == true)
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
                                                                                            final String url = '${Slip_history}';
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
                                                                                            onTap: () => downloadImage_slip('${MyConstant().domain}/files/$foder/slip/${Slip_history}', '${numinvoice}'),
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
                                                                                  stream: Stream.periodic(const Duration(seconds: 0)),
                                                                                  builder: (context, snapshot) {
                                                                                    return SingleChildScrollView(
                                                                                      child: ListBody(
                                                                                        children: <Widget>[
                                                                                          Container(
                                                                                            // height: 600,
                                                                                            width: MediaQuery.of(context).size.width,
                                                                                            child: WebViewX2Pagebeamcheck(id_ser: Slip_history),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  })
                                                                              : Stack(
                                                                                  alignment: Alignment.center,
                                                                                  children: <Widget>[
                                                                                    Image.network('${MyConstant().domain}/files/$foder/slip/${Slip_history}')
                                                                                  ],
                                                                                ),
                                                                        ),
                                                                      );
                                                                    },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]
                                              ]),
                                            ),
                                          ))
                                    ]),
                                  ),
                                  // Container(
                                  //     width: (Responsive.isDesktop(context))
                                  //         ? MediaQuery.of(context).size.width *
                                  //             0.52
                                  //         : 900,
                                  //     decoration: const BoxDecoration(
                                  //       color:
                                  //           AppbackgroundColor.Sub_Abg_Colors,
                                  //       borderRadius: BorderRadius.only(
                                  //           topLeft: Radius.circular(0),
                                  //           topRight: Radius.circular(0),
                                  //           bottomLeft: Radius.circular(10),
                                  //           bottomRight: Radius.circular(10)),
                                  //     ),
                                  //     child: Column(
                                  //       children: [
                                  //         Column(
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.start,
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.start,
                                  //           children: [
                                  //             Divider(),
                                  //             Padding(
                                  //               padding:
                                  //                   const EdgeInsets.all(8.0),
                                  //               child: Row(
                                  //                 mainAxisAlignment:
                                  //                     MainAxisAlignment.start,
                                  //                 children: [
                                  //                   Text(
                                  //                     'รายละเอียดการชำระ',
                                  //                     textAlign:
                                  //                         TextAlign.start,
                                  //                     style: TextStyle(
                                  //                         color:
                                  //                             PeopleChaoScreen_Color
                                  //                                 .Colors_Text1_,
                                  //                         fontWeight:
                                  //                             FontWeight.bold,
                                  //                         fontFamily:
                                  //                             FontWeight_
                                  //                                 .Fonts_T
                                  //                         //fontSize: 10.0
                                  //                         ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //         // dtypeselect == '!Z'
                                  //         //     ? SizedBox()
                                  //         //     : _TransReBillHistoryModels.length ==
                                  //         //             0
                                  //         //         ? SizedBox()
                                  //         //         :
                                  //         Padding(
                                  //           padding: const EdgeInsets.all(2.0),
                                  //           child: Row(
                                  //             children: [
                                  //               Expanded(
                                  //                 flex: 4,
                                  //                 child: Column(
                                  //                   children: [
                                  //                     Row(
                                  //                       children: [
                                  //                         Padding(
                                  //                           padding:
                                  //                               const EdgeInsets
                                  //                                   .all(4.0),
                                  //                           child: Container(
                                  //                             width: 350,
                                  //                             height: 50,
                                  //                             decoration:
                                  //                                 BoxDecoration(
                                  //                               // color: Colors.green,
                                  //                               borderRadius:
                                  //                                   const BorderRadius
                                  //                                       .only(
                                  //                                 topLeft: Radius
                                  //                                     .circular(
                                  //                                         6),
                                  //                                 topRight: Radius
                                  //                                     .circular(
                                  //                                         6),
                                  //                                 bottomLeft: Radius
                                  //                                     .circular(
                                  //                                         6),
                                  //                                 bottomRight: Radius
                                  //                                     .circular(
                                  //                                         6),
                                  //                               ),
                                  //                               border: Border.all(
                                  //                                   color: Colors
                                  //                                       .grey,
                                  //                                   width: 1),
                                  //                             ),
                                  //                             child: Padding(
                                  //                               padding:
                                  //                                   const EdgeInsets
                                  //                                           .all(
                                  //                                       4.0),
                                  //                               child: Container(
                                  //                                   height: 100,
                                  //                                   child: Text(
                                  //                                     'หมายเหตุ : ${Remark_}',
                                  //                                     textAlign:
                                  //                                         TextAlign
                                  //                                             .start,
                                  //                                     overflow:
                                  //                                         TextOverflow
                                  //                                             .ellipsis,
                                  //                                     style: const TextStyle(
                                  //                                         color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //                                         //fontWeight: FontWeight.bold,
                                  //                                         fontFamily: Font_.Fonts_T),
                                  //                                   )),
                                  //                             ),
                                  //                           ),
                                  //                         ),
                                  //                         // Expanded(
                                  //                         //   flex: 4,
                                  //                         //   child: Text(
                                  //                         //     (Slip_history
                                  //                         //                     .toString() ==
                                  //                         //                 null ||
                                  //                         //             Slip_history ==
                                  //                         //                 null ||
                                  //                         //             Slip_history
                                  //                         //                     .toString() ==
                                  //                         //                 'null')
                                  //                         //         ? 'หลักฐานการโอน'
                                  //                         //         : '',
                                  //                         //     textAlign:
                                  //                         //         TextAlign.end,
                                  //                         //     style: TextStyle(
                                  //                         //         color: PeopleChaoScreen_Color
                                  //                         //             .Colors_Text1_,
                                  //                         //         fontWeight:
                                  //                         //             FontWeight
                                  //                         //                 .bold,
                                  //                         //         fontFamily:
                                  //                         //             FontWeight_
                                  //                         //                 .Fonts_T
                                  //                         //         //fontSize: 10.0
                                  //                         //         ),
                                  //                         //   ),
                                  //                         // ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '',
                                  //                             // (Slip_history
                                  //                             //                 .toString() ==
                                  //                             //             null ||
                                  //                             //         Slip_history ==
                                  //                             //             null ||
                                  //                             //         Slip_history
                                  //                             //                 .toString() ==
                                  //                             //             'null')
                                  //                             //     ? 'หลักฐานการโอน : ไม่พบหลักฐาน'
                                  //                             //     : 'หลักฐานการโอน : พบหลักฐาน',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                     Divider(),
                                  //                     Row(
                                  //                       children: [
                                  //                         Expanded(
                                  //                           flex: 4,
                                  //                           child: Text(
                                  //                             'รวม(บาท)',
                                  //                             textAlign:
                                  //                                 TextAlign
                                  //                                     .start,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '${nFormat.format(getTotalByField(_TransReBillHistoryModels, (item) => item.pvat))}',
                                  //                             // round_p ==
                                  //                             //         '1'
                                  //                             //     ? '${nFormat.format(sum_pvat_up)}'
                                  //                             //     : '${nFormat.format(sum_pvat)}',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 1,
                                  //                           child: Text(
                                  //                             'บาท',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         // Expanded(
                                  //                         //   flex: 1,
                                  //                         //   child: Row(
                                  //                         //     mainAxisAlignment:
                                  //                         //         MainAxisAlignment
                                  //                         //             .end,
                                  //                         //     crossAxisAlignment:
                                  //                         //         CrossAxisAlignment
                                  //                         //             .center,
                                  //                         //     children: [
                                  //                         //       rental_ser !=
                                  //                         //               '106'
                                  //                         //           ? SizedBox()
                                  //                         //           : IconButton(
                                  //                         //               onPressed: () async {
                                  //                         //                 // //print(_TransReBillModels[
                                  //                         //                 //         index]
                                  //                         //                 //     .docno);
                                  //                         //                 if (renTal_lavel > 3) {
                                  //                         //                   if (rental_degree_up == '1') {
                                  //                         //                     new_dereee.text = round_p == '1' ? sum_pvat_up.toString().substring(sum_pvat_up.toString().indexOf('.') + 1) : sum_pvat.toString().substring(sum_pvat.toString().indexOf('.') + 1);
                                  //                         //                     showDialog(
                                  //                         //                       context: context,
                                  //                         //                       builder: (context) => AlertDialog(
                                  //                         //                           title: Center(
                                  //                         //                             child: Text(
                                  //                         //                               'ปรับจุดทศนิยม',
                                  //                         //                               maxLines: 1,
                                  //                         //                               textAlign: TextAlign.start,
                                  //                         //                               style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 20),
                                  //                         //                             ),
                                  //                         //                           ),
                                  //                         //                           content: Stack(
                                  //                         //                             alignment: Alignment.center,
                                  //                         //                             children: <Widget>[
                                  //                         //                               Container(
                                  //                         //                                   width: 250,
                                  //                         //                                   decoration: const BoxDecoration(
                                  //                         //                                     // color: Colors.black,
                                  //                         //                                     borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                         //                                   ),
                                  //                         //                                   padding: const EdgeInsets.all(8.0),
                                  //                         //                                   child: Row(
                                  //                         //                                     children: [
                                  //                         //                                       Expanded(
                                  //                         //                                         flex: 3,
                                  //                         //                                         child: Row(
                                  //                         //                                           mainAxisAlignment: MainAxisAlignment.end,
                                  //                         //                                           children: [
                                  //                         //                                             Padding(
                                  //                         //                                               padding: const EdgeInsets.all(8.0),
                                  //                         //                                               child: Text(
                                  //                         //                                                 round_p == '1' ? '${sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1)}' : '${sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1)}',
                                  //                         //                                               ),
                                  //                         //                                             ),
                                  //                         //                                           ],
                                  //                         //                                         ),
                                  //                         //                                       ),
                                  //                         //                                       Expanded(
                                  //                         //                                         flex: 2,
                                  //                         //                                         child: TextFormField(
                                  //                         //                                           //keyboardType: TextInputType.none,
                                  //                         //                                           controller: new_dereee,
                                  //                         //                                           // onChanged: (value) => value.trim(),
                                  //                         //                                           onFieldSubmitted: (value) async {
                                  //                         //                                             var new_amt = round_p == '1' ? sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1) + value : sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1) + value;

                                  //                         //                                             //print(docnoin_up);
                                  //                         //                                             SharedPreferences preferences = await SharedPreferences.getInstance();
                                  //                         //                                             var ren = preferences.getString('renTalSer');
                                  //                         //                                             var docno = docnoin_up;
                                  //                         //                                             var sum_amt_up = double.parse(new_amt);
                                  //                         //                                             var sum_vat_up = double.parse(new_amt.toString()) * 7 / 100;

                                  //                         //                                             String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                  //                         //                                             try {
                                  //                         //                                               var response = await http.get(Uri.parse(url));

                                  //                         //                                               var result = json.decode(response.body);
                                  //                         //                                               if (result.toString() == 'true') {
                                  //                         //                                                 setState(() {
                                  //                         //                                                   red_Trans_select_up();
                                  //                         //                                                   red_Invoice_up();

                                  //                         //                                                   // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum).toStringAsFixed(2).toString();
                                  //                         //                                                 });
                                  //                         //                                               }
                                  //                         //                                             } catch (e) {}

                                  //                         //                                             Navigator.pop(context, 'OK');
                                  //                         //                                           },
                                  //                         //                                           // maxLength: 13,
                                  //                         //                                           cursorColor: Colors.green,
                                  //                         //                                           decoration: InputDecoration(
                                  //                         //                                             fillColor: Colors.white.withOpacity(0.3),
                                  //                         //                                             filled: true,
                                  //                         //                                             // prefixIcon: const Icon(Icons.person, color: Colors.black),
                                  //                         //                                             // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                  //                         //                                             focusedBorder: const OutlineInputBorder(
                                  //                         //                                               borderRadius: BorderRadius.only(
                                  //                         //                                                 topRight: Radius.circular(15),
                                  //                         //                                                 topLeft: Radius.circular(15),
                                  //                         //                                                 bottomRight: Radius.circular(15),
                                  //                         //                                                 bottomLeft: Radius.circular(15),
                                  //                         //                                               ),
                                  //                         //                                               borderSide: BorderSide(
                                  //                         //                                                 width: 1,
                                  //                         //                                                 color: Colors.black,
                                  //                         //                                               ),
                                  //                         //                                             ),
                                  //                         //                                             errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
                                  //                         //                                             enabledBorder: const OutlineInputBorder(
                                  //                         //                                               borderRadius: BorderRadius.only(
                                  //                         //                                                 topRight: Radius.circular(15),
                                  //                         //                                                 topLeft: Radius.circular(15),
                                  //                         //                                                 bottomRight: Radius.circular(15),
                                  //                         //                                                 bottomLeft: Radius.circular(15),
                                  //                         //                                               ),
                                  //                         //                                               borderSide: BorderSide(
                                  //                         //                                                 width: 1,
                                  //                         //                                                 color: Colors.black,
                                  //                         //                                               ),
                                  //                         //                                             ),
                                  //                         //                                             // labelText: 'USERNAME',
                                  //                         //                                             labelStyle: const TextStyle(
                                  //                         //                                               fontSize: 14,
                                  //                         //                                               color: Colors.black54,
                                  //                         //                                               fontFamily: Font_.Fonts_T,
                                  //                         //                                             ),
                                  //                         //                                           ),
                                  //                         //                                           inputFormatters: <TextInputFormatter>[
                                  //                         //                                             //   // for below version 2 use this
                                  //                         //                                             //   FilteringTextInputFormatter(RegExp("[a-zA-Z1-9@.]"),
                                  //                         //                                             //       allow: true),
                                  //                         //                                             FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  //                         //                                             //for version 2 and greater youcan also use this
                                  //                         //                                             FilteringTextInputFormatter.digitsOnly
                                  //                         //                                           ],
                                  //                         //                                         ),
                                  //                         //                                       )
                                  //                         //                                     ],
                                  //                         //                                   ))
                                  //                         //                             ],
                                  //                         //                           ),
                                  //                         //                           actions: <Widget>[
                                  //                         //                             Row(
                                  //                         //                               mainAxisAlignment: MainAxisAlignment.center,
                                  //                         //                               children: [
                                  //                         //                                 Padding(
                                  //                         //                                   padding: const EdgeInsets.all(8.0),
                                  //                         //                                   child: Container(
                                  //                         //                                     width: 100,
                                  //                         //                                     decoration: const BoxDecoration(
                                  //                         //                                       color: Colors.black,
                                  //                         //                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                         //                                     ),
                                  //                         //                                     padding: const EdgeInsets.all(8.0),
                                  //                         //                                     child: TextButton(
                                  //                         //                                       onPressed: () => Navigator.pop(context, 'OK'),
                                  //                         //                                       child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                  //                         //                                     ),
                                  //                         //                                   ),
                                  //                         //                                 ),
                                  //                         //                               ],
                                  //                         //                             ),
                                  //                         //                           ]),
                                  //                         //                     );
                                  //                         //                   } else if (rental_degree_up == '2') {
                                  //                         //                     //print(docnoin_up);
                                  //                         //                     SharedPreferences preferences = await SharedPreferences.getInstance();
                                  //                         //                     var ren = preferences.getString('renTalSer');
                                  //                         //                     var docno = docnoin_up;
                                  //                         //                     var sum_amt_up = round_p == '1' ? sum_pvat_up.toPrecision(1) : sum_pvat.toPrecision(1);
                                  //                         //                     var sum_vat_up = round_p == '1' ? sum_pvat_up.toPrecision(1) * 7 / 100 : sum_pvat.toPrecision(1) * 7 / 100;

                                  //                         //                     String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                  //                         //                     try {
                                  //                         //                       var response = await http.get(Uri.parse(url));

                                  //                         //                       var result = json.decode(response.body);
                                  //                         //                       if (result.toString() == 'true') {
                                  //                         //                         setState(() {
                                  //                         //                           red_Trans_select_up();
                                  //                         //                           red_Invoice_up();
                                  //                         //                         });
                                  //                         //                       }
                                  //                         //                     } catch (e) {}
                                  //                         //                   }
                                  //                         //                 } else {
                                  //                         //                   Dialog_updegree();
                                  //                         //                 }
                                  //                         //               },
                                  //                         //               icon: Icon(
                                  //                         //                 Icons.unfold_more,
                                  //                         //               ),
                                  //                         //             ),
                                  //                         //       Text(
                                  //                         //         'บาท',
                                  //                         //         textAlign:
                                  //                         //             TextAlign.end,
                                  //                         //         style: TextStyle(
                                  //                         //             color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                         //             // fontWeight: FontWeight.bold,
                                  //                         //             fontFamily: Font_.Fonts_T
                                  //                         //             //fontSize: 10.0
                                  //                         //             ),
                                  //                         //       ),
                                  //                         //     ],
                                  //                         //   ),
                                  //                         // ),
                                  //                       ],
                                  //                     ),
                                  //                     Row(
                                  //                       children: [
                                  //                         Expanded(
                                  //                           flex: 4,
                                  //                           child: Text(
                                  //                             'ภาษีมูลค่าเพิ่ม(vat)',
                                  //                             textAlign:
                                  //                                 TextAlign
                                  //                                     .start,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '${nFormat.format(getTotalByField(_TransReBillHistoryModels, (item) => item.vat))}',
                                  //                             // round_p ==
                                  //                             //         '1'
                                  //                             //     ? '${nFormat.format(sum_vat_up)}'
                                  //                             //     : '${nFormat.format(sum_vat)}',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 1,
                                  //                           child: Text(
                                  //                             'บาท',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                     Row(
                                  //                       children: [
                                  //                         Expanded(
                                  //                           flex: 4,
                                  //                           child: Text(
                                  //                             'หัก ณ ที่จ่าย',
                                  //                             textAlign:
                                  //                                 TextAlign
                                  //                                     .start,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '${nFormat.format(getTotalByField(_TransReBillHistoryModels, (item) => item.wht))}',
                                  //                             // '${nFormat.format(sum_wht)}',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 1,
                                  //                           child: Text(
                                  //                             'บาท',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                     Row(
                                  //                       children: [
                                  //                         Expanded(
                                  //                           flex: 4,
                                  //                           child: Text(
                                  //                             'ค่าทำเนียม',
                                  //                             textAlign:
                                  //                                 TextAlign
                                  //                                     .start,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '${nFormat.format(sum_duesbill)}',
                                  //                             // '${nFormat.format(sum_wht)}',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 1,
                                  //                           child: Text(
                                  //                             'บาท',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                     Row(
                                  //                       children: [
                                  //                         Expanded(
                                  //                           flex: 4,
                                  //                           child: Text(
                                  //                             'ยอดรวม',
                                  //                             textAlign:
                                  //                                 TextAlign
                                  //                                     .start,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '${nFormat.format((getTotalByField(_TransReBillHistoryModels, (item) => item.total) + sum_duesbill))}',
                                  //                             // '${nFormat.format(sum_amt)}',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 1,
                                  //                           child: Text(
                                  //                             'บาท',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                     Row(
                                  //                       children: [
                                  //                         Expanded(
                                  //                           flex: 4,
                                  //                           child: Row(
                                  //                             children: [
                                  //                               Text(
                                  //                                 'ส่วนลด',
                                  //                                 textAlign:
                                  //                                     TextAlign
                                  //                                         .start,
                                  //                                 style: TextStyle(
                                  //                                     color: PeopleChaoScreen_Color
                                  //                                         .Colors_Text1_,
                                  //                                     fontWeight:
                                  //                                         FontWeight
                                  //                                             .bold,
                                  //                                     fontFamily:
                                  //                                         FontWeight_
                                  //                                             .Fonts_T
                                  //                                     //fontSize: 10.0
                                  //                                     ),
                                  //                               ),
                                  //                               SizedBox(
                                  //                                 width: 10,
                                  //                               ),
                                  //                               Text(
                                  //                                 '$sum_disp  %',
                                  //                                 textAlign:
                                  //                                     TextAlign
                                  //                                         .start,
                                  //                                 style: TextStyle(
                                  //                                     color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                                     // fontWeight: FontWeight.bold,
                                  //                                     fontFamily: FontWeight_.Fonts_T
                                  //                                     //fontSize: 10.0
                                  //                                     ),
                                  //                               ),
                                  //                             ],
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '${nFormat.format(sum_disamt)}',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 1,
                                  //                           child: Text(
                                  //                             'บาท',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),
                                  //                     // total_amt == 0.00
                                  //                     //     ? SizedBox()
                                  //                     //     : Row(
                                  //                     //         children: [
                                  //                     //           Expanded(
                                  //                     //             flex: 4,
                                  //                     //             child:
                                  //                     //                 Text(
                                  //                     //               'หักชำระ',
                                  //                     //               textAlign:
                                  //                     //                   TextAlign.start,
                                  //                     //               style: TextStyle(
                                  //                     //                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                     //                   fontWeight: FontWeight.bold,
                                  //                     //                   fontFamily: FontWeight_.Fonts_T
                                  //                     //                   //fontSize: 10.0
                                  //                     //                   ),
                                  //                     //             ),
                                  //                     //           ),
                                  //                     //           Expanded(
                                  //                     //             flex: 2,
                                  //                     //             child:
                                  //                     //                 Text(
                                  //                     //               '${nFormat.format(total_amt)}',
                                  //                     //               textAlign:
                                  //                     //                   TextAlign.end,
                                  //                     //               style: TextStyle(
                                  //                     //                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                     //                   fontWeight: FontWeight.bold,
                                  //                     //                   fontFamily: FontWeight_.Fonts_T
                                  //                     //                   //fontSize: 10.0
                                  //                     //                   ),
                                  //                     //             ),
                                  //                     //           ),
                                  //                     //           Expanded(
                                  //                     //             flex: 1,
                                  //                     //             child:
                                  //                     //                 Text(
                                  //                     //               'บาท',
                                  //                     //               textAlign:
                                  //                     //                   TextAlign.end,
                                  //                     //               style: TextStyle(
                                  //                     //                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                     //                   // fontWeight: FontWeight.bold,
                                  //                     //                   fontFamily: Font_.Fonts_T
                                  //                     //                   //fontSize: 10.0
                                  //                     //                   ),
                                  //                     //             ),
                                  //                     //           ),
                                  //                     //         ],
                                  //                     //       ),

                                  //                     if (nFormat
                                  //                             .format(
                                  //                                 dis_sum_Matjum)
                                  //                             .toString() !=
                                  //                         '0.00')
                                  //                       Row(
                                  //                         children: [
                                  //                           Expanded(
                                  //                             flex: 4,
                                  //                             child: Text(
                                  //                               'เงินมัดจำ(ตัดมัดจำ)',
                                  //                               textAlign:
                                  //                                   TextAlign
                                  //                                       .start,
                                  //                               style: TextStyle(
                                  //                                   color: PeopleChaoScreen_Color
                                  //                                       .Colors_Text1_,
                                  //                                   fontWeight:
                                  //                                       FontWeight
                                  //                                           .bold,
                                  //                                   fontFamily:
                                  //                                       FontWeight_
                                  //                                           .Fonts_T
                                  //                                   //fontSize: 10.0
                                  //                                   ),
                                  //                             ),
                                  //                           ),
                                  //                           Expanded(
                                  //                             flex: 2,
                                  //                             child: Text(
                                  //                               '${nFormat.format(dis_sum_Matjum)}',
                                  //                               // '${nFormat.format(sum_amt)}',r
                                  //                               textAlign:
                                  //                                   TextAlign
                                  //                                       .end,
                                  //                               style: TextStyle(
                                  //                                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                                   // fontWeight: FontWeight.bold,
                                  //                                   fontFamily: Font_.Fonts_T
                                  //                                   //fontSize: 10.0
                                  //                                   ),
                                  //                             ),
                                  //                           ),
                                  //                           Expanded(
                                  //                             flex: 1,
                                  //                             child: Text(
                                  //                               'บาท',
                                  //                               textAlign:
                                  //                                   TextAlign
                                  //                                       .end,
                                  //                               style: TextStyle(
                                  //                                   color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                                   // fontWeight: FontWeight.bold,
                                  //                                   fontFamily: Font_.Fonts_T
                                  //                                   //fontSize: 10.0
                                  //                                   ),
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                     Row(
                                  //                       children: [
                                  //                         Expanded(
                                  //                           flex: 4,
                                  //                           child: Text(
                                  //                             'ยอดชำระรวม',
                                  //                             textAlign:
                                  //                                 TextAlign
                                  //                                     .start,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 2,
                                  //                           child: Text(
                                  //                             '${nFormat.format((getTotalByField(_TransReBillHistoryModels, (item) => item.total) + sum_duesbill) - sum_disamt)}',
                                  //                             // '${nFormat.format((getTotalByField(_TransReBillHistoryModels, (item) => item.total) + 0) - sum_disamt)}',
                                  //                             // '${nFormat.format(sum_amt - sum_disamt - total_amt)}',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                 fontFamily:
                                  //                                     FontWeight_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                         Expanded(
                                  //                           flex: 1,
                                  //                           child: Text(
                                  //                             'บาท',
                                  //                             textAlign:
                                  //                                 TextAlign.end,
                                  //                             style: TextStyle(
                                  //                                 color: PeopleChaoScreen_Color
                                  //                                     .Colors_Text1_,
                                  //                                 // fontWeight: FontWeight.bold,
                                  //                                 fontFamily:
                                  //                                     Font_
                                  //                                         .Fonts_T
                                  //                                 //fontSize: 10.0
                                  //                                 ),
                                  //                           ),
                                  //                         ),
                                  //                       ],
                                  //                     ),

                                  //                     if (dtype_tep == 'KP' &&
                                  //                         numinvoice != null)
                                  //                       Align(
                                  //                         alignment:
                                  //                             Alignment.topLeft,
                                  //                         child: Container(
                                  //                           width: 360,
                                  //                           decoration:
                                  //                               BoxDecoration(
                                  //                             color: AppbackgroundColor
                                  //                                 .Sub_Abg_Colors,
                                  //                             borderRadius: const BorderRadius
                                  //                                     .only(
                                  //                                 topLeft:
                                  //                                     Radius.circular(
                                  //                                         10),
                                  //                                 topRight: Radius
                                  //                                     .circular(
                                  //                                         10),
                                  //                                 bottomLeft: Radius
                                  //                                     .circular(
                                  //                                         10),
                                  //                                 bottomRight: Radius
                                  //                                     .circular(
                                  //                                         10)),
                                  //                             // border: Border.all(
                                  //                             //     color: Colors.grey,
                                  //                             //     width: 1),
                                  //                           ),
                                  //                           padding:
                                  //                               const EdgeInsets
                                  //                                   .all(4.0),
                                  //                           child: Column(
                                  //                             crossAxisAlignment:
                                  //                                 CrossAxisAlignment
                                  //                                     .start,
                                  //                             mainAxisAlignment:
                                  //                                 MainAxisAlignment
                                  //                                     .start,
                                  //                             children: [
                                  //                               Divider(),
                                  //                               if (ref_id ==
                                  //                                       null ||
                                  //                                   ref_id.toString() ==
                                  //                                       'null')
                                  //                                 Align(
                                  //                                   alignment:
                                  //                                       Alignment
                                  //                                           .topLeft,
                                  //                                   child:
                                  //                                       AutoSizeText(
                                  //                                     minFontSize:
                                  //                                         8,
                                  //                                     maxFontSize:
                                  //                                         12,
                                  //                                     (ref_id == null ||
                                  //                                             ref_id.toString() == 'null')
                                  //                                         ? 'อ้างอิง : -'
                                  //                                         : 'อ้างอิง : ${ref_id.toString()}',
                                  //                                     maxLines:
                                  //                                         2,
                                  //                                     style: TextStyle(
                                  //                                         color: PeopleChaoScreen_Color
                                  //                                             .Colors_Text1_,
                                  //                                         fontWeight: FontWeight
                                  //                                             .bold,
                                  //                                         fontFamily:
                                  //                                             FontWeight_.Fonts_T
                                  //                                         //fontSize: 10.0
                                  //                                         ),
                                  //                                   ),
                                  //                                 ),
                                  //                               if (ref1 ==
                                  //                                       null ||
                                  //                                   ref1.toString() ==
                                  //                                       'null')
                                  //                                 Align(
                                  //                                   alignment:
                                  //                                       Alignment
                                  //                                           .topLeft,
                                  //                                   child:
                                  //                                       AutoSizeText(
                                  //                                     minFontSize:
                                  //                                         8,
                                  //                                     maxFontSize:
                                  //                                         12,
                                  //                                     (ref1 == null ||
                                  //                                             ref1.toString() == 'null')
                                  //                                         ? 'Ref1 : -'
                                  //                                         : 'Ref1 : ${ref1}',
                                  //                                     maxLines:
                                  //                                         2,
                                  //                                     style: TextStyle(
                                  //                                         color: PeopleChaoScreen_Color
                                  //                                             .Colors_Text1_,
                                  //                                         fontWeight: FontWeight
                                  //                                             .bold,
                                  //                                         fontFamily:
                                  //                                             FontWeight_.Fonts_T
                                  //                                         //fontSize: 10.0
                                  //                                         ),
                                  //                                   ),
                                  //                                 ),
                                  //                               if (ref2 ==
                                  //                                       null ||
                                  //                                   ref2.toString() ==
                                  //                                       'null')
                                  //                                 Align(
                                  //                                   alignment:
                                  //                                       Alignment
                                  //                                           .topLeft,
                                  //                                   child:
                                  //                                       AutoSizeText(
                                  //                                     minFontSize:
                                  //                                         8,
                                  //                                     maxFontSize:
                                  //                                         12,
                                  //                                     (ref2 == null ||
                                  //                                             ref2.toString() == 'null')
                                  //                                         ? 'Ref2 : -'
                                  //                                         : 'Ref2 : ${ref2}',
                                  //                                     maxLines:
                                  //                                         2,
                                  //                                     style: TextStyle(
                                  //                                         color: PeopleChaoScreen_Color
                                  //                                             .Colors_Text1_,
                                  //                                         fontWeight: FontWeight
                                  //                                             .bold,
                                  //                                         fontFamily:
                                  //                                             FontWeight_.Fonts_T
                                  //                                         //fontSize: 10.0
                                  //                                         ),
                                  //                                   ),
                                  //                                 ),
                                  //                               Align(
                                  //                                 alignment:
                                  //                                     Alignment
                                  //                                         .topLeft,
                                  //                                 child: Translate.TranslateAndSetText(
                                  //                                     (pdate == null ||
                                  //                                             pdate.toString() ==
                                  //                                                 'null')
                                  //                                         ? 'รูปแบบการชำระ ( วันที่ชำระ : ?? )'
                                  //                                         : 'รูปแบบการชำระ ( วันที่ชำระ : ${DateFormat('dd-MM').format(DateTime.parse('$pdate 00:00:00'))}-${DateTime.parse('$pdate 00:00:00').year + 0} )',
                                  //                                     AccountScreen_Color
                                  //                                         .Colors_Text1_,
                                  //                                     TextAlign
                                  //                                         .end,
                                  //                                     FontWeight
                                  //                                         .bold,
                                  //                                     FontWeight_
                                  //                                         .Fonts_T,
                                  //                                     14,
                                  //                                     1),
                                  //                               ),
                                  //                               for (var i = 0;
                                  //                                   i <
                                  //                                       finnancetransModels
                                  //                                           .length;
                                  //                                   i++)
                                  //                                 if (finnancetransModels[
                                  //                                             i]
                                  //                                         .dtype
                                  //                                         .toString() !=
                                  //                                     'FTA')
                                  //                                   Align(
                                  //                                     alignment:
                                  //                                         Alignment
                                  //                                             .topLeft,
                                  //                                     child:
                                  //                                         Column(
                                  //                                       crossAxisAlignment:
                                  //                                           CrossAxisAlignment.start,
                                  //                                       mainAxisAlignment:
                                  //                                           MainAxisAlignment.start,
                                  //                                       children: [
                                  //                                         Translate.TranslateAndSetText(
                                  //                                             '${i + 1}. Total : ${nFormat.format(double.parse(finnancetransModels[i].amt!))}  (${finnancetransModels[i].ptname})',
                                  //                                             AccountScreen_Color.Colors_Text1_,
                                  //                                             TextAlign.end,
                                  //                                             null,
                                  //                                             Font_.Fonts_T,
                                  //                                             14,
                                  //                                             1),
                                  //                                         if (finnancetransModels[i].type.toString() !=
                                  //                                             'CASH')
                                  //                                           AutoSizeText(
                                  //                                             minFontSize: 10,
                                  //                                             maxFontSize: 13,
                                  //                                             '  ** ${i + 1}.1. Bank : ${finnancetransModels[i].bank} , No. : ${finnancetransModels[i].bno}',
                                  //                                             style: TextStyle(
                                  //                                                 color: PeopleChaoScreen_Color.Colors_Text1_,
                                  //                                                 // fontWeight: FontWeight
                                  //                                                 //     .bold,
                                  //                                                 fontFamily: FontWeight_.Fonts_T
                                  //                                                 //fontSize: 10.0
                                  //                                                 ),
                                  //                                           ),
                                  //                                       ],
                                  //                                     ),
                                  //                                   ),
                                  //                             ],
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     // Row(
                                  //                     //   children: [
                                  //                     //     Expanded(
                                  //                     //       flex: 3,
                                  //                     //       child: Text(
                                  //                     //         'รูปแบบการชำระ',
                                  //                     //         textAlign:
                                  //                     //             TextAlign.start,
                                  //                     //         style: TextStyle(
                                  //                     //             color: PeopleChaoScreen_Color
                                  //                     //                 .Colors_Text1_,
                                  //                     //             fontWeight:
                                  //                     //                 FontWeight
                                  //                     //                     .bold,
                                  //                     //             fontFamily:
                                  //                     //                 FontWeight_
                                  //                     //                     .Fonts_T
                                  //                     //             //fontSize: 10.0
                                  //                     //             ),
                                  //                     //       ),
                                  //                     //     ),
                                  //                     //     Expanded(
                                  //                     //       flex: 4,
                                  //                     //       child: Column(
                                  //                     //         mainAxisAlignment:
                                  //                     //             MainAxisAlignment
                                  //                     //                 .end,
                                  //                     //         crossAxisAlignment:
                                  //                     //             CrossAxisAlignment
                                  //                     //                 .end,
                                  //                     //         children: [
                                  //                     //           for (var i = 0;
                                  //                     //               i <
                                  //                     //                   finnancetransModels
                                  //                     //                       .length;
                                  //                     //               i++)
                                  //                     //             finnancetransModels[
                                  //                     //                             i]
                                  //                     //                         .dtype ==
                                  //                     //                     'KP'
                                  //                     //                 ? AutoSizeText(
                                  //                     //                     minFontSize:
                                  //                     //                         10,
                                  //                     //                     maxFontSize:
                                  //                     //                         15,
                                  //                     //                     finnancetransModels[i].type ==
                                  //                     //                             'CASH'
                                  //                     //                         ? '${finnancetransModels[i].type} (เงินสด)'
                                  //                     //                         : '${finnancetransModels[i].type} (เงินโอน)',
                                  //                     //                     textAlign:
                                  //                     //                         TextAlign
                                  //                     //                             .end,
                                  //                     //                     style: TextStyle(
                                  //                     //                         color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //                     //                         //fontWeight: FontWeight.bold,
                                  //                     //                         fontFamily: Font_.Fonts_T),
                                  //                     //                   )
                                  //                     //                 : AutoSizeText(
                                  //                     //                     minFontSize:
                                  //                     //                         10,
                                  //                     //                     maxFontSize:
                                  //                     //                         15,
                                  //                     //                     '${finnancetransModels[i].remark}',
                                  //                     //                     textAlign:
                                  //                     //                         TextAlign
                                  //                     //                             .end,
                                  //                     //                     style: TextStyle(
                                  //                     //                         color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //                     //                         //fontWeight: FontWeight.bold,
                                  //                     //                         fontFamily: Font_.Fonts_T),
                                  //                     //                   ),
                                  //                     //         ],
                                  //                     //       ),
                                  //                     //     ),
                                  //                     //   ],
                                  //                     // ),
                                  //                     // for (var i = 0;
                                  //                     //     i <
                                  //                     //         finnancetransModels
                                  //                     //             .length;
                                  //                     //     i++)
                                  //                     //   Row(
                                  //                     //     children: [
                                  //                     //       Expanded(
                                  //                     //         flex: 2,
                                  //                     //         child: AutoSizeText(
                                  //                     //           minFontSize: 10,
                                  //                     //           maxFontSize: 15,
                                  //                     //           textAlign:
                                  //                     //               TextAlign.start,
                                  //                     //           nFormat.format(sum_amt -
                                  //                     //                       sum_disamt -
                                  //                     //                       total_amt) ==
                                  //                     //                   nFormat.format(
                                  //                     //                       double.parse(
                                  //                     //                           finnancetransModels[i].amt!))
                                  //                     //               ? ''
                                  //                     //               : 'ยอดรับชำระไม่กับยอดชำระ',
                                  //                     //           style: TextStyle(
                                  //                     //               color:
                                  //                     //                   Colors.red,
                                  //                     //               //fontWeight: FontWeight.bold,
                                  //                     //               fontFamily: Font_
                                  //                     //                   .Fonts_T),
                                  //                     //         ),
                                  //                     //       ),
                                  //                     //       Expanded(
                                  //                     //         flex: 2,
                                  //                     //         child: AutoSizeText(
                                  //                     //           minFontSize: 10,
                                  //                     //           maxFontSize: 15,
                                  //                     //           textAlign:
                                  //                     //               TextAlign.end,
                                  //                     //           'จำนวน',
                                  //                     //           style: TextStyle(
                                  //                     //               color: PeopleChaoScreen_Color
                                  //                     //                   .Colors_Text2_,
                                  //                     //               //fontWeight: FontWeight.bold,
                                  //                     //               fontFamily: Font_
                                  //                     //                   .Fonts_T),
                                  //                     //         ),
                                  //                     //       ),
                                  //                     //       Expanded(
                                  //                     //         flex: 2,
                                  //                     //         child: AutoSizeText(
                                  //                     //           minFontSize: 10,
                                  //                     //           maxFontSize: 15,
                                  //                     //           '${nFormat.format(double.parse(finnancetransModels[i].amt!))}',
                                  //                     //           textAlign:
                                  //                     //               TextAlign.end,
                                  //                     //           style: TextStyle(
                                  //                     //               color: nFormat.format(sum_amt -
                                  //                     //                           sum_disamt -
                                  //                     //                           total_amt) ==
                                  //                     //                       nFormat.format(double.parse(finnancetransModels[i]
                                  //                     //                           .amt!))
                                  //                     //                   ? PeopleChaoScreen_Color
                                  //                     //                       .Colors_Text2_
                                  //                     //                   : Colors
                                  //                     //                       .red,
                                  //                     //               //fontWeight: FontWeight.bold,
                                  //                     //               fontFamily: Font_
                                  //                     //                   .Fonts_T),
                                  //                     //         ),
                                  //                     //       ),
                                  //                     //       Expanded(
                                  //                     //         flex: 1,
                                  //                     //         child: Text(
                                  //                     //           'บาท',
                                  //                     //           textAlign:
                                  //                     //               TextAlign.end,
                                  //                     //           style: TextStyle(
                                  //                     //               color: PeopleChaoScreen_Color
                                  //                     //                   .Colors_Text1_,
                                  //                     //               // fontWeight: FontWeight.bold,
                                  //                     //               fontFamily:
                                  //                     //                   Font_
                                  //                     //                       .Fonts_T
                                  //                     //               //fontSize: 10.0
                                  //                     //               ),
                                  //                     //         ),
                                  //                     //       ),
                                  //                     //     ],
                                  //                     //   ),
                                  //                   ],
                                  //                 ),
                                  //               ),
                                  //               Expanded(
                                  //                 flex: 2,
                                  //                 child: Padding(
                                  //                   padding:
                                  //                       const EdgeInsets.all(
                                  //                           8.0),
                                  //                   child: (dtype_tep == '!Z')
                                  //                       ? (numinvoice == null)
                                  //                           ? SizedBox()
                                  //                           : SizedBox(
                                  //                               child: Padding(
                                  //                                 padding:
                                  //                                     const EdgeInsets
                                  //                                             .all(
                                  //                                         8.0),
                                  //                                 child:
                                  //                                     InkWell(
                                  //                                   child:
                                  //                                       Container(
                                  //                                     height:
                                  //                                         80,
                                  //                                     decoration:
                                  //                                         BoxDecoration(
                                  //                                       color: (Slip_history.toString() == null ||
                                  //                                               Slip_history == null ||
                                  //                                               Slip_history.toString() == 'null')
                                  //                                           ? Colors.green[200]
                                  //                                           : Colors.green,
                                  //                                       borderRadius: const BorderRadius.only(
                                  //                                           topLeft:
                                  //                                               Radius.circular(8),
                                  //                                           topRight: Radius.circular(8),
                                  //                                           bottomLeft: Radius.circular(8),
                                  //                                           bottomRight: Radius.circular(8)),
                                  //                                       // border: Border.all(
                                  //                                       //     color: Colors.grey, width: 2),
                                  //                                     ),
                                  //                                     padding:
                                  //                                         const EdgeInsets.all(
                                  //                                             8.0),
                                  //                                     child:
                                  //                                         Center(
                                  //                                       child:
                                  //                                           Text(
                                  //                                         (Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null')
                                  //                                             ? 'ไม่พบหลักฐาน'
                                  //                                             : 'พบหลักฐาน ',
                                  //                                         textAlign:
                                  //                                             TextAlign.center,
                                  //                                         style: const TextStyle(
                                  //                                             color: Colors.white,
                                  //                                             fontWeight: FontWeight.bold,
                                  //                                             fontFamily: Font_.Fonts_T
                                  //                                             //fontSize: 10.0
                                  //                                             ),
                                  //                                       ),
                                  //                                     ),
                                  //                                   ),
                                  //                                   onTap: (Slip_history.toString() == null ||
                                  //                                           Slip_history ==
                                  //                                               null ||
                                  //                                           Slip_history.toString() ==
                                  //                                               'null')
                                  //                                       ? null
                                  //                                       : () async {
                                  //                                           String
                                  //                                               Url =
                                  //                                               await '${MyConstant().domain}/files/$foder/slip/${Slip_history}';
                                  //                                           showDialog(
                                  //                                             context: context,
                                  //                                             builder: (context) => AlertDialog(
                                  //                                                 title: Center(
                                  //                                                   child: Column(
                                  //                                                     children: [
                                  //                                                       Text(
                                  //                                                         numinvoice == null
                                  //                                                             ? 'บิลเลขที่'
                                  //                                                             : numdoctax == ''
                                  //                                                                 ? 'บิลเลขที่ $numinvoice'
                                  //                                                                 : 'บิลเลขที่ $numdoctax',
                                  //                                                         maxLines: 1,
                                  //                                                         textAlign: TextAlign.start,
                                  //                                                         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                  //                                                       ),
                                  //                                                       Text(
                                  //                                                         '${Slip_history}',
                                  //                                                         textAlign: TextAlign.center,
                                  //                                                         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                  //                                                       ),
                                  //                                                     ],
                                  //                                                   ),
                                  //                                                 ),
                                  //                                                 content: Stack(
                                  //                                                   alignment: Alignment.center,
                                  //                                                   children: <Widget>[
                                  //                                                     Image.network('$Url')
                                  //                                                   ],
                                  //                                                 ),
                                  //                                                 actions: <Widget>[
                                  //                                                   Column(
                                  //                                                     children: [
                                  //                                                       const SizedBox(
                                  //                                                         height: 5.0,
                                  //                                                       ),
                                  //                                                       const Divider(
                                  //                                                         color: Colors.grey,
                                  //                                                         height: 4.0,
                                  //                                                       ),
                                  //                                                       const SizedBox(
                                  //                                                         height: 5.0,
                                  //                                                       ),
                                  //                                                       Row(
                                  //                                                         mainAxisAlignment: MainAxisAlignment.center,
                                  //                                                         children: [
                                  //                                                           Padding(
                                  //                                                             padding: const EdgeInsets.all(8.0),
                                  //                                                             child: Container(
                                  //                                                               width: 100,
                                  //                                                               decoration: const BoxDecoration(
                                  //                                                                 color: Colors.black,
                                  //                                                                 borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                                                               ),
                                  //                                                               padding: const EdgeInsets.all(8.0),
                                  //                                                               child: TextButton(
                                  //                                                                 onPressed: () => Navigator.pop(context, 'OK'),
                                  //                                                                 child: const Text(
                                  //                                                                   'ปิด',
                                  //                                                                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                                 ),
                                  //                                                               ),
                                  //                                                             ),
                                  //                                                           ),
                                  //                                                         ],
                                  //                                                       ),
                                  //                                                     ],
                                  //                                                   ),
                                  //                                                 ]),
                                  //                                           );
                                  //                                         },
                                  //                                 ),
                                  //                               ),
                                  //                             )
                                  //                       : (numinvoice == null)
                                  //                           ? SizedBox()
                                  //                           : Container(
                                  //                               child: Column(
                                  //                                 mainAxisAlignment:
                                  //                                     MainAxisAlignment
                                  //                                         .start,
                                  //                                 crossAxisAlignment:
                                  //                                     CrossAxisAlignment
                                  //                                         .start,
                                  //                                 children: [
                                  //                                   Row(
                                  //                                     mainAxisAlignment:
                                  //                                         MainAxisAlignment
                                  //                                             .start,
                                  //                                     crossAxisAlignment:
                                  //                                         CrossAxisAlignment
                                  //                                             .start,
                                  //                                     children: [
                                  //                                       Expanded(
                                  //                                         child: (Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null')
                                  //                                             ? SizedBox()
                                  //                                             : Padding(
                                  //                                                 padding: const EdgeInsets.all(8.0),
                                  //                                                 child: InkWell(
                                  //                                                   child: Container(
                                  //                                                     height: 80,
                                  //                                                     decoration: BoxDecoration(
                                  //                                                       color: (Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null') ? Colors.green[200] : Colors.green,
                                  //                                                       borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8), bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                  //                                                       // border: Border.all(
                                  //                                                       //     color: Colors.grey, width: 2),
                                  //                                                     ),
                                  //                                                     padding: const EdgeInsets.all(8.0),
                                  //                                                     child: Center(
                                  //                                                       child: Text(
                                  //                                                         (Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null') ? 'ไม่พบหลักฐาน' : 'พบหลักฐาน ',
                                  //                                                         textAlign: TextAlign.center,
                                  //                                                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T
                                  //                                                             //fontSize: 10.0
                                  //                                                             ),
                                  //                                                       ),
                                  //                                                     ),
                                  //                                                   ),
                                  //                                                   onTap: (Slip_history.toString() == null || Slip_history == null || Slip_history.toString() == 'null')
                                  //                                                       ? null
                                  //                                                       : () async {
                                  //                                                           String Url = await '${MyConstant().domain}/files/$foder/slip/${Slip_history}';
                                  //                                                           showDialog(
                                  //                                                             context: context,
                                  //                                                             builder: (context) => AlertDialog(
                                  //                                                                 title: Center(
                                  //                                                                   child: Column(
                                  //                                                                     children: [
                                  //                                                                       Text(
                                  //                                                                         numinvoice == null
                                  //                                                                             ? 'บิลเลขที่'
                                  //                                                                             : numdoctax == ''
                                  //                                                                                 ? 'บิลเลขที่ $numinvoice'
                                  //                                                                                 : 'บิลเลขที่ $numdoctax',
                                  //                                                                         maxLines: 1,
                                  //                                                                         textAlign: TextAlign.start,
                                  //                                                                         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                  //                                                                       ),
                                  //                                                                       Text(
                                  //                                                                         '${Slip_history}',
                                  //                                                                         textAlign: TextAlign.center,
                                  //                                                                         style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                  //                                                                       ),
                                  //                                                                     ],
                                  //                                                                   ),
                                  //                                                                 ),
                                  //                                                                 content: Stack(
                                  //                                                                   alignment: Alignment.center,
                                  //                                                                   children: <Widget>[
                                  //                                                                     Image.network('$Url')
                                  //                                                                   ],
                                  //                                                                 ),
                                  //                                                                 actions: <Widget>[
                                  //                                                                   Column(
                                  //                                                                     children: [
                                  //                                                                       const SizedBox(
                                  //                                                                         height: 5.0,
                                  //                                                                       ),
                                  //                                                                       const Divider(
                                  //                                                                         color: Colors.grey,
                                  //                                                                         height: 4.0,
                                  //                                                                       ),
                                  //                                                                       const SizedBox(
                                  //                                                                         height: 5.0,
                                  //                                                                       ),
                                  //                                                                       Row(
                                  //                                                                         mainAxisAlignment: MainAxisAlignment.center,
                                  //                                                                         children: [
                                  //                                                                           Padding(
                                  //                                                                             padding: const EdgeInsets.all(8.0),
                                  //                                                                             child: Container(
                                  //                                                                               width: 100,
                                  //                                                                               decoration: const BoxDecoration(
                                  //                                                                                 color: Colors.black,
                                  //                                                                                 borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                                                                               ),
                                  //                                                                               padding: const EdgeInsets.all(8.0),
                                  //                                                                               child: TextButton(
                                  //                                                                                 onPressed: () => Navigator.pop(context, 'OK'),
                                  //                                                                                 child: const Text(
                                  //                                                                                   'ปิด',
                                  //                                                                                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                                                 ),
                                  //                                                                               ),
                                  //                                                                             ),
                                  //                                                                           ),
                                  //                                                                         ],
                                  //                                                                       ),
                                  //                                                                     ],
                                  //                                                                   ),
                                  //                                                                 ]),
                                  //                                                           );
                                  //                                                         },
                                  //                                                 ),
                                  //                                               ),
                                  //                                       ),
                                  //                                       Expanded(
                                  //                                         child: numdoctax != ''
                                  //                                             ? SizedBox()
                                  //                                             : Padding(
                                  //                                                 padding: const EdgeInsets.all(8.0),
                                  //                                                 child: InkWell(
                                  //                                                   onTap: () {
                                  //                                                     PanaraConfirmDialog.showAnimatedGrow(
                                  //                                                       context,
                                  //                                                       title: "เปลี่ยนสถานะบิล",
                                  //                                                       message: "เปลี่ยนสถานะบิลเป็นใบกำกับภาษี",
                                  //                                                       confirmButtonText: "Confirm",
                                  //                                                       cancelButtonText: "Cancel",
                                  //                                                       onTapConfirm: () async {
                                  //                                                         setState(() {
                                  //                                                           pPC_finantIbillREbill();
                                  //                                                         });

                                  //                                                         Navigator.pop(context);
                                  //                                                       },
                                  //                                                       onTapCancel: () {
                                  //                                                         Navigator.pop(context);
                                  //                                                       },
                                  //                                                       panaraDialogType: PanaraDialogType.success,
                                  //                                                     );
                                  //                                                   },
                                  //                                                   child: Container(
                                  //                                                       height: 80,
                                  //                                                       decoration: BoxDecoration(
                                  //                                                         color: Colors.green[200],
                                  //                                                         borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                                                         // border: Border.all(color: Colors.white, width: 1),
                                  //                                                       ),
                                  //                                                       padding: const EdgeInsets.all(8.0),
                                  //                                                       child: const Center(
                                  //                                                           child: Text(
                                  //                                                         'เปลี่ยนสถานะบิล',
                                  //                                                         style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                       ))),
                                  //                                                 ),
                                  //                                               ),
                                  //                                       ),
                                  //                                     ],
                                  //                                   ),
                                  //                                   Row(
                                  //                                     mainAxisAlignment:
                                  //                                         MainAxisAlignment
                                  //                                             .start,
                                  //                                     crossAxisAlignment:
                                  //                                         CrossAxisAlignment
                                  //                                             .start,
                                  //                                     children: [
                                  //                                       Expanded(
                                  //                                         child: _TransReBillHistoryModels.length == 0
                                  //                                             ? SizedBox()
                                  //                                             : Padding(
                                  //                                                 padding: const EdgeInsets.all(8.0),
                                  //                                                 child: InkWell(
                                  //                                                   onTap: (_TransReBillHistoryModels.length == 0)
                                  //                                                       ? null
                                  //                                                       : () {
                                  //                                                           final tableData00 = [
                                  //                                                             // for (int index = 0; index < _TransReBillHistoryModels.length; index++)
                                  //                                                             //   [
                                  //                                                             //     '${index + 1}',
                                  //                                                             //     '${_TransReBillHistoryModels[index].date}',
                                  //                                                             //     '${_TransReBillHistoryModels[index].expname}',
                                  //                                                             //     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                  //                                                             //     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                  //                                                             //     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                  //                                                             //     '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                  //                                                             //   ],
                                  //                                                           ];

                                  //                                                           List newValuePDFimg = [];
                                  //                                                           for (int index = 0; index < 1; index++) {
                                  //                                                             if (renTalModels[0].imglogo!.trim() == '') {
                                  //                                                               // newValuePDFimg.add(
                                  //                                                               //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                  //                                                             } else {
                                  //                                                               newValuePDFimg.add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                  //                                                             }
                                  //                                                           }

                                  //                                                           ////////////////////----------------->
                                  //                                                           // //print(tableData00);
                                  //                                                           showMyDialog_SAVE(tableData00, newValuePDFimg, room_number_BillHistory);
                                  //                                                         },
                                  //                                                   child: Container(
                                  //                                                       height: 80,
                                  //                                                       decoration: const BoxDecoration(
                                  //                                                         color: Colors.blue,
                                  //                                                         borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                                                         // border: Border.all(color: Colors.white, width: 1),
                                  //                                                       ),
                                  //                                                       padding: EdgeInsets.all(8.0),
                                  //                                                       child: Center(
                                  //                                                           child: Text(
                                  //                                                         'พิมพ์',
                                  //                                                         style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                       ))),
                                  //                                                 ),
                                  //                                               ),
                                  //                                       ),
                                  //                                       Expanded(
                                  //                                         child: (Cancell_bill.toString() == '1')
                                  //                                             ? SizedBox()
                                  //                                             :
                                  //                                             // (fin_datex ==
                                  //                                             //         null)
                                  //                                             //     ? SizedBox()
                                  //                                             //     :
                                  //                                             // DateTime.parse('$fin_datex 00:00:00')
                                  //                                             //             .add(Duration(days: int.parse('${Day_Cancell_bill}')))
                                  //                                             //             .isBefore(newDatetime) &&
                                  //                                             //         Day_Cancell_bill.toString() != '0'
                                  //                                             //     ? SizedBox()
                                  //                                             //     :
                                  //                                             Padding(
                                  //                                                 padding: const EdgeInsets.all(8.0),
                                  //                                                 child: InkWell(
                                  //                                                   onTap: () async {
                                  //                                                     final Formbecause_ = TextEditingController();
                                  //                                                     // pPC_finantIbill();

                                  //                                                     showDialog<String>(
                                  //                                                       context: context,
                                  //                                                       builder: (BuildContext context) => AlertDialog(
                                  //                                                         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                  //                                                         title: const Center(
                                  //                                                             child: Text(
                                  //                                                           'ยกเลิกการรับชำระ',
                                  //                                                           style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                         )),
                                  //                                                         content: Container(
                                  //                                                           height: 120,
                                  //                                                           child: Column(
                                  //                                                             children: [
                                  //                                                               const SizedBox(
                                  //                                                                 height: 2.0,
                                  //                                                               ),
                                  //                                                               Text(
                                  //                                                                 'บิลเลขที่ ${numinvoice}',
                                  //                                                                 style: const TextStyle(
                                  //                                                                     color: AccountScreen_Color.Colors_Text2_,
                                  //                                                                     // fontWeight:
                                  //                                                                     //     FontWeight.bold,
                                  //                                                                     fontFamily: Font_.Fonts_T),
                                  //                                                               ),
                                  //                                                               Padding(
                                  //                                                                 padding: const EdgeInsets.all(8.0),
                                  //                                                                 child: TextFormField(
                                  //                                                                   keyboardType: TextInputType.number,
                                  //                                                                   controller: Formbecause_,
                                  //                                                                   validator: (value) {
                                  //                                                                     if (value == null || value.isEmpty) {
                                  //                                                                       return 'ใส่ข้อมูลให้ครบถ้วน ';
                                  //                                                                     }
                                  //                                                                     // if (int.parse(value.toString()) < 13) {
                                  //                                                                     //   return '< 13';
                                  //                                                                     // }
                                  //                                                                     return null;
                                  //                                                                   },
                                  //                                                                   // maxLength: 13,
                                  //                                                                   cursorColor: Colors.green,
                                  //                                                                   decoration: InputDecoration(
                                  //                                                                       fillColor: Colors.white.withOpacity(0.3),
                                  //                                                                       filled: true,
                                  //                                                                       // prefixIcon: const Icon(Icons.water,
                                  //                                                                       //     color: Colors.blue),
                                  //                                                                       // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                  //                                                                       focusedBorder: const OutlineInputBorder(
                                  //                                                                         borderRadius: BorderRadius.only(
                                  //                                                                           topRight: Radius.circular(15),
                                  //                                                                           topLeft: Radius.circular(15),
                                  //                                                                           bottomRight: Radius.circular(15),
                                  //                                                                           bottomLeft: Radius.circular(15),
                                  //                                                                         ),
                                  //                                                                         borderSide: BorderSide(
                                  //                                                                           width: 1,
                                  //                                                                           color: Colors.black,
                                  //                                                                         ),
                                  //                                                                       ),
                                  //                                                                       enabledBorder: const OutlineInputBorder(
                                  //                                                                         borderRadius: BorderRadius.only(
                                  //                                                                           topRight: Radius.circular(15),
                                  //                                                                           topLeft: Radius.circular(15),
                                  //                                                                           bottomRight: Radius.circular(15),
                                  //                                                                           bottomLeft: Radius.circular(15),
                                  //                                                                         ),
                                  //                                                                         borderSide: BorderSide(
                                  //                                                                           width: 1,
                                  //                                                                           color: Colors.grey,
                                  //                                                                         ),
                                  //                                                                       ),
                                  //                                                                       labelText: 'หมายเหตุ',
                                  //                                                                       labelStyle: const TextStyle(
                                  //                                                                         color: AccountScreen_Color.Colors_Text2_,
                                  //                                                                         // fontWeight:
                                  //                                                                         //     FontWeight.bold,
                                  //                                                                         fontFamily: Font_.Fonts_T,
                                  //                                                                       )),
                                  //                                                                   // inputFormatters: <TextInputFormatter>[
                                  //                                                                   //   // for below version 2 use this
                                  //                                                                   //   FilteringTextInputFormatter.allow(
                                  //                                                                   //       RegExp(r'[0-9]')),
                                  //                                                                   //   // for version 2 and greater youcan also use this
                                  //                                                                   //   FilteringTextInputFormatter.digitsOnly
                                  //                                                                   // ],
                                  //                                                                 ),
                                  //                                                               ),
                                  //                                                               const SizedBox(
                                  //                                                                 height: 5.0,
                                  //                                                               ),
                                  //                                                             ],
                                  //                                                           ),
                                  //                                                         ),
                                  //                                                         actions: <Widget>[
                                  //                                                           Padding(
                                  //                                                             padding: const EdgeInsets.all(8.0),
                                  //                                                             child: Container(
                                  //                                                               width: 150,
                                  //                                                               height: 40,
                                  //                                                               // ignore: deprecated_member_use
                                  //                                                               child: ElevatedButton(
                                  //                                                                 style: ElevatedButton.styleFrom(
                                  //                                                                   backgroundColor: Colors.green,
                                  //                                                                 ),
                                  //                                                                 onPressed: () {
                                  //                                                                   String Formbecause = Formbecause_.text.toString();
                                  //                                                                   if (Formbecause == '') {
                                  //                                                                     showDialog<String>(
                                  //                                                                       context: context,
                                  //                                                                       builder: (BuildContext context) => AlertDialog(
                                  //                                                                         shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                  //                                                                         title: const Center(
                                  //                                                                             child: Text(
                                  //                                                                           'กรุณากรอกเหตุผล !!',
                                  //                                                                           style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                                         )),
                                  //                                                                         actions: <Widget>[
                                  //                                                                           Padding(
                                  //                                                                             padding: const EdgeInsets.all(8.0),
                                  //                                                                             child: Row(
                                  //                                                                               mainAxisAlignment: MainAxisAlignment.center,
                                  //                                                                               children: [
                                  //                                                                                 Container(
                                  //                                                                                   width: 100,
                                  //                                                                                   decoration: const BoxDecoration(
                                  //                                                                                     color: Colors.redAccent,
                                  //                                                                                     borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                                                                                   ),
                                  //                                                                                   padding: const EdgeInsets.all(8.0),
                                  //                                                                                   child: TextButton(
                                  //                                                                                     onPressed: () => Navigator.pop(context, 'OK'),
                                  //                                                                                     child: const Text(
                                  //                                                                                       'ปิด',
                                  //                                                                                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                                                     ),
                                  //                                                                                   ),
                                  //                                                                                 ),
                                  //                                                                               ],
                                  //                                                                             ),
                                  //                                                                           ),
                                  //                                                                         ],
                                  //                                                                       ),
                                  //                                                                     );
                                  //                                                                   } else {
                                  //                                                                     pPC_finantIbill(Formbecause);
                                  //                                                                     setState(() {
                                  //                                                                       Formbecause_.clear();
                                  //                                                                     });
                                  //                                                                     Navigator.pop(context, 'OK');
                                  //                                                                   }
                                  //                                                                 },
                                  //                                                                 child: const Text(
                                  //                                                                   'ยืนยัน',
                                  //                                                                   style: TextStyle(
                                  //                                                                     // fontSize: 20.0,
                                  //                                                                     // fontWeight: FontWeight.bold,
                                  //                                                                     color: Colors.white,
                                  //                                                                   ),
                                  //                                                                 ),
                                  //                                                                 // color: Colors.black,
                                  //                                                               ),
                                  //                                                             ),
                                  //                                                           ),
                                  //                                                           Padding(
                                  //                                                             padding: const EdgeInsets.all(8.0),
                                  //                                                             child: Container(
                                  //                                                               width: 150,
                                  //                                                               height: 40,
                                  //                                                               // ignore: deprecated_member_use
                                  //                                                               child: ElevatedButton(
                                  //                                                                 style: ElevatedButton.styleFrom(
                                  //                                                                   backgroundColor: Colors.black,
                                  //                                                                 ),
                                  //                                                                 onPressed: () {
                                  //                                                                   setState(() {
                                  //                                                                     Formbecause_.clear();
                                  //                                                                   });
                                  //                                                                   Navigator.pop(context, 'OK');
                                  //                                                                 },
                                  //                                                                 child: const Text(
                                  //                                                                   'ปิด',
                                  //                                                                   style: TextStyle(
                                  //                                                                     // fontSize: 20.0,
                                  //                                                                     // fontWeight: FontWeight.bold,
                                  //                                                                     color: Colors.white,
                                  //                                                                   ),
                                  //                                                                 ),
                                  //                                                                 // color: Colors.black,
                                  //                                                               ),
                                  //                                                             ),
                                  //                                                           ),
                                  //                                                         ],
                                  //                                                       ),
                                  //                                                     );
                                  //                                                   },
                                  //                                                   child: Container(
                                  //                                                       height: 80,
                                  //                                                       decoration: BoxDecoration(
                                  //                                                         color: Colors.red,
                                  //                                                         borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                  //                                                         // border: Border.all(color: Colors.white, width: 1),
                                  //                                                       ),
                                  //                                                       padding: EdgeInsets.all(8.0),
                                  //                                                       child: Center(
                                  //                                                           child: Text(
                                  //                                                         'ยกเลิกรับชำระ',
                                  //                                                         style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                  //                                                       ))),
                                  //                                                 ),
                                  //                                               ),
                                  //                                       ),
                                  //                                     ],
                                  //                                   ),
                                  //                                 ],
                                  //                               ),
                                  //                             ),
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         )
                                  //       ],
                                  //     ))
                                ])),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        // dtypeselect == '!Z'
        //     ? SizedBox()
        //     : _TransReBillHistoryModels.length == 0
        //         ? SizedBox()
        //         : Align(
        //             alignment: Alignment.topRight,
        //             child: SingleChildScrollView(
        //               scrollDirection: Axis.horizontal,
        //               child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.end,
        //                 children: [
        //                   Padding(
        //                     padding: const EdgeInsets.all(16.0),
        //                     child: Container(
        //                       width: (Responsive.isDesktop(context))
        //                           ? MediaQuery.of(context).size.width * 0.52
        //                           : 900,
        //                       padding: EdgeInsets.only(right: 55),
        //                       child: Column(
        //                         children: [
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 50,
        //                                   decoration: BoxDecoration(
        //                                     color: Colors.green[200],
        //                                     borderRadius:
        //                                         const BorderRadius.only(
        //                                       topLeft: Radius.circular(10),
        //                                       topRight: Radius.circular(10),
        //                                       bottomLeft: Radius.circular(0),
        //                                       bottomRight: Radius.circular(0),
        //                                     ),
        //                                     // border: Border.all(
        //                                     //     color: Colors.grey, width: 1),
        //                                   ),
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Center(
        //                                     child: Text(
        //                                       numinvoice == null
        //                                           ? 'บิลเลขที่'
        //                                           : numdoctax == ''
        //                                               ? 'บิลเลขที่ $numinvoice'
        //                                               : 'บิลเลขที่ $numdoctax',
        //                                       textAlign: TextAlign.center,
        //                                       style: TextStyle(
        //                                           color: PeopleChaoScreen_Color
        //                                               .Colors_Text1_,
        //                                           fontWeight: FontWeight.bold,
        //                                           fontFamily:
        //                                               FontWeight_.Fonts_T
        //                                           //fontSize: 10.0
        //                                           ),
        //                                     ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 10,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     '',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'หลักฐานการโอน',
        //                                     textAlign: TextAlign.start,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     '',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: InkWell(
        //                                   child: Container(
        //                                     height: 40,
        //                                     decoration: BoxDecoration(
        //                                       color: (Slip_history.toString() ==
        //                                                   null ||
        //                                               Slip_history == null ||
        //                                               Slip_history.toString() ==
        //                                                   'null')
        //                                           ? Colors.green[200]
        //                                           : Colors.green,
        //                                       borderRadius:
        //                                           const BorderRadius.only(
        //                                               topLeft:
        //                                                   Radius.circular(8),
        //                                               topRight:
        //                                                   Radius.circular(8),
        //                                               bottomLeft:
        //                                                   Radius.circular(8),
        //                                               bottomRight:
        //                                                   Radius.circular(8)),
        //                                       // border: Border.all(
        //                                       //     color: Colors.grey, width: 2),
        //                                     ),
        //                                     padding: const EdgeInsets.all(8.0),
        //                                     child: Center(
        //                                       child: Text(
        //                                         (Slip_history.toString() ==
        //                                                     null ||
        //                                                 Slip_history == null ||
        //                                                 Slip_history
        //                                                         .toString() ==
        //                                                     'null')
        //                                             ? 'ไม่พบหลักฐาน'
        //                                             : 'พบหลักฐาน ',
        //                                         textAlign: TextAlign.center,
        //                                         style: const TextStyle(
        //                                             color: Colors.white,
        //                                             fontWeight: FontWeight.bold,
        //                                             fontFamily: Font_.Fonts_T
        //                                             //fontSize: 10.0
        //                                             ),
        //                                       ),
        //                                     ),
        //                                   ),
        //                                   onTap:
        //                                       (Slip_history.toString() ==
        //                                                   null ||
        //                                               Slip_history == null ||
        //                                               Slip_history.toString() ==
        //                                                   'null')
        //                                           ? null
        //                                           : () async {
        //                                               String Url =
        //                                                   await '${MyConstant().domain}/files/$foder/slip/${Slip_history}';
        //                                               showDialog(
        //                                                 context: context,
        //                                                 builder: (context) =>
        //                                                     AlertDialog(
        //                                                         title: Center(
        //                                                           child: Column(
        //                                                             children: [
        //                                                               Text(
        //                                                                 numinvoice ==
        //                                                                         null
        //                                                                     ? 'บิลเลขที่'
        //                                                                     : numdoctax == ''
        //                                                                         ? 'บิลเลขที่ $numinvoice'
        //                                                                         : 'บิลเลขที่ $numdoctax',
        //                                                                 maxLines:
        //                                                                     1,
        //                                                                 textAlign:
        //                                                                     TextAlign.start,
        //                                                                 style: const TextStyle(
        //                                                                     color:
        //                                                                         Colors.black,
        //                                                                     fontWeight: FontWeight.bold,
        //                                                                     fontFamily: FontWeight_.Fonts_T,
        //                                                                     fontSize: 12.0),
        //                                                               ),
        //                                                               Text(
        //                                                                 '${Slip_history}',
        //                                                                 textAlign:
        //                                                                     TextAlign.center,
        //                                                                 style: const TextStyle(
        //                                                                     color:
        //                                                                         Colors.black,
        //                                                                     fontWeight: FontWeight.bold,
        //                                                                     fontFamily: FontWeight_.Fonts_T,
        //                                                                     fontSize: 12.0),
        //                                                               ),
        //                                                             ],
        //                                                           ),
        //                                                         ),
        //                                                         content: Stack(
        //                                                           alignment:
        //                                                               Alignment
        //                                                                   .center,
        //                                                           children: <Widget>[
        //                                                             Image.network(
        //                                                                 '$Url')
        //                                                           ],
        //                                                         ),
        //                                                         actions: <Widget>[
        //                                                       Column(
        //                                                         children: [
        //                                                           const SizedBox(
        //                                                             height: 5.0,
        //                                                           ),
        //                                                           const Divider(
        //                                                             color: Colors
        //                                                                 .grey,
        //                                                             height: 4.0,
        //                                                           ),
        //                                                           const SizedBox(
        //                                                             height: 5.0,
        //                                                           ),
        //                                                           Row(
        //                                                             mainAxisAlignment:
        //                                                                 MainAxisAlignment
        //                                                                     .center,
        //                                                             children: [
        //                                                               Padding(
        //                                                                 padding:
        //                                                                     const EdgeInsets.all(8.0),
        //                                                                 child:
        //                                                                     Container(
        //                                                                   width:
        //                                                                       100,
        //                                                                   decoration:
        //                                                                       const BoxDecoration(
        //                                                                     color:
        //                                                                         Colors.black,
        //                                                                     borderRadius: BorderRadius.only(
        //                                                                         topLeft: Radius.circular(10),
        //                                                                         topRight: Radius.circular(10),
        //                                                                         bottomLeft: Radius.circular(10),
        //                                                                         bottomRight: Radius.circular(10)),
        //                                                                   ),
        //                                                                   padding:
        //                                                                       const EdgeInsets.all(8.0),
        //                                                                   child:
        //                                                                       TextButton(
        //                                                                     onPressed: () =>
        //                                                                         Navigator.pop(context, 'OK'),
        //                                                                     child:
        //                                                                         const Text(
        //                                                                       'ปิด',
        //                                                                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
        //                                                                     ),
        //                                                                   ),
        //                                                                 ),
        //                                                               ),
        //                                                             ],
        //                                                           ),
        //                                                         ],
        //                                                       ),
        //                                                     ]),
        //                                               );
        //                                             },
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     '',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'รวม(บาท)',
        //                                     textAlign: TextAlign.start,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     round_p == '1'
        //                                         ? '${nFormat.format(sum_pvat_up)}'
        //                                         : '${nFormat.format(sum_pvat)}',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Row(
        //                                     mainAxisAlignment:
        //                                         MainAxisAlignment.end,
        //                                     crossAxisAlignment:
        //                                         CrossAxisAlignment.center,
        //                                     children: [
        //                                       rental_ser != '106'
        //                                           ? SizedBox()
        //                                           : IconButton(
        //                                               onPressed: () async {
        //                                                 // //print(_TransReBillModels[
        //                                                 //         index]
        //                                                 //     .docno);
        //                                                 if (renTal_lavel > 3) {
        //                                                   if (rental_degree_up ==
        //                                                       '1') {
        //                                                     new_dereee
        //                                                         .text = round_p ==
        //                                                             '1'
        //                                                         ? sum_pvat_up
        //                                                             .toString()
        //                                                             .substring(sum_pvat_up
        //                                                                     .toString()
        //                                                                     .indexOf(
        //                                                                         '.') +
        //                                                                 1)
        //                                                         : sum_pvat
        //                                                             .toString()
        //                                                             .substring(sum_pvat
        //                                                                     .toString()
        //                                                                     .indexOf('.') +
        //                                                                 1);
        //                                                     showDialog(
        //                                                       context: context,
        //                                                       builder: (context) =>
        //                                                           AlertDialog(
        //                                                               title:
        //                                                                   Center(
        //                                                                 child:
        //                                                                     Text(
        //                                                                   'ปรับจุดทศนิยม',
        //                                                                   maxLines:
        //                                                                       1,
        //                                                                   textAlign:
        //                                                                       TextAlign.start,
        //                                                                   style: const TextStyle(
        //                                                                       color: Colors.black,
        //                                                                       fontWeight: FontWeight.bold,
        //                                                                       fontFamily: FontWeight_.Fonts_T,
        //                                                                       fontSize: 20),
        //                                                                 ),
        //                                                               ),
        //                                                               content:
        //                                                                   Stack(
        //                                                                 alignment:
        //                                                                     Alignment.center,
        //                                                                 children: <Widget>[
        //                                                                   Container(
        //                                                                       width: 250,
        //                                                                       decoration: const BoxDecoration(
        //                                                                         // color: Colors.black,
        //                                                                         borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        //                                                                       ),
        //                                                                       padding: const EdgeInsets.all(8.0),
        //                                                                       child: Row(
        //                                                                         children: [
        //                                                                           Expanded(
        //                                                                             flex: 3,
        //                                                                             child: Row(
        //                                                                               mainAxisAlignment: MainAxisAlignment.end,
        //                                                                               children: [
        //                                                                                 Padding(
        //                                                                                   padding: const EdgeInsets.all(8.0),
        //                                                                                   child: Text(
        //                                                                                     round_p == '1' ? '${sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1)}' : '${sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1)}',
        //                                                                                   ),
        //                                                                                 ),
        //                                                                               ],
        //                                                                             ),
        //                                                                           ),
        //                                                                           Expanded(
        //                                                                             flex: 2,
        //                                                                             child: TextFormField(
        //                                                                               //keyboardType: TextInputType.none,
        //                                                                               controller: new_dereee,
        //                                                                               // onChanged: (value) => value.trim(),
        //                                                                               onFieldSubmitted: (value) async {
        //                                                                                 var new_amt = round_p == '1' ? sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1) + value : sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1) + value;

        //                                                                                 //print(docnoin_up);
        //                                                                                 SharedPreferences preferences = await SharedPreferences.getInstance();
        //                                                                                 var ren = preferences.getString('renTalSer');
        //                                                                                 var docno = docnoin_up;
        //                                                                                 var sum_amt_up = double.parse(new_amt);
        //                                                                                 var sum_vat_up = double.parse(new_amt.toString()) * 7 / 100;

        //                                                                                 String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
        //                                                                                 try {
        //                                                                                   var response = await http.get(Uri.parse(url));

        //                                                                                   var result = json.decode(response.body);
        //                                                                                   if (result.toString() == 'true') {
        //                                                                                     setState(() {
        //                                                                                       red_Trans_select_up();
        //                                                                                       red_Invoice_up();

        //                                                                                       // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum).toStringAsFixed(2).toString();
        //                                                                                     });
        //                                                                                   }
        //                                                                                 } catch (e) {}

        //                                                                                 Navigator.pop(context, 'OK');
        //                                                                               },
        //                                                                               // maxLength: 13,
        //                                                                               cursorColor: Colors.green,
        //                                                                               decoration: InputDecoration(
        //                                                                                 fillColor: Colors.white.withOpacity(0.3),
        //                                                                                 filled: true,
        //                                                                                 // prefixIcon: const Icon(Icons.person, color: Colors.black),
        //                                                                                 // suffixIcon: Icon(Icons.clear, color: Colors.black),
        //                                                                                 focusedBorder: const OutlineInputBorder(
        //                                                                                   borderRadius: BorderRadius.only(
        //                                                                                     topRight: Radius.circular(15),
        //                                                                                     topLeft: Radius.circular(15),
        //                                                                                     bottomRight: Radius.circular(15),
        //                                                                                     bottomLeft: Radius.circular(15),
        //                                                                                   ),
        //                                                                                   borderSide: BorderSide(
        //                                                                                     width: 1,
        //                                                                                     color: Colors.black,
        //                                                                                   ),
        //                                                                                 ),
        //                                                                                 errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
        //                                                                                 enabledBorder: const OutlineInputBorder(
        //                                                                                   borderRadius: BorderRadius.only(
        //                                                                                     topRight: Radius.circular(15),
        //                                                                                     topLeft: Radius.circular(15),
        //                                                                                     bottomRight: Radius.circular(15),
        //                                                                                     bottomLeft: Radius.circular(15),
        //                                                                                   ),
        //                                                                                   borderSide: BorderSide(
        //                                                                                     width: 1,
        //                                                                                     color: Colors.black,
        //                                                                                   ),
        //                                                                                 ),
        //                                                                                 // labelText: 'USERNAME',
        //                                                                                 labelStyle: const TextStyle(
        //                                                                                   fontSize: 14,
        //                                                                                   color: Colors.black54,
        //                                                                                   fontFamily: Font_.Fonts_T,
        //                                                                                 ),
        //                                                                               ),
        //                                                                               inputFormatters: <TextInputFormatter>[
        //                                                                                 //   // for below version 2 use this
        //                                                                                 //   FilteringTextInputFormatter(RegExp("[a-zA-Z1-9@.]"),
        //                                                                                 //       allow: true),
        //                                                                                 FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        //                                                                                 //for version 2 and greater youcan also use this
        //                                                                                 FilteringTextInputFormatter.digitsOnly
        //                                                                               ],
        //                                                                             ),
        //                                                                           )
        //                                                                         ],
        //                                                                       ))
        //                                                                 ],
        //                                                               ),
        //                                                               actions: <Widget>[
        //                                                             Row(
        //                                                               mainAxisAlignment:
        //                                                                   MainAxisAlignment
        //                                                                       .center,
        //                                                               children: [
        //                                                                 Padding(
        //                                                                   padding:
        //                                                                       const EdgeInsets.all(8.0),
        //                                                                   child:
        //                                                                       Container(
        //                                                                     width:
        //                                                                         100,
        //                                                                     decoration:
        //                                                                         const BoxDecoration(
        //                                                                       color: Colors.black,
        //                                                                       borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        //                                                                     ),
        //                                                                     padding:
        //                                                                         const EdgeInsets.all(8.0),
        //                                                                     child:
        //                                                                         TextButton(
        //                                                                       onPressed: () => Navigator.pop(context, 'OK'),
        //                                                                       child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
        //                                                                     ),
        //                                                                   ),
        //                                                                 ),
        //                                                               ],
        //                                                             ),
        //                                                           ]),
        //                                                     );
        //                                                   } else if (rental_degree_up ==
        //                                                       '2') {
        //                                                     //print(docnoin_up);
        //                                                     SharedPreferences
        //                                                         preferences =
        //                                                         await SharedPreferences
        //                                                             .getInstance();
        //                                                     var ren = preferences
        //                                                         .getString(
        //                                                             'renTalSer');
        //                                                     var docno =
        //                                                         docnoin_up;
        //                                                     var sum_amt_up = round_p ==
        //                                                             '1'
        //                                                         ? sum_pvat_up
        //                                                             .toPrecision(
        //                                                                 1)
        //                                                         : sum_pvat
        //                                                             .toPrecision(
        //                                                                 1);
        //                                                     var sum_vat_up = round_p ==
        //                                                             '1'
        //                                                         ? sum_pvat_up
        //                                                                 .toPrecision(
        //                                                                     1) *
        //                                                             7 /
        //                                                             100
        //                                                         : sum_pvat
        //                                                                 .toPrecision(
        //                                                                     1) *
        //                                                             7 /
        //                                                             100;

        //                                                     String url =
        //                                                         '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
        //                                                     try {
        //                                                       var response =
        //                                                           await http.get(
        //                                                               Uri.parse(
        //                                                                   url));

        //                                                       var result =
        //                                                           json.decode(
        //                                                               response
        //                                                                   .body);
        //                                                       if (result
        //                                                               .toString() ==
        //                                                           'true') {
        //                                                         setState(() {
        //                                                           red_Trans_select_up();
        //                                                           red_Invoice_up();
        //                                                         });
        //                                                       }
        //                                                     } catch (e) {}
        //                                                   }
        //                                                 } else {
        //                                                   Dialog_updegree();
        //                                                 }
        //                                               },
        //                                               icon: Icon(
        //                                                 Icons.unfold_more,
        //                                               ),
        //                                             ),
        //                                       Text(
        //                                         'บาท',
        //                                         textAlign: TextAlign.end,
        //                                         style: TextStyle(
        //                                             color:
        //                                                 PeopleChaoScreen_Color
        //                                                     .Colors_Text1_,
        //                                             // fontWeight: FontWeight.bold,
        //                                             fontFamily: Font_.Fonts_T
        //                                             //fontSize: 10.0
        //                                             ),
        //                                       ),
        //                                     ],
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'ภาษีมูลค่าเพิ่ม(vat)',
        //                                     textAlign: TextAlign.start,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     round_p == '1'
        //                                         ? '${nFormat.format(sum_vat_up)}'
        //                                         : '${nFormat.format(sum_vat)}',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'บาท',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'หัก ณ ที่จ่าย',
        //                                     textAlign: TextAlign.start,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     '${nFormat.format(sum_wht)}',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'บาท',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'ยอดรวม',
        //                                     textAlign: TextAlign.start,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     '${nFormat.format(sum_amt)}',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'บาท',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Center(
        //                                     child: Row(
        //                                       children: [
        //                                         Text(
        //                                           'ส่วนลด',
        //                                           textAlign: TextAlign.start,
        //                                           style: TextStyle(
        //                                               color:
        //                                                   PeopleChaoScreen_Color
        //                                                       .Colors_Text1_,
        //                                               fontWeight:
        //                                                   FontWeight.bold,
        //                                               fontFamily:
        //                                                   FontWeight_.Fonts_T
        //                                               //fontSize: 10.0
        //                                               ),
        //                                         ),
        //                                         SizedBox(
        //                                           width: 10,
        //                                         ),
        //                                         Text(
        //                                           '$sum_disp  %',
        //                                           textAlign: TextAlign.start,
        //                                           style: TextStyle(
        //                                               color:
        //                                                   PeopleChaoScreen_Color
        //                                                       .Colors_Text1_,
        //                                               // fontWeight: FontWeight.bold,
        //                                               fontFamily:
        //                                                   FontWeight_.Fonts_T
        //                                               //fontSize: 10.0
        //                                               ),
        //                                         ),
        //                                       ],
        //                                     ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     '${nFormat.format(sum_disamt)}',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'บาท',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: Font_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           total_amt == 0.00
        //                               ? SizedBox()
        //                               : Row(
        //                                   children: [
        //                                     Expanded(
        //                                       flex: 2,
        //                                       child: Container(
        //                                         height: 40,
        //                                         color: AppbackgroundColor
        //                                             .Sub_Abg_Colors,
        //                                         padding:
        //                                             const EdgeInsets.all(8.0),
        //                                         child: Text(
        //                                           'หักชำระ',
        //                                           textAlign: TextAlign.start,
        //                                           style: TextStyle(
        //                                               color:
        //                                                   PeopleChaoScreen_Color
        //                                                       .Colors_Text1_,
        //                                               fontWeight:
        //                                                   FontWeight.bold,
        //                                               fontFamily:
        //                                                   FontWeight_.Fonts_T
        //                                               //fontSize: 10.0
        //                                               ),
        //                                         ),
        //                                       ),
        //                                     ),
        //                                     Expanded(
        //                                       flex: 4,
        //                                       child: Container(
        //                                         height: 40,
        //                                         color: AppbackgroundColor
        //                                             .Sub_Abg_Colors,
        //                                         padding:
        //                                             const EdgeInsets.all(8.0),
        //                                         child: Text(
        //                                           '${nFormat.format(total_amt)}',
        //                                           textAlign: TextAlign.end,
        //                                           style: TextStyle(
        //                                               color:
        //                                                   PeopleChaoScreen_Color
        //                                                       .Colors_Text1_,
        //                                               fontWeight:
        //                                                   FontWeight.bold,
        //                                               fontFamily:
        //                                                   FontWeight_.Fonts_T
        //                                               //fontSize: 10.0
        //                                               ),
        //                                         ),
        //                                       ),
        //                                     ),
        //                                     Expanded(
        //                                       flex: 1,
        //                                       child: Container(
        //                                         height: 40,
        //                                         color: AppbackgroundColor
        //                                             .Sub_Abg_Colors,
        //                                         padding:
        //                                             const EdgeInsets.all(8.0),
        //                                         child: Text(
        //                                           'บาท',
        //                                           textAlign: TextAlign.end,
        //                                           style: TextStyle(
        //                                               color:
        //                                                   PeopleChaoScreen_Color
        //                                                       .Colors_Text1_,
        //                                               // fontWeight: FontWeight.bold,
        //                                               fontFamily:
        //                                                   FontWeight_.Fonts_T
        //                                               //fontSize: 10.0
        //                                               ),
        //                                         ),
        //                                       ),
        //                                     ),
        //                                   ],
        //                                 ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'ยอดชำระรวม',
        //                                     textAlign: TextAlign.start,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     // '${nFormat.format(sum_amt - sum_disamt)}',
        //                                     '${nFormat.format(sum_amt - sum_disamt - total_amt)}',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'บาท',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         // fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                           if (room_number_BillHistory
        //                                       .toString()
        //                                       .trim() !=
        //                                   '' ||
        //                               room_number_BillHistory != null)
        //                             Row(children: [
        //                               Expanded(
        //                                 flex: 2,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     'ยอดชำระรวม',
        //                                     textAlign: TextAlign.start,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               Expanded(
        //                                 flex: 4,
        //                                 child: Container(
        //                                   height: 40,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Text(
        //                                     (room_number_BillHistory
        //                                                     .toString()
        //                                                     .trim() ==
        //                                                 '' ||
        //                                             room_number_BillHistory ==
        //                                                 null)
        //                                         ? ''
        //                                         : 'ประเภท ( ล็อคเสียบ )',
        //                                     textAlign: TextAlign.end,
        //                                     style: TextStyle(
        //                                         color: PeopleChaoScreen_Color
        //                                             .Colors_Text1_,
        //                                         fontWeight: FontWeight.bold,
        //                                         fontFamily: FontWeight_.Fonts_T
        //                                         //fontSize: 10.0
        //                                         ),
        //                                   ),
        //                                 ),
        //                               ),
        //                             ]),
        //                           Row(children: [
        //                             Expanded(
        //                               flex: 2,
        //                               child: Container(
        //                                 height: 40,
        //                                 color:
        //                                     AppbackgroundColor.Sub_Abg_Colors,
        //                                 padding: const EdgeInsets.all(8.0),
        //                                 child: Center(
        //                                   child: Row(
        //                                     children: [
        //                                       Text(
        //                                         'รูปแบบการชำระ',
        //                                         textAlign: TextAlign.end,
        //                                         style: TextStyle(
        //                                             color:
        //                                                 PeopleChaoScreen_Color
        //                                                     .Colors_Text1_,
        //                                             fontWeight: FontWeight.bold,
        //                                             fontFamily:
        //                                                 FontWeight_.Fonts_T
        //                                             //fontSize: 10.0
        //                                             ),
        //                                       ),
        //                                     ],
        //                                   ),
        //                                 ),
        //                               ),
        //                             ),
        //                           ]),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 50,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Center(
        //                                     child: Row(
        //                                       children: [],
        //                                     ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               for (var i = 0;
        //                                   i < finnancetransModels.length;
        //                                   i++)
        //                                 Expanded(
        //                                   flex: 4,
        //                                   child: Container(
        //                                     height: 50,
        //                                     child: Column(
        //                                       children: [
        //                                         Row(
        //                                           children: [
        //                                             Expanded(
        //                                               child: Container(
        //                                                 height: 50,

        //                                                 // width: MediaQuery.of(context).size.width,
        //                                                 decoration:
        //                                                     const BoxDecoration(
        //                                                   color:
        //                                                       AppbackgroundColor
        //                                                           .Sub_Abg_Colors,
        //                                                   borderRadius:
        //                                                       BorderRadius.only(
        //                                                     topLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     topRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                   ),
        //                                                   // border: Border.all(color: Colors.grey, width: 1),
        //                                                 ),
        //                                                 padding:
        //                                                     const EdgeInsets
        //                                                         .all(8.0),
        //                                                 child:
        //                                                     finnancetransModels[
        //                                                                     i]
        //                                                                 .dtype ==
        //                                                             'KP'
        //                                                         ? AutoSizeText(
        //                                                             minFontSize:
        //                                                                 10,
        //                                                             maxFontSize:
        //                                                                 15,
        //                                                             finnancetransModels[i].type ==
        //                                                                     'CASH'
        //                                                                 ? '${finnancetransModels[i].type} (เงินสด)'
        //                                                                 : '${finnancetransModels[i].type} (เงินโอน)',
        //                                                             style: TextStyle(
        //                                                                 color: PeopleChaoScreen_Color.Colors_Text2_,
        //                                                                 //fontWeight: FontWeight.bold,
        //                                                                 fontFamily: Font_.Fonts_T),
        //                                                           )
        //                                                         : AutoSizeText(
        //                                                             minFontSize:
        //                                                                 10,
        //                                                             maxFontSize:
        //                                                                 15,
        //                                                             '${finnancetransModels[i].remark}',
        //                                                             style: TextStyle(
        //                                                                 color: PeopleChaoScreen_Color.Colors_Text2_,
        //                                                                 //fontWeight: FontWeight.bold,
        //                                                                 fontFamily: Font_.Fonts_T),
        //                                                           ),
        //                                               ),
        //                                             ),
        //                                           ],
        //                                         ),
        //                                       ],
        //                                     ),
        //                                   ),
        //                                 ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                 flex: 1,
        //                                 child: Container(
        //                                   height: 50,
        //                                   color:
        //                                       AppbackgroundColor.Sub_Abg_Colors,
        //                                   padding: const EdgeInsets.all(8.0),
        //                                   child: Center(
        //                                     child: Row(
        //                                       children: [],
        //                                     ),
        //                                   ),
        //                                 ),
        //                               ),
        //                               for (var i = 0;
        //                                   i < finnancetransModels.length;
        //                                   i++)
        //                                 Expanded(
        //                                   flex: 4,
        //                                   child: Container(
        //                                     height: 50,
        //                                     child: Column(
        //                                       children: [
        //                                         Row(
        //                                           mainAxisAlignment:
        //                                               MainAxisAlignment.end,
        //                                           children: [
        //                                             Expanded(
        //                                               child: Container(
        //                                                 height: 50,
        //                                                 // width: MediaQuery.of(context).size.width,
        //                                                 decoration:
        //                                                     const BoxDecoration(
        //                                                   color:
        //                                                       AppbackgroundColor
        //                                                           .Sub_Abg_Colors,
        //                                                   borderRadius:
        //                                                       BorderRadius.only(
        //                                                     topLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     topRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                   ),
        //                                                   // border: Border.all(color: Colors.grey, width: 1),
        //                                                 ),
        //                                                 padding:
        //                                                     const EdgeInsets
        //                                                         .all(8.0),
        //                                                 child: AutoSizeText(
        //                                                   minFontSize: 10,
        //                                                   maxFontSize: 15,
        //                                                   'จำนวน',
        //                                                   style: TextStyle(
        //                                                       color: PeopleChaoScreen_Color
        //                                                           .Colors_Text2_,
        //                                                       //fontWeight: FontWeight.bold,
        //                                                       fontFamily: Font_
        //                                                           .Fonts_T),
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                             Expanded(
        //                                               child: Container(
        //                                                 height: 50,
        //                                                 // width: MediaQuery.of(context).size.width,
        //                                                 decoration:
        //                                                     const BoxDecoration(
        //                                                   color:
        //                                                       AppbackgroundColor
        //                                                           .Sub_Abg_Colors,
        //                                                   borderRadius:
        //                                                       BorderRadius.only(
        //                                                     topLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     topRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                   ),
        //                                                   // border: Border.all(color: Colors.grey, width: 1),
        //                                                 ),
        //                                                 padding:
        //                                                     const EdgeInsets
        //                                                         .all(8.0),
        //                                                 child: AutoSizeText(
        //                                                   minFontSize: 10,
        //                                                   maxFontSize: 15,
        //                                                   '${nFormat.format(double.parse(finnancetransModels[i].amt!))}',
        //                                                   style: TextStyle(
        //                                                       color: PeopleChaoScreen_Color
        //                                                           .Colors_Text2_,
        //                                                       //fontWeight: FontWeight.bold,
        //                                                       fontFamily: Font_
        //                                                           .Fonts_T),
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                             Expanded(
        //                                               child: Container(
        //                                                 height: 50,
        //                                                 // width: MediaQuery.of(context).size.width,
        //                                                 decoration:
        //                                                     const BoxDecoration(
        //                                                   color:
        //                                                       AppbackgroundColor
        //                                                           .Sub_Abg_Colors,
        //                                                   borderRadius:
        //                                                       BorderRadius.only(
        //                                                     topLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     topRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomLeft:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                     bottomRight:
        //                                                         Radius.circular(
        //                                                             6),
        //                                                   ),
        //                                                   // border: Border.all(color: Colors.grey, width: 1),
        //                                                 ),
        //                                                 padding:
        //                                                     const EdgeInsets
        //                                                         .all(8.0),
        //                                                 child: AutoSizeText(
        //                                                   minFontSize: 10,
        //                                                   maxFontSize: 15,
        //                                                   'บาท',
        //                                                   style: TextStyle(
        //                                                       color: PeopleChaoScreen_Color
        //                                                           .Colors_Text2_,
        //                                                       //fontWeight: FontWeight.bold,
        //                                                       fontFamily: Font_
        //                                                           .Fonts_T),
        //                                                 ),
        //                                               ),
        //                                             ),
        //                                           ],
        //                                         ),
        //                                       ],
        //                                     ),
        //                                   ),
        //                                 ),
        //                             ],
        //                           ),
        //                           Row(
        //                             children: [
        //                               Expanded(
        //                                   flex: 1,
        //                                   child: Container(
        //                                     height: 50,
        //                                     // width: MediaQuery.of(context).size.width,
        //                                     decoration: const BoxDecoration(
        //                                       color: AppbackgroundColor
        //                                           .Sub_Abg_Colors,
        //                                       borderRadius: BorderRadius.only(
        //                                         topLeft: Radius.circular(0),
        //                                         topRight: Radius.circular(0),
        //                                         bottomLeft: Radius.circular(10),
        //                                         bottomRight: Radius.circular(0),
        //                                       ),
        //                                       // border: Border.all(color: Colors.grey, width: 1),
        //                                     ),
        //                                   )),
        //                               Expanded(
        //                                   flex: 4,
        //                                   child: Container(
        //                                     height: 50,
        //                                     // width: MediaQuery.of(context).size.width,
        //                                     decoration: const BoxDecoration(
        //                                       color: AppbackgroundColor
        //                                           .Sub_Abg_Colors,
        //                                       borderRadius: BorderRadius.only(
        //                                         topLeft: Radius.circular(0),
        //                                         topRight: Radius.circular(0),
        //                                         bottomLeft: Radius.circular(0),
        //                                         bottomRight:
        //                                             Radius.circular(10),
        //                                       ),
        //                                       // border: Border.all(color: Colors.grey, width: 1),
        //                                     ),
        //                                   )),
        //                             ],
        //                           ),
        //                           const SizedBox(
        //                             height: 20,
        //                           ),
        //                           _TransReBillHistoryModels.length == 0
        //                               ? SizedBox()
        //                               : Row(
        //                                   children: [
        //                                     Expanded(
        //                                       flex: 4,
        //                                       child: Padding(
        //                                         padding:
        //                                             const EdgeInsets.all(8.0),
        //                                         child: InkWell(
        //                                           onTap:
        //                                               (_TransReBillHistoryModels
        //                                                           .length ==
        //                                                       0)
        //                                                   ? null
        //                                                   : () {
        //                                                       final tableData00 =
        //                                                           [
        //                                                         for (int index =
        //                                                                 0;
        //                                                             index <
        //                                                                 _TransReBillHistoryModels
        //                                                                     .length;
        //                                                             index++)
        //                                                           [
        //                                                             '${index + 1}',
        //                                                             '${_TransReBillHistoryModels[index].date}',
        //                                                             '${_TransReBillHistoryModels[index].expname}',
        //                                                             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
        //                                                             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
        //                                                             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
        //                                                             '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
        //                                                           ],
        //                                                       ];

        //                                                       List
        //                                                           newValuePDFimg =
        //                                                           [];
        //                                                       for (int index =
        //                                                               0;
        //                                                           index < 1;
        //                                                           index++) {
        //                                                         if (renTalModels[
        //                                                                     0]
        //                                                                 .imglogo!
        //                                                                 .trim() ==
        //                                                             '') {
        //                                                           // newValuePDFimg.add(
        //                                                           //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
        //                                                         } else {
        //                                                           newValuePDFimg
        //                                                               .add(
        //                                                                   '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
        //                                                         }
        //                                                       }

        //                                                       ////////////////////----------------->

        //                                                       showMyDialog_SAVE(
        //                                                           tableData00,
        //                                                           newValuePDFimg,
        //                                                           room_number_BillHistory);

        //                                                       ////////////////////----------------->

        //                                                       //   Pdfgen_his_statusbill
        //                                                       // .exportPDF_statusbill(
        //                                                       //     tableData00,
        //                                                       //     context,
        //                                                       //     _TransReBillHistoryModels,
        //                                                       //     'Num_cid',
        //                                                       //     'Namenew',
        //                                                       //     sum_pvat,
        //                                                       //     sum_vat,
        //                                                       //     sum_wht,
        //                                                       //     sum_amt,
        //                                                       //     sum_disp,
        //                                                       //     sum_disamt,
        //                                                       //     '${sum_amt - sum_disamt}',
        //                                                       //     renTal_name,
        //                                                       //     Form_bussscontact,
        //                                                       //     Form_bussscontact,
        //                                                       //     Form_address,
        //                                                       //     Form_tax,
        //                                                       //     bill_addr,
        //                                                       //     bill_email,
        //                                                       //     bill_tel,
        //                                                       //     bill_tax,
        //                                                       //     bill_name,
        //                                                       //     newValuePDFimg,
        //                                                       //     numdoctax == ''
        //                                                       //         ? '$numinvoice'
        //                                                       //         : '$numdoctax',
        //                                                       //     numinvoice,
        //                                                       //     finnancetransModels,
        //                                                       //     '${finnancetransModels[0].date}');
        //                                                     },
        //                                           child: Container(
        //                                               height: 50,
        //                                               decoration:
        //                                                   const BoxDecoration(
        //                                                 color: Colors.blue,
        //                                                 borderRadius:
        //                                                     BorderRadius.only(
        //                                                         topLeft: Radius
        //                                                             .circular(
        //                                                                 10),
        //                                                         topRight: Radius
        //                                                             .circular(
        //                                                                 10),
        //                                                         bottomLeft: Radius
        //                                                             .circular(
        //                                                                 10),
        //                                                         bottomRight: Radius
        //                                                             .circular(
        //                                                                 10)),
        //                                                 // border: Border.all(color: Colors.white, width: 1),
        //                                               ),
        //                                               padding:
        //                                                   EdgeInsets.all(8.0),
        //                                               child: Center(
        //                                                   child: Text(
        //                                                 'พิมพ์',
        //                                                 style: TextStyle(
        //                                                     color: PeopleChaoScreen_Color
        //                                                         .Colors_Text1_,
        //                                                     fontWeight:
        //                                                         FontWeight.bold,
        //                                                     fontFamily:
        //                                                         FontWeight_
        //                                                             .Fonts_T),
        //                                               ))),
        //                                         ),
        //                                       ),
        //                                     ),
        //                                     numdoctax != ''
        //                                         ? SizedBox()
        //                                         : Expanded(
        //                                             flex: 2,
        //                                             child: Padding(
        //                                               padding:
        //                                                   const EdgeInsets.all(
        //                                                       8.0),
        //                                               child: InkWell(
        //                                                 onTap: () {
        //                                                   pPC_finantIbillREbill();
        //                                                 },
        //                                                 child: Container(
        //                                                     height: 50,
        //                                                     decoration:
        //                                                         BoxDecoration(
        //                                                       color: Colors
        //                                                           .green[200],
        //                                                       borderRadius: BorderRadius.only(
        //                                                           topLeft: Radius
        //                                                               .circular(
        //                                                                   10),
        //                                                           topRight: Radius
        //                                                               .circular(
        //                                                                   10),
        //                                                           bottomLeft: Radius
        //                                                               .circular(
        //                                                                   10),
        //                                                           bottomRight: Radius
        //                                                               .circular(
        //                                                                   10)),
        //                                                       // border: Border.all(color: Colors.white, width: 1),
        //                                                     ),
        //                                                     padding:
        //                                                         const EdgeInsets
        //                                                             .all(8.0),
        //                                                     child: const Center(
        //                                                         child: Text(
        //                                                       'เปลี่ยนสถานะบิล',
        //                                                       style: TextStyle(
        //                                                           color: PeopleChaoScreen_Color
        //                                                               .Colors_Text1_,
        //                                                           fontWeight:
        //                                                               FontWeight
        //                                                                   .bold,
        //                                                           fontFamily:
        //                                                               FontWeight_
        //                                                                   .Fonts_T),
        //                                                     ))),
        //                                               ),
        //                                             ),
        //                                           ),
        //                                     DateTime.parse('$fin_datex 00:00:00')
        //                                                 .add(Duration(
        //                                                     days: int.parse(
        //                                                         '${Day_Cancell_bill}')))
        //                                                 .isBefore(
        //                                                     newDatetime) &&
        //                                             Day_Cancell_bill
        //                                                     .toString() !=
        //                                                 '0'
        //                                         ? SizedBox()
        //                                         : Expanded(
        //                                             flex: 4,
        //                                             child: Padding(
        //                                               padding:
        //                                                   const EdgeInsets.all(
        //                                                       8.0),
        //                                               child: InkWell(
        //                                                 onTap: () async {
        //                                                   final Formbecause_ =
        //                                                       TextEditingController();
        //                                                   // pPC_finantIbill();

        //                                                   showDialog<String>(
        //                                                     context: context,
        //                                                     builder: (BuildContext
        //                                                             context) =>
        //                                                         AlertDialog(
        //                                                       shape: const RoundedRectangleBorder(
        //                                                           borderRadius:
        //                                                               BorderRadius.all(
        //                                                                   Radius.circular(
        //                                                                       20.0))),
        //                                                       title:
        //                                                           const Center(
        //                                                               child:
        //                                                                   Text(
        //                                                         'ยกเลิกการรับชำระ',
        //                                                         style: TextStyle(
        //                                                             color: Colors
        //                                                                 .red,
        //                                                             fontWeight:
        //                                                                 FontWeight
        //                                                                     .bold,
        //                                                             fontFamily:
        //                                                                 FontWeight_
        //                                                                     .Fonts_T),
        //                                                       )),
        //                                                       content:
        //                                                           Container(
        //                                                         height: 120,
        //                                                         child: Column(
        //                                                           children: [
        //                                                             const SizedBox(
        //                                                               height:
        //                                                                   2.0,
        //                                                             ),
        //                                                             Text(
        //                                                               'บิลเลขที่ ${numinvoice}',
        //                                                               style: const TextStyle(
        //                                                                   color: AccountScreen_Color.Colors_Text2_,
        //                                                                   // fontWeight:
        //                                                                   //     FontWeight.bold,
        //                                                                   fontFamily: Font_.Fonts_T),
        //                                                             ),
        //                                                             Padding(
        //                                                               padding:
        //                                                                   const EdgeInsets.all(
        //                                                                       8.0),
        //                                                               child:
        //                                                                   TextFormField(
        //                                                                 keyboardType:
        //                                                                     TextInputType.number,
        //                                                                 controller:
        //                                                                     Formbecause_,
        //                                                                 validator:
        //                                                                     (value) {
        //                                                                   if (value == null ||
        //                                                                       value.isEmpty) {
        //                                                                     return 'ใส่ข้อมูลให้ครบถ้วน ';
        //                                                                   }
        //                                                                   // if (int.parse(value.toString()) < 13) {
        //                                                                   //   return '< 13';
        //                                                                   // }
        //                                                                   return null;
        //                                                                 },
        //                                                                 // maxLength: 13,
        //                                                                 cursorColor:
        //                                                                     Colors.green,
        //                                                                 decoration: InputDecoration(
        //                                                                     fillColor: Colors.white.withOpacity(0.3),
        //                                                                     filled: true,
        //                                                                     // prefixIcon: const Icon(Icons.water,
        //                                                                     //     color: Colors.blue),
        //                                                                     // suffixIcon: Icon(Icons.clear, color: Colors.black),
        //                                                                     focusedBorder: const OutlineInputBorder(
        //                                                                       borderRadius: BorderRadius.only(
        //                                                                         topRight: Radius.circular(15),
        //                                                                         topLeft: Radius.circular(15),
        //                                                                         bottomRight: Radius.circular(15),
        //                                                                         bottomLeft: Radius.circular(15),
        //                                                                       ),
        //                                                                       borderSide: BorderSide(
        //                                                                         width: 1,
        //                                                                         color: Colors.black,
        //                                                                       ),
        //                                                                     ),
        //                                                                     enabledBorder: const OutlineInputBorder(
        //                                                                       borderRadius: BorderRadius.only(
        //                                                                         topRight: Radius.circular(15),
        //                                                                         topLeft: Radius.circular(15),
        //                                                                         bottomRight: Radius.circular(15),
        //                                                                         bottomLeft: Radius.circular(15),
        //                                                                       ),
        //                                                                       borderSide: BorderSide(
        //                                                                         width: 1,
        //                                                                         color: Colors.grey,
        //                                                                       ),
        //                                                                     ),
        //                                                                     labelText: 'หมายเหตุ',
        //                                                                     labelStyle: const TextStyle(
        //                                                                       color: AccountScreen_Color.Colors_Text2_,
        //                                                                       // fontWeight:
        //                                                                       //     FontWeight.bold,
        //                                                                       fontFamily: Font_.Fonts_T,
        //                                                                     )),
        //                                                                 // inputFormatters: <TextInputFormatter>[
        //                                                                 //   // for below version 2 use this
        //                                                                 //   FilteringTextInputFormatter.allow(
        //                                                                 //       RegExp(r'[0-9]')),
        //                                                                 //   // for version 2 and greater youcan also use this
        //                                                                 //   FilteringTextInputFormatter.digitsOnly
        //                                                                 // ],
        //                                                               ),
        //                                                             ),
        //                                                             const SizedBox(
        //                                                               height:
        //                                                                   5.0,
        //                                                             ),
        //                                                           ],
        //                                                         ),
        //                                                       ),
        //                                                       actions: <Widget>[
        //                                                         Padding(
        //                                                           padding:
        //                                                               const EdgeInsets
        //                                                                       .all(
        //                                                                   8.0),
        //                                                           child:
        //                                                               Container(
        //                                                             width: 150,
        //                                                             height: 40,
        //                                                             // ignore: deprecated_member_use
        //                                                             child:
        //                                                                 ElevatedButton(
        //                                                               style: ElevatedButton
        //                                                                   .styleFrom(
        //                                                                 backgroundColor:
        //                                                                     Colors.green,
        //                                                               ),
        //                                                               onPressed:
        //                                                                   () {
        //                                                                 String
        //                                                                     Formbecause =
        //                                                                     Formbecause_.text.toString();
        //                                                                 if (Formbecause ==
        //                                                                     '') {
        //                                                                   showDialog<
        //                                                                       String>(
        //                                                                     context:
        //                                                                         context,
        //                                                                     builder: (BuildContext context) =>
        //                                                                         AlertDialog(
        //                                                                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        //                                                                       title: const Center(
        //                                                                           child: Text(
        //                                                                         'กรุณากรอกเหตุผล !!',
        //                                                                         style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
        //                                                                       )),
        //                                                                       actions: <Widget>[
        //                                                                         Padding(
        //                                                                           padding: const EdgeInsets.all(8.0),
        //                                                                           child: Row(
        //                                                                             mainAxisAlignment: MainAxisAlignment.center,
        //                                                                             children: [
        //                                                                               Container(
        //                                                                                 width: 100,
        //                                                                                 decoration: const BoxDecoration(
        //                                                                                   color: Colors.redAccent,
        //                                                                                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        //                                                                                 ),
        //                                                                                 padding: const EdgeInsets.all(8.0),
        //                                                                                 child: TextButton(
        //                                                                                   onPressed: () => Navigator.pop(context, 'OK'),
        //                                                                                   child: const Text(
        //                                                                                     'ปิด',
        //                                                                                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
        //                                                                                   ),
        //                                                                                 ),
        //                                                                               ),
        //                                                                             ],
        //                                                                           ),
        //                                                                         ),
        //                                                                       ],
        //                                                                     ),
        //                                                                   );
        //                                                                 } else {
        //                                                                   pPC_finantIbill(
        //                                                                       Formbecause);
        //                                                                   setState(
        //                                                                       () {
        //                                                                     Formbecause_.clear();
        //                                                                   });
        //                                                                   Navigator.pop(
        //                                                                       context,
        //                                                                       'OK');
        //                                                                 }
        //                                                               },
        //                                                               child:
        //                                                                   const Text(
        //                                                                 'ยืนยัน',
        //                                                                 style:
        //                                                                     TextStyle(
        //                                                                   // fontSize: 20.0,
        //                                                                   // fontWeight: FontWeight.bold,
        //                                                                   color:
        //                                                                       Colors.white,
        //                                                                 ),
        //                                                               ),
        //                                                               // color: Colors.black,
        //                                                             ),
        //                                                           ),
        //                                                         ),
        //                                                         Padding(
        //                                                           padding:
        //                                                               const EdgeInsets
        //                                                                       .all(
        //                                                                   8.0),
        //                                                           child:
        //                                                               Container(
        //                                                             width: 150,
        //                                                             height: 40,
        //                                                             // ignore: deprecated_member_use
        //                                                             child:
        //                                                                 ElevatedButton(
        //                                                               style: ElevatedButton
        //                                                                   .styleFrom(
        //                                                                 backgroundColor:
        //                                                                     Colors.black,
        //                                                               ),
        //                                                               onPressed:
        //                                                                   () {
        //                                                                 setState(
        //                                                                     () {
        //                                                                   Formbecause_
        //                                                                       .clear();
        //                                                                 });
        //                                                                 Navigator.pop(
        //                                                                     context,
        //                                                                     'OK');
        //                                                               },
        //                                                               child:
        //                                                                   const Text(
        //                                                                 'ปิด',
        //                                                                 style:
        //                                                                     TextStyle(
        //                                                                   // fontSize: 20.0,
        //                                                                   // fontWeight: FontWeight.bold,
        //                                                                   color:
        //                                                                       Colors.white,
        //                                                                 ),
        //                                                               ),
        //                                                               // color: Colors.black,
        //                                                             ),
        //                                                           ),
        //                                                         ),
        //                                                       ],
        //                                                     ),
        //                                                   );
        //                                                 },
        //                                                 child: Container(
        //                                                     height: 50,
        //                                                     decoration:
        //                                                         BoxDecoration(
        //                                                       color: Colors.red,
        //                                                       borderRadius: BorderRadius.only(
        //                                                           topLeft: Radius
        //                                                               .circular(
        //                                                                   10),
        //                                                           topRight: Radius
        //                                                               .circular(
        //                                                                   10),
        //                                                           bottomLeft: Radius
        //                                                               .circular(
        //                                                                   10),
        //                                                           bottomRight: Radius
        //                                                               .circular(
        //                                                                   10)),
        //                                                       // border: Border.all(color: Colors.white, width: 1),
        //                                                     ),
        //                                                     padding:
        //                                                         EdgeInsets.all(
        //                                                             8.0),
        //                                                     child: Center(
        //                                                         child: Text(
        //                                                       'ยกเลิกการรับชำระ',
        //                                                       style: TextStyle(
        //                                                           color: PeopleChaoScreen_Color
        //                                                               .Colors_Text1_,
        //                                                           fontWeight:
        //                                                               FontWeight
        //                                                                   .bold,
        //                                                           fontFamily:
        //                                                               FontWeight_
        //                                                                   .Fonts_T),
        //                                                     ))),
        //                                               ),
        //                                             ),
        //                                           ),
        //                                   ],
        //                                 ),
        //                         ],
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        SizedBox(
          height: 100,
        )
      ],
    );
  }

///////////////-------------------------------------------->
  final Formbecause_ = TextEditingController();
  Future<void> dialogOk(BuildContext context) {
    bool _openDeINV = false;
    // วางนอก onPressed (เช่นเป็นฟิลด์ของ State)
    bool _savingBill = false;
    // เก็บ key ของรายการที่เลือกให้ตรงกับ value ของ items
    String? selectedPaymentKey; // เช่น 'ser:ptname'

// helper แปลง ptser → label

    String _pt(String? s) =>
        ({
          '1': '( รับชำระแบบเงินสด )',
          '2': '( แบบแนบรูป QR เอง )',
          '5': '( ระบบ Gen PromptPay QR ให้ )',
          '6': '( ระบบ Gen Standard QR [ref.1 , ref.2] ให้ )',
          '7': '( ตัวกลางรับชำระ )',
          '8': '( AIP รับชำระ ชอยส์ )'
        })[s] ??
        '';
    String _fee(it) => it.fine == '1'
        ? (it.fine_c == '0.00'
            ? 'ค่าธรรมเนียม ${it.fine_a}'
            : 'ค่าธรรมเนียม ${it.fine_c} %')
        : '';
    ImageProvider _logo(it) =>
        AssetImage((it.ptname == 'เงินสด' || it.bser == null)
            ? 'images/LogoBank/CASH.png'
            : 'images/LogoBank/${it.bcode}.png');
    Widget _tile(it) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              CircleAvatar(
                  radius: 8,
                  backgroundImage: _logo(it),
                  backgroundColor: Colors.transparent),
              const SizedBox(width: 6),
              Expanded(
                  child: Text(it.ptname ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T))),
              const SizedBox(width: 6),
              Text(it.bno ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                      fontFamily: Font_.Fonts_T)),
            ]),
            const SizedBox(height: 2),
            Row(children: [
              Expanded(
                  flex: 2,
                  child: Text(_pt(it.ptser?.toString()),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          fontFamily: Font_.Fonts_T))),
              Expanded(
                  flex: 1,
                  child: Text(_fee(it),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.red,
                          fontFamily: Font_.Fonts_T))),
              Expanded(
                  flex: 2,
                  child: Text(it.bname ?? '',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                          fontFamily: Font_.Fonts_T))),
            ]),
          ],
        );
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

            // ---------- Title ----------
            title: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.receipt_sharp,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'รายละเอียดบิล',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                      Container(
                        width: 140,
                        padding: EdgeInsets.all(4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor:
                                PeopleChaoScreen_Color.Colors_Text3_,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          onPressed: (_savingBill ||
                                  Slip_history.toString() == null ||
                                  Slip_history == null ||
                                  Slip_history.toString() == 'null' ||
                                  Slip_history.toString() == '')
                              ? null
                              : () async {
                                  bool hasNonCashTransaction =
                                      finnancetransModels.any((transaction) {
                                    return transaction.ptser
                                            .toString()
                                            .trim() ==
                                        '7';
                                  });

                                  ///finnancetransModels
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
                                      actionsPadding: const EdgeInsets.all(6.0),
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
                                                        color: Colors.red[700]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '${numinvoice} ',
                                              maxLines: 1,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                  fontSize: 12.0),
                                            ),
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
                                                            textAlign: TextAlign
                                                                .center,
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
                                                        ),
                                                        InkWell(
                                                          onTap: () async {
                                                            final String url =
                                                                '${Slip_history}';
                                                            if (await canLaunch(
                                                                url)) {
                                                              await launch(url);
                                                            } else {
                                                              throw 'Could not launch $url';
                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .open_in_browser,
                                                            color: Colors.blue,
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
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                FontWeight_
                                                                    .Fonts_T,
                                                            fontSize: 12.0),
                                                      ),
                                                      InkWell(
                                                        onTap: () =>
                                                            downloadImage_slip(
                                                                '${MyConstant().domain}/files/$foder/slip/${Slip_history}',
                                                                '${numinvoice}'),
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
                                                        child:
                                                            WebViewX2Pagebeamcheck(
                                                                id_ser:
                                                                    Slip_history),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                          : Stack(
                                              alignment: Alignment.center,
                                              children: <Widget>[
                                                Image.network(
                                                    '${MyConstant().domain}/files/$foder/slip/${Slip_history}')
                                              ],
                                            ),
                                    ),
                                  );
                                },
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: Text(
                                (Slip_history.toString() == null ||
                                        Slip_history == null ||
                                        Slip_history.toString() == 'null' ||
                                        Slip_history.toString() == '')
                                    ? 'ไม่พบหลักฐาน'
                                    : 'หลักฐาน',
                                style: TextStyle(fontFamily: Font_.Fonts_T)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.close, size: 22, color: Colors.black54),
                  ),
                ),
              ],
            ),

            // ---------- Content ----------
            content: Container(
              width: double.infinity,
              // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              // decoration: BoxDecoration(
              //   // color: toneColor.withOpacity(0.06),
              //   borderRadius: BorderRadius.circular(10),
              //   // border: Border.all(color: Colors.grey.withOpacity(0.18)),
              // ),
              // child:
              //  ConstrainedBox(
              // constraints: const BoxConstraints(
              //   maxWidth: 200, // ⬅️ ความกว้างสูงสุด (สวยบนจอใหญ่/เล็ก)
              // ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==== Header card ====
                    // Container(
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         Colors.green.shade400,
                    //         Colors.green.shade300,
                    //       ],
                    //       begin: Alignment.topLeft,
                    //       end: Alignment.bottomRight,
                    //     ),
                    //     borderRadius:
                    //         const BorderRadius.vertical(top: Radius.circular(14)),
                    //     boxShadow: const [
                    //       BoxShadow(
                    //         blurRadius: 10,
                    //         offset: Offset(0, 4),
                    //         color: Color(0x1A000000),
                    //       ),
                    //     ],
                    //   ),
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 16, vertical: 12),
                    //   child: const Center(
                    //     child: Text(
                    //       'ยอดชำระทั้งหมด',
                    //       style: TextStyle(
                    //         color: PeopleChaoScreen_Color.Colors_Text3_,
                    //         fontWeight: FontWeight.bold,
                    //         fontFamily: FontWeight_.Fonts_T,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEAEAEA)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.25)),
                            ),
                            child: Text(
                              '${widget.Get_Value_NameShop_index}' == '1'
                                  ? 'เลขที่ใบสัญญา'
                                  : 'เลขที่ใบเสนอราคา',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              '${widget.Get_Value_cid}',
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: Colors.deepPurple.withOpacity(0.25)),
                            ),
                            child: Text(
                              'ใบเสร็จ',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              '${numinvoice}',
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Info text
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.18)),
                      ),
                      child: Text(
                        'ตรวจสอบข้อมูลให้ถูกต้องก่อนทำรายการ',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // ==== Body card ====
                    Container(
                      decoration: BoxDecoration(
                        color: AppbackgroundColor.Sub_Abg_Colors,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(14),
                            bottom: Radius.circular(14)),
                        border: Border.all(color: Colors.black12),
                      ),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                      child: Column(
                        children: [
                          // ยอดชำระรวม
                          Row(
                            children: [
                              const Text(
                                'ยอดชำระรวม : ',
                                style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 13,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[50]!.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Text(
                                    '${nFormat.format((getTotalByField(_TransReBillHistoryModels, (item) => item.total) + sum_duesbill) - sum_disamt)}',
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // หัวบิล
                          Row(
                            children: [
                              const Text(
                                'หัวบิล :',
                                style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DropdownButtonFormField2(
                                  alignment: Alignment.center,
                                  focusColor: Colors.white,
                                  autofocus: false,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFE7E3E3)),
                                    ),
                                  ),
                                  hint: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(Icons.arrow_drop_down,
                                      color: Colors.black54),
                                  iconSize: 22,
                                  buttonHeight: 44,
                                  buttonPadding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  items: TitleType_Default_Receipt_.map((item) {
                                    return DropdownMenuItem<String>(
                                      value: '$item',
                                      child: Text(
                                        '$item',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) async {
                                    final i =
                                        TitleType_Default_Receipt_.indexWhere(
                                            (e) => e == value);
                                    setState(
                                        () => TitleType_Default_Receipt = i);
                                  },
                                ),
                              ),
                            ],
                          ),

                          if (_openDeINV == true) const SizedBox(height: 10),
                          if (_openDeINV == true)
                            Row(
                              children: [
                                const Text(
                                  'หมายเหตุ :',
                                  style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SizedBox(
                                      height: 45,
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
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            // prefixIcon: const Icon(Icons.water,
                                            //     color: Colors.blue),
                                            // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                topLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                              ),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            // labelText: 'หมายเหตุ-Note',
                                            labelStyle: const TextStyle(
                                              color: AccountScreen_Color
                                                  .Colors_Text2_,
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
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // ),
            ),

            // ---------- Actions ----------
            actionsAlignment:
                MainAxisAlignment.center, // ⬅️ จัดกึ่งกลาง (เฉพาะ AlertDialog)

            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ========== พิมพ์/บันทึก ==========
                  SizedBox(
                    width: 170,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: PeopleChaoScreen_Color.Colors_Text3_,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _savingBill
                          ? null // กันกดซ้ำระหว่างกำลังบันทึก
                          : () async {
                              // กันกดซ้ำ
                              _savingBill = true;

                              // 1) เปิด Loader
                              ChaoAppLoader.show(
                                asset: 'images/LOGO.png', // หรือ .gif ก็ได้
                                assetFromPackage:
                                    false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                useCard: false,
                                dimBackground: true,
                                dismissible: true,
                                message: 'กำลังดำเนินการ...',
                                messageStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: FontWeight_.Fonts_T,
                                ),
                                slideAcross: false,
                                vSlideAcross: false,
                                motion: Motion.pingPong,
                                rangeMinAt: 0.48,
                                rangeMaxAt: 0.52,
                                slideMs: 1800,
                                verticalFactor: 0.5,
                                size: 150,
                              );

                              final navigator =
                                  Navigator.of(ctx); // ใช้ ctx ใน dialog

                              try {
                                // 2) เตรียมข้อมูล
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
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                var renTal_name =
                                    preferences.getString('renTalName');

                                final tableData00 = [];

                                await Receipt_his_statusbill(
                                    tableData00,
                                    newValuePDFimg,
                                    room_number_BillHistory,
                                    '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}');
                                // await showMyDialog_SAVE(tableData00,
                                //     newValuePDFimg, room_number_BillHistory);

                                // 4) ปิด dialog นี้ 1 ครั้งพอ (ถ้ายังเปิด)
                                if (navigator.canPop()) navigator.pop();

                                // 5) หน่วง 1 วิ แล้วแจ้งสำเร็จ (ถ้าหน้ายังอยู่)
                                await Future.delayed(
                                    const Duration(seconds: 1));
                                if (ctx.mounted) {
                                  Dialog_success(ctx, 'success');
                                }
                              } catch (e) {
                                // debug//print('in_Trans_His error: $e');
                                if (ctx.mounted) {
                                  Dialog_error(
                                      ctx, 'เกิดข้อผิดพลาด: ${e.toString()}');
                                }
                              } finally {
                                // 6) ปิด Loader เสมอ
                                ChaoAppLoader.hide();

                                // ปล่อยปุ่มให้กดใหม่ได้
                                _savingBill = false;
                                if (mounted)
                                  setState(
                                      () {}); // รีเฟรชปุ่ม disabled/enabled
                              }
                            },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text('พิมพ์',
                            style: TextStyle(fontFamily: Font_.Fonts_T)),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  // ========== บันทึก ==========
                  SizedBox(
                    width: 170,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_openDeINV == false)
                            ? Colors.orange.shade800
                            : Colors.red.shade800,
                        foregroundColor: PeopleChaoScreen_Color.Colors_Text3_,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _savingBill
                          ? null
                          : (numinvoice == null)
                              ? null
                              : (_openDeINV == false)
                                  ? () async {
                                      setState(() {
                                        _openDeINV = true;
                                        Formbecause_.text = 'ข้อมูลผิดพลาด';
                                      });
                                    }
                                  : () async {
                                      setState(() =>
                                          _savingBill = true); // กันกดซ้ำทันที

                                      // 1) เปิด Loader
                                      ChaoAppLoader.show(
                                        asset:
                                            'images/LOGO.png', // หรือ .gif ก็ได้
                                        assetFromPackage:
                                            false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                        useCard: false,
                                        dimBackground: true,
                                        dismissible: true,
                                        message: 'กำลังดำเนินการ...',
                                        messageStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                        slideAcross: false,
                                        vSlideAcross: false,
                                        motion: Motion.pingPong,
                                        rangeMinAt: 0.48,
                                        rangeMaxAt: 0.52,
                                        slideMs: 1800,
                                        verticalFactor: 0.5,
                                        size: 150,
                                      );

                                      final navigator = Navigator.of(
                                          ctx); // ใช้ ctx ของ dialog

                                      try {
                                        Insert_log.Insert_logs('ผู้เช่า',
                                            'ประวัติบิล>>ยกเลิกการชำระ(${numinvoice.toString()})');
                                        // 2) งานหลัก
                                        await pPC_finantIbill(
                                            Formbecause_.text);

                                        // 3) ปิด dialog นี้ 1 ครั้งพอ (ถ้ายังเปิดอยู่)
                                        if (navigator.canPop()) navigator.pop();

                                        // 4) รอ 1 วิ แล้วโชว์ success (ถ้าหน้ายังอยู่)
                                        await Future.delayed(
                                            const Duration(seconds: 1));
                                        if (ctx.mounted) {
                                          Dialog_success(ctx, 'success');
                                        }
                                      } catch (e) {
                                        //debug//print('in_Trans_His error: $e');
                                        if (ctx.mounted) {
                                          Dialog_error(ctx,
                                              'เกิดข้อผิดพลาด: ${e.toString()}');
                                        }
                                      } finally {
                                        // 5) ปิด Loader เสมอ
                                        ChaoAppLoader.hide();

                                        // 6) ปลดล็อกปุ่ม
                                        if (mounted)
                                          setState(() => _savingBill = false);
                                      }

                                      // if (numinvoice != null) {
                                      //   Insert_log.Insert_logs('ผู้เช่า',
                                      //       'วางบิล>>ประวัติวางบิล>>ยกเลิกการวางบิล(${numinvoice.toString()})');
                                      //   //print(numinvoice);
                                      //   de_invoice();
                                      //   Navigator.pop(context);
                                      // }
                                    },
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                            (_openDeINV == false)
                                ? 'ยกเลิกการชำระ'
                                : 'ยืนยันการยกเลิก',
                            style: TextStyle(fontFamily: Font_.Fonts_T)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
      },
    );
  }

  ///============================>
  // Dialog_updegree() async {
  //   PanaraInfoDialog.showAnimatedGrow(
  //     context,
  //     title: "Oops",
  //     message: "User ของท่านไม่สามารถทำการปรับจุดทศนิยมได้ !!",
  //     buttonText: "รับทราบ",
  //     onTapDismiss: () async {
  //       Navigator.pop(context);
  //     },
  //     panaraDialogType: PanaraDialogType.error,
  //     barrierDismissible: false,
  //   );
  // }

  // Future<Null> pPC_finantIbillREbill() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   // var ciddoc = widget.Get_Value_cid;
  //   // var qutser = widget.Get_Value_NameShop_index;

  //   var numin = numinvoice;
  //   //print('>>>zzzz>>>>>> $numin');

  //   String url =
  //       '${MyConstant().domain}/UPC_finant_billREbill.php?isAdd=true&ren=$ren&user=$user&numin=$numin';
  //   //print(url);
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     //print(result);
  //     if (result.toString() != 'No') {
  //       setState(() {
  //         _InvoiceModels.clear();
  //         _InvoiceHistoryModels.clear();
  //         _TransReBillHistoryModels.clear();
  //         numinvoice = null;
  //         numdoctax = null;
  //         // sum_disamtx.text = '0.00';
  //         // sum_dispx.text = '0.00';
  //         sum_pvat = 0.00;
  //         sum_vat = 0.00;
  //         sum_wht = 0.00;
  //         sum_amt = 0.00;
  //         sum_dis = 0.00;
  //         sum_disamt = 0.00;
  //         sum_disp = 0;
  //         select_page = 0;
  //         red_Trans_bill();
  //         finnancetransModels.clear();
  //       });
  //       //print('rrrrrrrrrrrrrr');
  //     }
  //   } catch (e) {}
  // }

  Future<Null> pPC_finantIbill(Formbecause) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;

    String url =
        '${MyConstant().domain}/UPC_finant_bill.php?isAdd=true&ren=$ren&user=$user&numin=$numin&because=$Formbecause';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // //print(result);
      if (result.toString() == 'true') {
        Insert_log.Insert_logs('บัญชี',
            'ประวัติบิล>>ยกเลิกการรับชำระ($numin,เหตุผล:${Formbecause})');
        setState(() {
          _InvoiceModels.clear();
          _InvoiceHistoryModels.clear();
          _TransReBillHistoryModels.clear();
          numinvoice = null;
          numdoctax = null;
          // sum_disamtx.text = '0.00';
          // sum_dispx.text = '0.00';
          sum_pvat = 0.00;
          sum_vat = 0.00;
          sum_wht = 0.00;
          sum_amt = 0.00;
          sum_dis = 0.00;
          sum_disamt = 0.00;
          total_amt = 0.00;
          sum_disp = 0;
          select_page = 0;
          red_Trans_bill();
          finnancetransModels.clear();
        });
        // //print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  // ////////////------------------------------------------------------>(Export file)
  // Future<void> showMyDialog_SAVE(
  //     tableData00, newValuePDFimg, room_number_BillHistory) async {
  //   String _ReportValue_type = "ไม่ระบุ";
  //   String _verticalGroupValue_NameFile = "จากระบบ";
  //   String Value_Report = ' ';
  //   String NameFile_ = '';
  //   String Pre_and_Dow = '';
  //   String? TitleType_Default_Receipt_Name;
  //   final _formKey = GlobalKey<FormState>();
  //   final FormNameFile_text = TextEditingController();
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return StreamBuilder(
  //         stream: Stream.periodic(const Duration(seconds: 0)),
  //         builder: (context, snapshot) {
  //           return Form(
  //             key: _formKey,
  //             child: AlertDialog(
  //               shape: const RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.all(Radius.circular(15.0))),
  //               content: SingleChildScrollView(
  //                 child: ListBody(
  //                   children: <Widget>[
  //                     const Text(
  //                       'หัวบิล :',
  //                       style: TextStyle(
  //                         color: ReportScreen_Color.Colors_Text2_,
  //                         // fontWeight: FontWeight.bold,
  //                         fontFamily: Font_.Fonts_T,
  //                       ),
  //                     ),
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white.withOpacity(0.3),
  //                         borderRadius: const BorderRadius.only(
  //                           topLeft: Radius.circular(15),
  //                           topRight: Radius.circular(15),
  //                           bottomLeft: Radius.circular(15),
  //                           bottomRight: Radius.circular(15),
  //                         ),
  //                         border: Border.all(color: Colors.grey, width: 1),
  //                       ),
  //                       padding: const EdgeInsets.all(8.0),
  //                       child: RadioGroup<String>.builder(
  //                         direction: Axis.vertical,
  //                         groupValue: _ReportValue_type,
  //                         horizontalAlignment: MainAxisAlignment.center,
  //                         onChanged: (value) {
  //                           // setState(() {
  //                           //   FormNameFile_text.clear();
  //                           // });
  //                           setState(() {
  //                             _ReportValue_type = value ?? '';
  //                           });

  //                           if (value == 'ไม่ระบุ') {
  //                             setState(() {
  //                               TitleType_Default_Receipt_Name = null;
  //                             });
  //                           } else {
  //                             setState(() {
  //                               TitleType_Default_Receipt_Name = value;
  //                             });
  //                           }
  //                         },
  //                         items: const <String>[
  //                           'ไม่ระบุ',
  //                           'ต้นฉบับ',
  //                           'คู่ฉบับ',
  //                           'สำเนา',
  //                           'สำเนาคู่ฉบับ',
  //                         ],
  //                         textStyle: const TextStyle(
  //                           fontSize: 15,
  //                           color: ReportScreen_Color.Colors_Text2_,
  //                           // fontWeight: FontWeight.bold,
  //                           fontFamily: Font_.Fonts_T,
  //                         ),
  //                         itemBuilder: (item) => RadioButtonBuilder(
  //                           item,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               actions: <Widget>[
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.all(4.0),
  //                       child: InkWell(
  //                         onTap: () {
  //                           Receipt_his_statusbill(
  //                               tableData00,
  //                               newValuePDFimg,
  //                               room_number_BillHistory,
  //                               TitleType_Default_Receipt_Name);
  //                         },
  //                         child: Container(
  //                           width: 100,
  //                           decoration: const BoxDecoration(
  //                             color: Colors.green,
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 topRight: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10),
  //                                 bottomRight: Radius.circular(10)),
  //                           ),
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Center(
  //                             child: Text(
  //                               'พิมพ์',
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 //fontWeight: FontWeight.bold, color:

  //                                 // fontWeight: FontWeight.bold,
  //                                 fontFamily: Font_.Fonts_T,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.all(4.0),
  //                       child: InkWell(
  //                         onTap: () => Navigator.pop(context, 'OK'),
  //                         child: Container(
  //                           width: 100,
  //                           decoration: const BoxDecoration(
  //                             color: Colors.black,
  //                             borderRadius: BorderRadius.only(
  //                                 topLeft: Radius.circular(10),
  //                                 topRight: Radius.circular(10),
  //                                 bottomLeft: Radius.circular(10),
  //                                 bottomRight: Radius.circular(10)),
  //                           ),
  //                           padding: const EdgeInsets.all(8.0),
  //                           child: Center(
  //                             child: Text(
  //                               'ปิด',
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 //fontWeight: FontWeight.bold, color:

  //                                 // fontWeight: FontWeight.bold,
  //                                 fontFamily: Font_.Fonts_T,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 )
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

//////////////-------------------------------------------------------------> ( รายการชำระ ประวัติบิล )
  Future<Null> Receipt_his_statusbill(tableData00, newValuePDFimg,
      room_number_BillHistory, TitleType_Default_Receipt_Name) async {
    var date_Transaction = (finnancetransModels.length == 0)
        ? ''
        : '${finnancetransModels[0].daterec}';
    var date_pay = (finnancetransModels.length == 0)
        ? ''
        : '${finnancetransModels[0].dateacc}';
    var cFinn_S = (numinvoice != '') ? numinvoice : numdoctax;
    Navigator.pop(context, 'OK');
    Future.delayed(Duration(milliseconds: 200), () async {
      ManPay_Receipt_PDF.ManPayReceipt_PDF(
          '${cFinn_S}',
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
    });
  }

  // Dia_log1() {
  //   return showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (_) {
  //         Timer(Duration(milliseconds: 400), () {
  //           Navigator.of(context).pop();
  //         });
  //         return Dialog(
  //           child: SizedBox(
  //             height: 20,
  //             width: 80,
  //             child: FittedBox(
  //               fit: BoxFit.cover,
  //               child: Image.asset(
  //                 "images/gif-LOGOchao.gif",
  //                 fit: BoxFit.cover,
  //                 height: 20,
  //                 width: 80,
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }

  // Dia_log2() {
  //   return showDialog(
  //       barrierDismissible: true,
  //       context: context,
  //       builder: (BuildContext builderContext) {
  //         Timer(Duration(milliseconds: 230), () {
  //           Navigator.of(context).pop();
  //         });

  //         return AlertDialog(
  //           backgroundColor: Colors.transparent,
  //           elevation: 0,
  //           content: Container(
  //             child: Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           ),
  //         );
  //       });
  // }
}
