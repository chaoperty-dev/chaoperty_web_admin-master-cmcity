import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/PeopleChao/Pays_.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constant/Myconstant.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_Credit_Note_PDF.dart';
import '../Man_PDF/Man_Pay_Receipt_PDF.dart';
import '../Man_PDF/Man_Reduce_debt.dart';
import '../Model/GetFinnancetrans_Model.dart';
import '../Model/GetInvoice_Model.dart';
import '../Model/GetInvoice_dis_Model.dart';
import '../Model/GetInvoice_history_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/GetTrans_hisdisinv_Model.dart';
import '../Model/invoice_cn_model.dart';
import '../Model/trans_re_bill_history_model.dart';
import '../Model/trans_re_bill_model.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';

class DiscountBill extends StatefulWidget {
  final Get_Value_cid;
  const DiscountBill({
    super.key,
    this.Get_Value_cid,
  });

  @override
  State<DiscountBill> createState() => _DiscountBillState();
}

class _DiscountBillState extends State<DiscountBill> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  List<TransBillModel> _TransBillModels = [];
  List<TransModel> _TransModels = [];
  List<TransReBillModel> _TransReBillModels = [];
  List<InvoiceCNModel> _invoiceCNModels = [];
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
  final Formposlokdispri_ = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
      sum_pvat_up = 0.00;

  int select_page = 0,
      pamentpage = 0,
      renTal_lavel = 0,
      selece_bill = 0,
      discount_page = 0,
      dis_bill = 0,
      mrp_cn = 0; // = 0 _TransModels : = 1 _InvoiceHistoryModels
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
  double sum_pvat_cn = 0.00,
      sum_vat_cn = 0.00,
      sum_wht_cn = 0.00,
      sum_amt_cn = 0.00,
      sum_Total_cn = 0.00,
      sum_disamt_cn = 0.00,
      sum_disp_cn = 0,
      pri_cn = 0,
      pvat_cn = 0,
      vat_cn = 0,
      wht_cn = 0,
      amt_cn = 0;
  int view_bill = 0;
  String? reduce_bill, reduce_bill_status, reduce_bill_doc;
  String? Receipt_type;
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
    print('name>>>>>  $renname');
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
    var qutser = '1';

    String url =
        '${MyConstant().domain}/GC_tenantlookAS.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
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

  Future<Null> red_Trans_bill() async {
    if (_TransReBillModels.length != 0) {
      setState(() {
        _TransReBillModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = '1';

    String url =
        '${MyConstant().domain}/GC_bill_pay.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          TransReBillModel transReBillModel = TransReBillModel.fromJson(map);
          setState(() {
            if (transReBillModel.dtype != '!Z') {
              _TransReBillModels.add(transReBillModel);
            }
            // _TransBillModels.add(_TransBillModel);
          });
        }

        print('result ${_TransReBillModels.length}');
      }
    } catch (e) {}
  }

  String Remark_ = '', date_check = '';

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
    print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
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
          print(
              '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Invoice_CN() async {
    if (_invoiceCNModels.length != 0) {
      setState(() {
        _invoiceCNModels.clear();
        pvat_cn = 0;
        vat_cn = 0;
        wht_cn = 0;
        amt_cn = 0;
        mrp_cn = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var docnotran = numdoctax == '' || numdoctax == null || numdoctax == 'null'
        ? numinvoice == '' || numinvoice == null || numinvoice == 'null'
            ? ''
            : '$numinvoice'
        : '$numdoctax';
    var docnoin = reduce_bill_doc; //.toString().trim()
    print('>>>>>>>>>>>reduce_bill_doc>>>$docnotran in cn  $docnoin');

    String url =
        '${MyConstant().domain}/GC_CN_invoice.php?isAdd=true&ren=$ren&docnotran=$docnotran&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceCNModel _invoiceCNModel = InvoiceCNModel.fromJson(map);
          var pvat_cnx = double.parse(_invoiceCNModel.pvatCn!);
          var amt_cnx = double.parse(_invoiceCNModel.amtCn!);
          var vat_cnx = double.parse(_invoiceCNModel.vatCn!);
          var wht_cnx = double.parse(_invoiceCNModel.whtCn!);

          var mrp_cnx = int.parse(_invoiceCNModel.mrp!);
          if (mrp_cnx == '2') {
            setState(() {
              pvat_cn = pvat_cnx;
              vat_cn = vat_cnx;
              wht_cn = wht_cnx;
              amt_cn = amt_cnx;
              mrp_cn = mrp_cnx;
              _invoiceCNModels.add(_invoiceCNModel);
            });
          } else {
            setState(() {
              pvat_cn = pvat_cn + pvat_cnx;
              vat_cn = vat_cn + vat_cnx;
              wht_cn = wht_cn + wht_cnx;
              amt_cn = amt_cn + amt_cnx;
              mrp_cn = mrp_cnx;
              _invoiceCNModels.add(_invoiceCNModel);
            });
          }
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Invoice_up() async {
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
    var ciddoc = ciddoc_up;
    var qutser = qutser_up;
    var docnoin = docnoin_up; //.toString().trim()
    print('>>>>>>>>>>>dd>>> in d  $docnoin');

    String url =
        '${MyConstant().domain}/GC_bill_pay_amt.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await http.get(Uri.parse(url));
      var result = json.decode(response.body);
      print('BBBBBBBBBBBBBBBB>>>> $result');
      if (result.toString() != 'null') {
        for (var map in result) {
          FinnancetransModel finnancetransModel =
              FinnancetransModel.fromJson(map);

          var sidamt = double.parse(finnancetransModel.amt!);
          var siddisper = double.parse(finnancetransModel.disper!);
          var pdatex = finnancetransModel.pdate;

          setState(() {
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
          print(
              '>>>>> ${finnancetransModel.slip}>>>>>>dd>>> in $sidamt $siddisper  ');
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_select(index) async {
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
    var qutser = '1';
    var docnoin = _TransReBillModels[index].docno;

    String url =
        '${MyConstant().domain}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print('GC_bill_pay_history>>>> $result');
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
          var sum_amtx = dtypeinvoiceent == 'KP' || dtypeinvoiceent == '!Z'
              ? double.parse(_TransReBillHistoryModel.dis!) != 0
                  ? double.parse(_TransReBillHistoryModel.total!) -
                      double.parse(_TransReBillHistoryModel.vat!)
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
      // print('fin_datex>>>>  $fin_datex $round_p $sum_vat_up $sum_pvat_up');
      // setState(() {
      //   red_Invoice();
      // });
    } catch (e) {}
    print(
        '_TransReBillHistoryModels.length >>>> ${_TransReBillHistoryModels.length}');
  }

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
    var qutser = '1';
    var docnoin = docnoin_up;

    String url =
        '${MyConstant().domain}/GC_bill_pay_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
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
            }
            //  else if (dtypeinvoiceent == '!Z') {
            //   sum_pvat = sum_pvat + sum_pvatx;
            //   sum_vat = sum_vat + sum_vatx;
            //   sum_wht = sum_wht + sum_whtx;
            //   sum_amt = sum_amt + sum_amtx;
            //   // sum_disamt = sum_disamtx;
            //   // sum_disp = sum_dispx;
            //   numinvoice = _TransReBillHistoryModel.docno;
            //   numdoctax = _TransReBillHistoryModel.doctax;

            //   _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            // }
            else {
              total_amt = total_amt + total_amtx;

              _TransReBillHistoryModels.add(_TransReBillHistoryModel);
            }
          });
        }
      }
      // print('fin_datex>>>>  $fin_datex $round_p $sum_vat_up $sum_pvat_up');
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

  //   print('object11');

  //   String url =
  //       '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
  //   try {
  //     var response = await http.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     print(result);
  //     print('object22');
  //     if (result.toString() != 'null') {
  //       print('object33');
  //       for (var map in result) {
  //         print('object44');
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          }),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.86,
                  // discount_page == 0
                  //     ? MediaQuery.of(context).size.width * 0.86
                  //     : MediaQuery.of(context).size.width * 1.36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            width: (Responsive.isDesktop(context))
                                ? MediaQuery.of(context).size.width / 3.5
                                : 400,
                            child: Column(children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _InvoiceModels.clear();
                                          _InvoiceHistoryModels.clear();
                                          _TransReBillHistoryModels.clear();
                                          numinvoice = null;
                                          numdoctax = null;
                                          selece_bill = 0;
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
                                          red_Trans_bill();
                                        });
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: selece_bill != 0
                                              ? Colors.yellow[200]
                                              : Color.fromARGB(255, 250, 58, 0),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(0),
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(0),
                                          ),
                                          // border: Border.all(
                                          //     color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            'ใบเสร็จรับเงิน',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: selece_bill == 0
                                                    ? Colors.white
                                                    : PeopleChaoScreen_Color
                                                        .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T
                                                //fontSize: 10.0
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Expanded(
                                  //   flex: 4,
                                  //   child: GestureDetector(
                                  //     onTap: () {
                                  //       setState(() {
                                  //         _InvoiceModels.clear();
                                  //         _InvoiceHistoryModels.clear();
                                  //         _TransReBillHistoryModels.clear();
                                  //         numinvoice = null;
                                  //         numdoctax = null;
                                  //         selece_bill = 1;
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
                                  //       });
                                  //     },
                                  //     child: Container(
                                  //       height: 50,
                                  //       decoration: BoxDecoration(
                                  //         color: selece_bill != 1
                                  //             ? Colors.yellow[200]
                                  //             : Color.fromARGB(255, 250, 58, 0),
                                  //         borderRadius: const BorderRadius.only(
                                  //           topLeft: Radius.circular(10),
                                  //           topRight: Radius.circular(0),
                                  //           bottomLeft: Radius.circular(0),
                                  //           bottomRight: Radius.circular(0),
                                  //         ),
                                  //         // border: Border.all(
                                  //         //     color: Colors.grey, width: 1),
                                  //       ),
                                  //       padding: const EdgeInsets.all(8.0),
                                  //       child: Center(
                                  //         child: Text(
                                  //           'ใบลดหนี้',
                                  //           textAlign: TextAlign.center,
                                  //           style: TextStyle(
                                  //               color: selece_bill == 1
                                  //                   ? Colors.white
                                  //                   : PeopleChaoScreen_Color
                                  //                       .Colors_Text1_,
                                  //               fontWeight: FontWeight.bold,
                                  //               fontFamily: FontWeight_.Fonts_T
                                  //               //fontSize: 10.0
                                  //               ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 50,
                                      color: Colors.brown[200],
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Center(
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          'ประเภท',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 50,
                                      color: Colors.brown[200],
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          'วันที่ชำระ',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      height: 50,
                                      color: Colors.brown[200],
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Center(
                                        child: AutoSizeText(
                                          minFontSize: 10,
                                          maxFontSize: 25,
                                          maxLines: 1,
                                          'เลขที่ใบเสร็จ',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                              color: PeopleChaoScreen_Color
                                                  .Colors_Text2_,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                  height: _TransReBillHistoryModels.length == 0
                                      ? 400
                                      : dtypeselect == '!Z'
                                          ? 400
                                          : 720,
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
                                      return Material(
                                        color: (_TransReBillModels[index]
                                                        .docno
                                                        .toString() ==
                                                    numinvoice.toString() ||
                                                _TransReBillModels[index]
                                                        .doctax
                                                        .toString() ==
                                                    numinvoice.toString())
                                            ? tappedIndex_Color
                                                .tappedIndex_Colors
                                            : _TransReBillModels[index].dtype ==
                                                    '!Z'
                                                ? Colors.red.shade100
                                                : AppbackgroundColor
                                                    .Sub_Abg_Colors,
                                        child: ListTile(
                                          onTap: () async {
                                            print(
                                                '${_TransReBillModels[index].ser} ${_TransReBillModels[index].docno}');
                                            red_Trans_select(index);
                                            setState(() {
                                              Remark_ =
                                                  _TransReBillModels[index]
                                                      .descr!;
                                              room_number_BillHistory =
                                                  '${_TransReBillModels[index].room_number}';
                                              ciddoc_up =
                                                  _TransReBillModels[index].ser;
                                              qutser_up =
                                                  _TransReBillModels[index]
                                                      .ser_in;
                                              docnoin_up =
                                                  _TransReBillModels[index]
                                                      .docno;
                                              date_check =
                                                  _TransReBillModels[index]
                                                      .daterec!;
                                              discount_page = 0;
                                              dis_bill = 0;
                                              view_bill = 0;
                                              reduce_bill =
                                                  _TransReBillModels[index]
                                                      .reduce_debt;
                                              reduce_bill_status =
                                                  _TransReBillModels[index]
                                                      .reduce_status;
                                              reduce_bill_doc =
                                                  _TransReBillModels[index]
                                                      .reduce_bill;
                                            });
                                            red_Invoice(index);

                                            setState(() {
                                              dtypeselect =
                                                  _TransReBillModels[index]
                                                      .dtype;
                                            });
                                            // in_Trans_select(index);
                                          },
                                          title: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Tooltip(
                                                      richMessage: TextSpan(
                                                        text: _TransReBillModels[
                                                                        index]
                                                                    .dtype ==
                                                                '!Z'
                                                            ? '${_TransReBillModels[index].expname} (ยกเลิก)'
                                                            : '${_TransReBillModels[index].expname}',
                                                        style: const TextStyle(
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
                                                        _TransReBillModels[
                                                                        index]
                                                                    .dtype ==
                                                                '!Z'
                                                            ? '${_TransReBillModels[index].expname} (ยกเลิก)'
                                                            : '${_TransReBillModels[index].expname}',
                                                        textAlign:
                                                            TextAlign.start,
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
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 25,
                                                      maxLines: 1,
                                                      '${_TransReBillModels[index].daterec}',
                                                      textAlign:
                                                          TextAlign.center,
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
                                                        _TransReBillModels[
                                                                        index]
                                                                    .doctax ==
                                                                ''
                                                            ? '${_TransReBillModels[index].docno}'
                                                            : '${_TransReBillModels[index].doctax}',
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
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: _TransReBillModels[
                                                                    index]
                                                                .reduce_debt ==
                                                            '0'
                                                        ? SizedBox()
                                                        : Text(
                                                            _TransReBillModels[
                                                                            index]
                                                                        .reduce_status ==
                                                                    '0'
                                                                ? 'ใบลดหนี้ ( รอนุมัติ )'
                                                                : 'ใบลดหนี้ ( อนุมัติ )',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: _TransReBillModels[index]
                                                                            .reduce_status ==
                                                                        '0'
                                                                    ? Colors.red
                                                                        .shade800
                                                                    : Colors
                                                                        .green
                                                                        .shade800),
                                                          ),
                                                  ),
                                                  Expanded(
                                                      child: _TransReBillModels[
                                                                      index]
                                                                  .pos ==
                                                              '0'
                                                          ? Text(
                                                              'รับชำระแล้ว',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .green
                                                                      .shade800),
                                                            )
                                                          : Text(
                                                              'รอตรวจสอบ',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .orange
                                                                      .shade800),
                                                            )),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                              Container(
                                  width: (Responsive.isDesktop(context))
                                      ? MediaQuery.of(context).size.width / 3.5
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                      // page_detel(),
                      discount_page == 1 ? page_detel_Dicount() : page_detel()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 100,
        )
      ],
    );
  }

  Padding page_detel() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: (Responsive.isDesktop(context))
              ? MediaQuery.of(context).size.width * 0.52
              : 900,
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
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
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          view_bill = 0;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: reduce_bill == '0'
                              ? Colors.orange[100]
                              : numdoctax == '' ||
                                      numdoctax == null ||
                                      numdoctax == 'null'
                                  ? numinvoice == '' ||
                                          numinvoice == null ||
                                          numinvoice == 'null'
                                      ? Colors.orange[100]
                                      : view_bill == 0
                                          ? Colors.blue
                                          : Colors.white
                                  : view_bill == 0
                                      ? Colors.blue
                                      : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: reduce_bill == '0'
                                ? Radius.circular(10)
                                : numdoctax == '' ||
                                        numdoctax == null ||
                                        numdoctax == 'null'
                                    ? numinvoice == '' ||
                                            numinvoice == null ||
                                            numinvoice == 'null'
                                        ? Radius.circular(0)
                                        : Radius.circular(15)
                                    : Radius.circular(15),
                            topRight: reduce_bill == '0'
                                ? Radius.circular(0)
                                : numdoctax == '' ||
                                        numdoctax == null ||
                                        numdoctax == 'null'
                                    ? numinvoice == '' ||
                                            numinvoice == null ||
                                            numinvoice == 'null'
                                        ? Radius.circular(0)
                                        : Radius.circular(15)
                                    : Radius.circular(15),
                            bottomLeft: reduce_bill == '0'
                                ? Radius.circular(0)
                                : numdoctax == '' ||
                                        numdoctax == null ||
                                        numdoctax == 'null'
                                    ? numinvoice == '' ||
                                            numinvoice == null ||
                                            numinvoice == 'null'
                                        ? Radius.circular(0)
                                        : Radius.circular(15)
                                    : Radius.circular(15),
                            bottomRight: reduce_bill == '0'
                                ? Radius.circular(0)
                                : numdoctax == '' ||
                                        numdoctax == null ||
                                        numdoctax == 'null'
                                    ? numinvoice == '' ||
                                            numinvoice == null ||
                                            numinvoice == 'null'
                                        ? Radius.circular(0)
                                        : Radius.circular(15)
                                    : Radius.circular(15),
                          ),
                          // border: Border.all(
                          //     color: Colors.grey, width: 1),
                        ),
                        padding: reduce_bill == '0'
                            ? EdgeInsets.all(0)
                            : EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            reduce_bill == '0'
                                ? 'รายละเอียด'
                                : numdoctax == '' ||
                                        numdoctax == null ||
                                        numdoctax == 'null'
                                    ? numinvoice == '' ||
                                            numinvoice == null ||
                                            numinvoice == 'null'
                                        ? 'รายละเอียด'
                                        : 'รายละเอียด บิลเลขที่ $numinvoice' // บิลเลขที่ $numinvoice
                                    : 'รายละเอียด บิลเลขที่ $numdoctax', //numinvoice
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: view_bill == 0
                                    ? Colors.white
                                    : PeopleChaoScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T
                                //fontSize: 10.0
                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                numinvoice == null
                    ? SizedBox()
                    : Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orange[100],

                            // border: Border.all(
                            //     color: Colors.grey, width: 1),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                view_bill = 1;
                                red_Invoice_CN();
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: numdoctax == '' ||
                                        numdoctax == null ||
                                        numdoctax == 'null'
                                    ? numinvoice == '' ||
                                            numinvoice == null ||
                                            numinvoice == 'null'
                                        ? Colors.orange[100]
                                        : view_bill == 1
                                            ? Colors.blue
                                            : Colors.white
                                    : view_bill == 1
                                        ? Colors.blue
                                        : Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                // border: Border.all(
                                //     color: Colors.grey, width: 1),
                              ),
                              child: Center(
                                child: Text(
                                  reduce_bill == '1'
                                      ? 'รายละเอียดใบลดหนี้ เลขที่ $reduce_bill_doc'
                                      : numdoctax == '' ||
                                              numdoctax == null ||
                                              numdoctax == 'null'
                                          ? numinvoice == '' ||
                                                  numinvoice == null ||
                                                  numinvoice == 'null'
                                              ? ''
                                              : 'บิลเลขที่ $numinvoice'
                                          : 'บิลเลขที่ $numdoctax', //
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: view_bill == 1
                                          ? Colors.white
                                          : PeopleChaoScreen_Color
                                              .Colors_Text1_,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: FontWeight_.Fonts_T
                                      //fontSize: 10.0
                                      //fontSize: 10.0
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    // padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'ลำดับ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'วันที่ชำระ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'กำหนดชำระ',
                        // 'รายการ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'เลขตั้งหนี้',
                        // 'รายการ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'รายการ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'VAT(฿)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'WHT(฿)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'ยอดสุทธิ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            view_bill == 0
                ? Container(
                    height: 440,
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _TransReBillHistoryModels.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Material(
                          color: AppbackgroundColor.Sub_Abg_Colors,
                          child: ListTile(
                            onTap: () {},
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${index + 1}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${_TransReBillHistoryModels[index].daterec}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${_TransReBillHistoryModels[index].date}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${_TransReBillHistoryModels[index].refno}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${_TransReBillHistoryModels[index].expname}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,

                                    '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                    // '${_TransReBillHistoryModels[index].nvat}',
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,

                                    '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                    // '${_TransReBillHistoryModels[index].wht}',
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : mrp_cn != 2
                    ? Container(
                        height: 440,
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
                          physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _invoiceCNModels.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Material(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              child: ListTile(
                                onTap: () {},
                                title: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${index + 1}',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${_invoiceCNModels[index].daterec}',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${_invoiceCNModels[index].date}',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${_invoiceCNModels[index].refno}',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${_invoiceCNModels[index].expname}',
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,

                                            '${nFormat.format(double.parse(_invoiceCNModels[index].vat!))}',
                                            // '${_TransReBillHistoryModels[index].nvat}',
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,

                                            '${nFormat.format(double.parse(_invoiceCNModels[index].wht!))}',
                                            // '${_TransReBillHistoryModels[index].wht}',
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${nFormat.format(double.parse(_invoiceCNModels[index].total!))}',
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '',
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Icon(
                                            Icons.subdirectory_arrow_right,
                                            color: Colors.red,
                                          ),
                                        ),
                                        // Expanded(
                                        //   flex: 2,
                                        //   child: AutoSizeText(
                                        //     minFontSize: 10,
                                        //     maxFontSize: 15,
                                        //     maxLines: 1,
                                        //     '',
                                        //     textAlign: TextAlign.center,
                                        //     overflow: TextOverflow.ellipsis,
                                        //     style: TextStyle(
                                        //         color: PeopleChaoScreen_Color
                                        //             .Colors_Text2_,
                                        //         //fontWeight: FontWeight.bold,
                                        //         fontFamily: Font_.Fonts_T),
                                        //   ),
                                        // ),
                                        Expanded(
                                          flex: 4,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${_invoiceCNModels[index].nameCn}',
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,

                                            '${nFormat.format(double.parse(_invoiceCNModels[index].vatCn!))}',
                                            // '${_TransReBillHistoryModels[index].nvat}',
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,

                                            '${nFormat.format(double.parse(_invoiceCNModels[index].whtCn!))}',
                                            // '${_TransReBillHistoryModels[index].wht}',
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 15,
                                            maxLines: 1,
                                            '${nFormat.format(double.parse(_invoiceCNModels[index].amtCn!))}',
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                //fontWeight: FontWeight.bold,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Expanded(
                                    //       flex: 1,
                                    //       child: AutoSizeText(
                                    //         minFontSize: 10,
                                    //         maxFontSize: 15,
                                    //         maxLines: 1,
                                    //         '',
                                    //         textAlign: TextAlign.center,
                                    //         overflow: TextOverflow.ellipsis,
                                    //         style: const TextStyle(
                                    //             color: PeopleChaoScreen_Color
                                    //                 .Colors_Text2_,
                                    //             //fontWeight: FontWeight.bold,
                                    //             fontFamily: Font_.Fonts_T),
                                    //       ),
                                    //     ),
                                    //     Expanded(
                                    //       flex: 2,
                                    //       child: AutoSizeText(
                                    //         minFontSize: 10,
                                    //         maxFontSize: 15,
                                    //         maxLines: 1,
                                    //         '',
                                    //         textAlign: TextAlign.center,
                                    //         overflow: TextOverflow.ellipsis,
                                    //         style: const TextStyle(
                                    //             color: PeopleChaoScreen_Color
                                    //                 .Colors_Text2_,
                                    //             //fontWeight: FontWeight.bold,
                                    //             fontFamily: Font_.Fonts_T),
                                    //       ),
                                    //     ),
                                    //     Expanded(flex: 2, child: SizedBox()),
                                    //     // Expanded(
                                    //     //   flex: 2,
                                    //     //   child: AutoSizeText(
                                    //     //     minFontSize: 10,
                                    //     //     maxFontSize: 15,
                                    //     //     maxLines: 1,
                                    //     //     '',
                                    //     //     textAlign: TextAlign.center,
                                    //     //     overflow: TextOverflow.ellipsis,
                                    //     //     style: TextStyle(
                                    //     //         color: PeopleChaoScreen_Color
                                    //     //             .Colors_Text2_,
                                    //     //         //fontWeight: FontWeight.bold,
                                    //     //         fontFamily: Font_.Fonts_T),
                                    //     //   ),
                                    //     // ),
                                    //     Expanded(
                                    //       flex: 4,
                                    //       child: AutoSizeText(
                                    //         minFontSize: 10,
                                    //         maxFontSize: 15,
                                    //         maxLines: 1,
                                    //         '',
                                    //         textAlign: TextAlign.end,
                                    //         overflow: TextOverflow.ellipsis,
                                    //         style: const TextStyle(
                                    //             color: PeopleChaoScreen_Color
                                    //                 .Colors_Text2_,
                                    //             //fontWeight: FontWeight.bold,
                                    //             fontFamily: Font_.Fonts_T),
                                    //       ),
                                    //     ),
                                    //     Expanded(
                                    //       flex: 1,
                                    //       child: AutoSizeText(
                                    //         minFontSize: 10,
                                    //         maxFontSize: 15,
                                    //         maxLines: 1,

                                    //         '',
                                    //         // '${_TransReBillHistoryModels[index].nvat}',
                                    //         textAlign: TextAlign.right,
                                    //         overflow: TextOverflow.ellipsis,
                                    //         style: const TextStyle(
                                    //             color: PeopleChaoScreen_Color
                                    //                 .Colors_Text2_,
                                    //             //fontWeight: FontWeight.bold,
                                    //             fontFamily: Font_.Fonts_T),
                                    //       ),
                                    //     ),
                                    //     Expanded(
                                    //       flex: 1,
                                    //       child: AutoSizeText(
                                    //         minFontSize: 10,
                                    //         maxFontSize: 15,
                                    //         maxLines: 1,

                                    //         '',
                                    //         // '${_TransReBillHistoryModels[index].wht}',
                                    //         textAlign: TextAlign.end,
                                    //         overflow: TextOverflow.ellipsis,
                                    //         style: const TextStyle(
                                    //             color: PeopleChaoScreen_Color
                                    //                 .Colors_Text2_,
                                    //             //fontWeight: FontWeight.bold,
                                    //             fontFamily: Font_.Fonts_T),
                                    //       ),
                                    //     ),
                                    //     Expanded(
                                    //       flex: 2,
                                    //       child: AutoSizeText(
                                    //         minFontSize: 10,
                                    //         maxFontSize: 15,
                                    //         maxLines: 1,
                                    //         '${nFormat.format(double.parse(_invoiceCNModels[index].amtCn!) - double.parse(_invoiceCNModels[index].total!))}',
                                    //         textAlign: TextAlign.end,
                                    //         overflow: TextOverflow.ellipsis,
                                    //         style: const TextStyle(
                                    //             color: PeopleChaoScreen_Color
                                    //                 .Colors_Text2_,
                                    //             decoration:
                                    //                 TextDecoration.underline,
                                    //             decorationStyle:
                                    //                 TextDecorationStyle.double,
                                    //             decorationColor: Colors.red,
                                    //             //fontWeight: FontWeight.bold,
                                    //             fontFamily: Font_.Fonts_T),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(0),
                        child: Column(
                          children: [
                            Container(
                              height: 390,
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
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _TransReBillHistoryModels.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Material(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    child: ListTile(
                                      onTap: () {},
                                      title: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              '${index + 1}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              '${_TransReBillHistoryModels[index].daterec}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              '${_TransReBillHistoryModels[index].date}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              '${_TransReBillHistoryModels[index].refno}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              '${_TransReBillHistoryModels[index].expname}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,

                                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                              // '${_TransReBillHistoryModels[index].nvat}',
                                              textAlign: TextAlign.right,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,

                                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                              // '${_TransReBillHistoryModels[index].wht}',
                                              textAlign: TextAlign.end,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: AutoSizeText(
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                              textAlign: TextAlign.end,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  //fontWeight: FontWeight.bold,
                                                  fontFamily: Font_.Fonts_T),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              height: 50,
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
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: _invoiceCNModels.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Material(
                                    color: AppbackgroundColor.Sub_Abg_Colors,
                                    child: ListTile(
                                      onTap: () {},
                                      title: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  '',
                                                  textAlign: TextAlign.center,
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
                                                flex: 2,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  '',
                                                  textAlign: TextAlign.center,
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
                                                flex: 2,
                                                child: Icon(
                                                  Icons
                                                      .subdirectory_arrow_right,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              // Expanded(
                                              //   flex: 2,
                                              //   child: AutoSizeText(
                                              //     minFontSize: 10,
                                              //     maxFontSize: 15,
                                              //     maxLines: 1,
                                              //     '',
                                              //     textAlign: TextAlign.center,
                                              //     overflow: TextOverflow.ellipsis,
                                              //     style: TextStyle(
                                              //         color: PeopleChaoScreen_Color
                                              //             .Colors_Text2_,
                                              //         //fontWeight: FontWeight.bold,
                                              //         fontFamily: Font_.Fonts_T),
                                              //   ),
                                              // ),
                                              Expanded(
                                                flex: 4,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  '${_invoiceCNModels[index].nameCn}',
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
                                                  maxFontSize: 15,
                                                  maxLines: 1,

                                                  '${nFormat.format(double.parse(_invoiceCNModels[index].vatCn!))}',
                                                  // '${_TransReBillHistoryModels[index].nvat}',
                                                  textAlign: TextAlign.right,
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
                                                  maxFontSize: 15,
                                                  maxLines: 1,

                                                  '${nFormat.format(double.parse(_invoiceCNModels[index].whtCn!))}',
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
                                              Expanded(
                                                flex: 2,
                                                child: AutoSizeText(
                                                  minFontSize: 10,
                                                  maxFontSize: 15,
                                                  maxLines: 1,
                                                  '${nFormat.format(double.parse(_invoiceCNModels[index].amtCn!))}',
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
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )),
            Container(
                width: (Responsive.isDesktop(context))
                    ? MediaQuery.of(context).size.width * 0.52
                    : 900,
                decoration: const BoxDecoration(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    dtypeselect == '!Z'
                        ? SizedBox()
                        : _TransReBillHistoryModels.length == 0
                            ? SizedBox()
                            : Column(
                                children: [
                                  Divider(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 8, left: 8, right: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            view_bill == 0
                                                ? 'รายละเอียดการชำระ'
                                                : '',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T
                                                //fontSize: 10.0
                                                ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child:
                                              (Slip_history == null ||
                                                      Slip_history.toString() ==
                                                          'null' ||
                                                      Slip_history.toString() ==
                                                          '')
                                                  ? SizedBox()
                                                  : discount_page == 1
                                                      ? SizedBox()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: InkWell(
                                                            child: Container(
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: (Slip_history
                                                                                .toString() ==
                                                                            '' ||
                                                                        Slip_history ==
                                                                            null ||
                                                                        Slip_history.toString() ==
                                                                            'null')
                                                                    ? Colors.green[
                                                                        200]
                                                                    : Colors
                                                                        .green,
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft:
                                                                        Radius.circular(
                                                                            8),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            8),
                                                                    bottomLeft:
                                                                        Radius.circular(
                                                                            8),
                                                                    bottomRight:
                                                                        Radius.circular(
                                                                            8)),
                                                                // border: Border.all(
                                                                //     color: Colors.grey, width: 2),
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Center(
                                                                child: Text(
                                                                  (Slip_history.toString() == '' ||
                                                                          Slip_history ==
                                                                              null ||
                                                                          Slip_history.toString() ==
                                                                              'null')
                                                                      ? 'ไม่พบหลักฐาน'
                                                                      : 'พบหลักฐาน ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T
                                                                      //fontSize: 10.0
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                            onTap: (Slip_history
                                                                            .toString() ==
                                                                        '' ||
                                                                    Slip_history ==
                                                                        null ||
                                                                    Slip_history
                                                                            .toString() ==
                                                                        'null')
                                                                ? null
                                                                : () async {
                                                                    String Url =
                                                                        await '${MyConstant().domain}/files/$foder/slip/${Slip_history}';
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder: (context) => AlertDialog(
                                                                          title: Center(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Text(
                                                                                  numinvoice == null
                                                                                      ? 'บิลเลขที่'
                                                                                      : numdoctax == ''
                                                                                          ? 'บิลเลขที่ $numinvoice'
                                                                                          : 'บิลเลขที่ $numdoctax',
                                                                                  maxLines: 1,
                                                                                  textAlign: TextAlign.start,
                                                                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                                                                ),
                                                                                Text(
                                                                                  '${Slip_history}',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 12.0),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          content: Stack(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            children: <Widget>[
                                                                              Image.network('$Url')
                                                                            ],
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
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: Container(
                                                                                        width: 100,
                                                                                        decoration: const BoxDecoration(
                                                                                          color: Colors.black,
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
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ]),
                                                                    );
                                                                  },
                                                          ),
                                                        ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child:
                                              _TransReBillHistoryModels
                                                          .length ==
                                                      0
                                                  ? SizedBox()
                                                  : discount_page == 1
                                                      ? SizedBox()
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: InkWell(
                                                            onTap: (_TransReBillHistoryModels
                                                                        .length ==
                                                                    0)
                                                                ? null
                                                                : () async {
                                                                    setState(
                                                                        () {
                                                                      Receipt_type =
                                                                          'Bill_pay';
                                                                    });
                                                                    final tableData00 =
                                                                        [
                                                                      for (int index =
                                                                              0;
                                                                          index <
                                                                              _TransReBillHistoryModels.length;
                                                                          index++)
                                                                        [
                                                                          '${index + 1}',
                                                                          '${_TransReBillHistoryModels[index].date}',
                                                                          '${_TransReBillHistoryModels[index].expname}',
                                                                          '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                                                          '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                                                          '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                                                          '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                                        ],
                                                                    ];

                                                                    List
                                                                        newValuePDFimg =
                                                                        [];
                                                                    for (int index =
                                                                            0;
                                                                        index <
                                                                            1;
                                                                        index++) {
                                                                      if (renTalModels[0]
                                                                              .imglogo!
                                                                              .trim() ==
                                                                          '') {
                                                                        // newValuePDFimg.add(
                                                                        //     'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg');
                                                                      } else {
                                                                        newValuePDFimg
                                                                            .add('${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                                      }
                                                                    }

                                                                    ////////////////////----------------->

                                                                    showMyDialog_SAVE(
                                                                        tableData00,
                                                                        newValuePDFimg,
                                                                        room_number_BillHistory);
                                                                  },
                                                            child: Container(
                                                                height: 50,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                  color: Colors
                                                                      .blue,
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
                                                                  // border: Border.all(color: Colors.white, width: 1),
                                                                ),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Center(
                                                                    child: Text(
                                                                  'พิมพ์ใบเสร็จ',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          FontWeight_
                                                                              .Fonts_T),
                                                                ))),
                                                          ),
                                                        ),
                                        ),
                                        reduce_bill == '0' ||
                                                reduce_bill == null
                                            ? SizedBox()
                                            : Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        Receipt_type =
                                                            'Credit_Note';
                                                      });
                                                      final tableData00 = [
                                                        for (int index = 0;
                                                            index <
                                                                _TransReBillHistoryModels
                                                                    .length;
                                                            index++)
                                                          [
                                                            '${index + 1}',
                                                            '${_TransReBillHistoryModels[index].date}',
                                                            '${_TransReBillHistoryModels[index].expname}',
                                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))}',
                                                            '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total!))}',
                                                          ],
                                                      ];

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

                                                      ////////////////////----------------->

                                                      showMyDialog_SAVE(
                                                          tableData00,
                                                          newValuePDFimg,
                                                          room_number_BillHistory);
                                                    },
                                                    child: Container(
                                                        height: 50,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.purple,
                                                          borderRadius: BorderRadius.only(
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
                                                          // border: Border.all(color: Colors.white, width: 1),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Center(
                                                            child: Text(
                                                          'พิมพ์ใบลดหนี้',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T),
                                                        ))),
                                                  ),
                                                ),
                                              ),
                                        // reduce_bill == '0' ||
                                        //         reduce_bill == null
                                        //     ? SizedBox()
                                        //     : Expanded(
                                        //         flex: 1,
                                        //         child: Padding(
                                        //           padding:
                                        //               const EdgeInsets.all(8.0),
                                        //           child: InkWell(
                                        //             onTap: () {},
                                        //             child: Container(
                                        //                 height: 50,
                                        //                 decoration:
                                        //                      BoxDecoration(
                                        //                   color: Colors.purple.shade300,
                                        //                   borderRadius: BorderRadius.only(
                                        //                       topLeft: Radius
                                        //                           .circular(10),
                                        //                       topRight: Radius
                                        //                           .circular(10),
                                        //                       bottomLeft: Radius
                                        //                           .circular(10),
                                        //                       bottomRight:
                                        //                           Radius
                                        //                               .circular(
                                        //                                   10)),
                                        //                   // border: Border.all(color: Colors.white, width: 1),
                                        //                 ),
                                        //                 padding:
                                        //                     EdgeInsets.all(8.0),
                                        //                 child: Center(
                                        //                     child: Text(
                                        //                   'View',
                                        //                   style: TextStyle(
                                        //                       color:
                                        //                           Colors.white,
                                        //                       fontWeight:
                                        //                           FontWeight
                                        //                               .bold,
                                        //                       fontFamily:
                                        //                           FontWeight_
                                        //                               .Fonts_T),
                                        //                 ))),
                                        //           ),
                                        //         ),
                                        //       ),
                                        reduce_bill == '0' ||
                                                reduce_bill == null
                                            ? SizedBox()
                                            : reduce_bill_status == '1'
                                                ? SizedBox()
                                                : Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          print(
                                                              '$docnoin_up >>> $reduce_bill_doc');
                                                          PanaraConfirmDialog
                                                              .showAnimatedGrow(
                                                            context,
                                                            title: "ทำรายการ",
                                                            message:
                                                                "ยกเลิกใบลดหนี้",
                                                            confirmButtonText:
                                                                "ยืนยัน",
                                                            cancelButtonText:
                                                                "ปิด",
                                                            onTapConfirm:
                                                                () async {
                                                              var t_docnoin_up =
                                                                  docnoin_up;
                                                              var t_reduce_bill_doc =
                                                                  reduce_bill_doc;

                                                              Insert_log
                                                                  .Insert_logs(
                                                                      'ลดหนี้',
                                                                      'ยกเลิกใบลดหนี้:$reduce_bill_doc > $docnoin_up ยืนยันยกเลิกใบลดหนี้');

                                                              SharedPreferences
                                                                  preferences =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              var ren = preferences
                                                                  .getString(
                                                                      'renTalSer');
                                                              var user =
                                                                  preferences
                                                                      .getString(
                                                                          'ser');
                                                              var ciddoc = widget
                                                                  .Get_Value_cid;

                                                              String url =
                                                                  '${MyConstant().domain}/U_Can_CN.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&user=$user&docnoin_up=$docnoin_up&reduce_bill_doc=$reduce_bill_doc';
                                                              try {
                                                                var response =
                                                                    await http.get(
                                                                        Uri.parse(
                                                                            url));

                                                                var result =
                                                                    json.decode(
                                                                        response
                                                                            .body);
                                                                // print(result);
                                                                if (result
                                                                        .toString() ==
                                                                    'true') {
                                                                  setState(() {
                                                                    _InvoiceModels
                                                                        .clear();
                                                                    _InvoiceHistoryModels
                                                                        .clear();
                                                                    _TransReBillHistoryModels
                                                                        .clear();
                                                                    numinvoice =
                                                                        null;
                                                                    numdoctax =
                                                                        null;
                                                                    // sum_disamtx.text = '0.00';
                                                                    // sum_dispx.text = '0.00';
                                                                    sum_pvat =
                                                                        0.00;
                                                                    sum_vat =
                                                                        0.00;
                                                                    sum_wht =
                                                                        0.00;
                                                                    sum_amt =
                                                                        0.00;
                                                                    sum_dis =
                                                                        0.00;
                                                                    sum_disamt =
                                                                        0.00;
                                                                    sum_disp =
                                                                        0;
                                                                    select_page =
                                                                        0;
                                                                    red_Trans_bill();
                                                                    finnancetransModels
                                                                        .clear();
                                                                  });
                                                                }
                                                              } catch (e) {}
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            onTapCancel: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            panaraDialogType:
                                                                PanaraDialogType
                                                                    .warning,
                                                          );
                                                        },
                                                        child: Container(
                                                            height: 50,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Colors.red,
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
                                                              // border: Border.all(color: Colors.white, width: 1),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Center(
                                                                child: Text(
                                                              'ยกเลิกใบลดหนี้',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      FontWeight_
                                                                          .Fonts_T),
                                                            ))),
                                                      ),
                                                    ),
                                                  ),
                                        reduce_bill == '0' ||
                                                reduce_bill == null
                                            ? SizedBox()
                                            : reduce_bill_status == '1'
                                                ? SizedBox()
                                                : Expanded(
                                                    flex: 2,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          if (renTal_lavel >=
                                                              4) {
                                                            PanaraConfirmDialog
                                                                .showAnimatedGrow(
                                                              context,
                                                              title: "ทำรายการ",
                                                              message:
                                                                  "อนุมัติใบลดหนี้",
                                                              confirmButtonText:
                                                                  "ยืนยัน",
                                                              cancelButtonText:
                                                                  "ปิด",
                                                              onTapConfirm:
                                                                  () async {
                                                                var t_docnoin_up =
                                                                    docnoin_up;
                                                                var t_reduce_bill_doc =
                                                                    reduce_bill_doc;

                                                                Insert_log
                                                                    .Insert_logs(
                                                                        'ลดหนี้',
                                                                        'อนุมัติใบลดหนี้:$reduce_bill_doc > $docnoin_up ยืนยันอนุมัติใบลดหนี้');

                                                                SharedPreferences
                                                                    preferences =
                                                                    await SharedPreferences
                                                                        .getInstance();
                                                                var ren = preferences
                                                                    .getString(
                                                                        'renTalSer');
                                                                var user = preferences
                                                                    .getString(
                                                                        'ser');
                                                                var ciddoc = widget
                                                                    .Get_Value_cid;

                                                                String url =
                                                                    '${MyConstant().domain}/U_Can_CN_Add.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&user=$user&docnoin_up=$docnoin_up&reduce_bill_doc=$reduce_bill_doc';
                                                                try {
                                                                  var response =
                                                                      await http.get(
                                                                          Uri.parse(
                                                                              url));

                                                                  var result =
                                                                      json.decode(
                                                                          response
                                                                              .body);
                                                                  // print(result);
                                                                  if (result
                                                                          .toString() ==
                                                                      'true') {
                                                                    setState(
                                                                        () {
                                                                      _InvoiceModels
                                                                          .clear();
                                                                      _InvoiceHistoryModels
                                                                          .clear();
                                                                      _TransReBillHistoryModels
                                                                          .clear();
                                                                      numinvoice =
                                                                          null;
                                                                      numdoctax =
                                                                          null;
                                                                      // sum_disamtx.text = '0.00';
                                                                      // sum_dispx.text = '0.00';
                                                                      sum_pvat =
                                                                          0.00;
                                                                      sum_vat =
                                                                          0.00;
                                                                      sum_wht =
                                                                          0.00;
                                                                      sum_amt =
                                                                          0.00;
                                                                      sum_dis =
                                                                          0.00;
                                                                      sum_disamt =
                                                                          0.00;
                                                                      sum_disp =
                                                                          0;
                                                                      select_page =
                                                                          0;
                                                                      red_Trans_bill();
                                                                      finnancetransModels
                                                                          .clear();
                                                                    });
                                                                  }
                                                                } catch (e) {}
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              onTapCancel: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              panaraDialogType:
                                                                  PanaraDialogType
                                                                      .success,
                                                            );
                                                          } else {
                                                            PanaraInfoDialog
                                                                .showAnimatedGrow(
                                                              context,
                                                              title: "Oops",
                                                              message:
                                                                  "User ของท่านไม่สามารถทำการได้ !!",
                                                              buttonText:
                                                                  "รับทราบ",
                                                              onTapDismiss:
                                                                  () async {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              panaraDialogType:
                                                                  PanaraDialogType
                                                                      .error,
                                                              barrierDismissible:
                                                                  false,
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                            height: 50,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color:
                                                                  Colors.green,
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
                                                              // border: Border.all(color: Colors.white, width: 1),
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Center(
                                                                child: Text(
                                                              'อนุมัติใบลดหนี้',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      FontWeight_
                                                                          .Fonts_T),
                                                            ))),
                                                      ),
                                                    ),
                                                  ),
                                        reduce_bill == '1'
                                            ? SizedBox()
                                            :
                                            // (DateTime.now()
                                            //             .difference(DateTime.parse(
                                            //                 '$date_check 00:00:00'))
                                            //             .inDays <=
                                            //         30)
                                            //     ?
                                            Expanded(
                                                flex: 2,
                                                child: _TransReBillHistoryModels
                                                            .length ==
                                                        0
                                                    ? SizedBox()
                                                    : Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: InkWell(
                                                          onTap: () {
                                                            // if (DateTime.now()
                                                            //         .difference(DateTime.parse('$date_check 00:00:00'))
                                                            //         .inDays <=
                                                            //     30) {
                                                            setState(() {
                                                              de_Trans_CN('0');
                                                              if (discount_page ==
                                                                  1) {
                                                                discount_page =
                                                                    0;
                                                                dis_bill = 0;
                                                              } else {
                                                                discount_page =
                                                                    1;
                                                                dis_bill = 0;
                                                              }
                                                            });
                                                            // } else {
                                                            //   PanaraInfoDialog
                                                            //       .showAnimatedGrow(
                                                            //     context,
                                                            //     title:
                                                            //         "Oops",
                                                            //     message:
                                                            //         "เกินกำหนด คุณไม่สามารถทำรายการได้ !!",
                                                            //     buttonText:
                                                            //         "รับทราบ",
                                                            //     onTapDismiss:
                                                            //         () async {
                                                            //       Navigator.pop(
                                                            //           context);
                                                            //     },
                                                            //     panaraDialogType:
                                                            //         PanaraDialogType.error,
                                                            //     barrierDismissible:
                                                            //         false,
                                                            //   );
                                                            // }
                                                          },
                                                          child: Container(
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .orange
                                                                    .shade900,
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
                                                                // border: Border.all(color: Colors.white, width: 1),
                                                              ),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Center(
                                                                  child: Text(
                                                                discount_page ==
                                                                        1
                                                                    ? 'ยกเลิกทำรายการลดหนี้'
                                                                    : 'ทำรายการลดหนี้',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        FontWeight_
                                                                            .Fonts_T),
                                                              ))),
                                                        ),
                                                      ),
                                              )
                                        // : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                    dtypeselect == '!Z'
                        ? SizedBox()
                        : _TransReBillHistoryModels.length == 0
                            ? SizedBox()
                            : view_bill == 0
                                ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 8, right: 8, bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 4,
                                                      child: Remark_ == ''
                                                          ? SizedBox()
                                                          : Text(
                                                              'หมายเหตุ : $Remark_',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .orange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                            )
                                                      //  Text(
                                                      //   (Slip_history.toString() == null ||
                                                      //           Slip_history ==
                                                      //               null ||
                                                      //           Slip_history.toString() ==
                                                      //               'null')
                                                      //       ? 'หลักฐานการโอน'
                                                      //       : '',
                                                      //   textAlign:
                                                      //       TextAlign
                                                      //           .end,
                                                      //   style: TextStyle(
                                                      //       color: PeopleChaoScreen_Color
                                                      //           .Colors_Text1_,
                                                      //       fontWeight:
                                                      //           FontWeight
                                                      //               .bold,
                                                      //       fontFamily:
                                                      //           FontWeight_.Fonts_T
                                                      //       //fontSize: 10.0
                                                      //       ),
                                                      // ),
                                                      ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'รวม(บาท)',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      round_p == '1'
                                                          ? '${nFormat.format(sum_pvat_up)}'
                                                          : '${nFormat.format(sum_pvat)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        rental_ser != '106'
                                                            ? SizedBox()
                                                            : IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  // print(_TransReBillModels[
                                                                  //         index]
                                                                  //     .docno);
                                                                  if (renTal_lavel >
                                                                      3) {
                                                                    if (rental_degree_up ==
                                                                        '1') {
                                                                      new_dereee
                                                                          .text = round_p ==
                                                                              '1'
                                                                          ? sum_pvat_up.toString().substring(sum_pvat_up.toString().indexOf('.') +
                                                                              1)
                                                                          : sum_pvat
                                                                              .toString()
                                                                              .substring(sum_pvat.toString().indexOf('.') + 1);
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder: (context) => AlertDialog(
                                                                            title: Center(
                                                                              child: Text(
                                                                                'ปรับจุดทศนิยม',
                                                                                maxLines: 1,
                                                                                textAlign: TextAlign.start,
                                                                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T, fontSize: 20),
                                                                              ),
                                                                            ),
                                                                            content: Stack(
                                                                              alignment: Alignment.center,
                                                                              children: <Widget>[
                                                                                Container(
                                                                                    width: 250,
                                                                                    decoration: const BoxDecoration(
                                                                                      // color: Colors.black,
                                                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                    ),
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          flex: 3,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                                            children: [
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.all(8.0),
                                                                                                child: Text(
                                                                                                  round_p == '1' ? '${sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1)}' : '${sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1)}',
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          flex: 2,
                                                                                          child: TextFormField(
                                                                                            //keyboardType: TextInputType.none,
                                                                                            controller: new_dereee,
                                                                                            // onChanged: (value) => value.trim(),
                                                                                            onFieldSubmitted: (value) async {
                                                                                              var new_amt = round_p == '1' ? sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1) + value : sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1) + value;

                                                                                              print(docnoin_up);
                                                                                              SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                              var ren = preferences.getString('renTalSer');
                                                                                              var docno = docnoin_up;
                                                                                              var sum_amt_up = double.parse(new_amt);
                                                                                              var sum_vat_up = double.parse(new_amt.toString()) * 7 / 100;

                                                                                              String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                                                              try {
                                                                                                var response = await http.get(Uri.parse(url));

                                                                                                var result = json.decode(response.body);
                                                                                                if (result.toString() == 'true') {
                                                                                                  setState(() {
                                                                                                    red_Trans_select_up();
                                                                                                    red_Invoice_up();

                                                                                                    // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum).toStringAsFixed(2).toString();
                                                                                                  });
                                                                                                }
                                                                                              } catch (e) {}

                                                                                              Navigator.pop(context, 'OK');
                                                                                            },
                                                                                            // maxLength: 13,
                                                                                            cursorColor: Colors.green,
                                                                                            decoration: InputDecoration(
                                                                                              fillColor: Colors.white.withOpacity(0.3),
                                                                                              filled: true,
                                                                                              // prefixIcon: const Icon(Icons.person, color: Colors.black),
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
                                                                                              errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                              enabledBorder: const OutlineInputBorder(
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
                                                                                              // labelText: 'USERNAME',
                                                                                              labelStyle: const TextStyle(
                                                                                                fontSize: 14,
                                                                                                color: Colors.black54,
                                                                                                fontFamily: Font_.Fonts_T,
                                                                                              ),
                                                                                            ),
                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                              //   // for below version 2 use this
                                                                                              //   FilteringTextInputFormatter(RegExp("[a-zA-Z1-9@.]"),
                                                                                              //       allow: true),
                                                                                              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                                                              //for version 2 and greater youcan also use this
                                                                                              FilteringTextInputFormatter.digitsOnly
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ))
                                                                              ],
                                                                            ),
                                                                            actions: <Widget>[
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Container(
                                                                                      width: 100,
                                                                                      decoration: const BoxDecoration(
                                                                                        color: Colors.black,
                                                                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                      ),
                                                                                      padding: const EdgeInsets.all(8.0),
                                                                                      child: TextButton(
                                                                                        onPressed: () => Navigator.pop(context, 'OK'),
                                                                                        child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ]),
                                                                      );
                                                                    } else if (rental_degree_up ==
                                                                        '2') {
                                                                      print(
                                                                          docnoin_up);
                                                                      SharedPreferences
                                                                          preferences =
                                                                          await SharedPreferences
                                                                              .getInstance();
                                                                      var ren =
                                                                          preferences
                                                                              .getString('renTalSer');
                                                                      var docno =
                                                                          docnoin_up;
                                                                      var sum_amt_up = round_p ==
                                                                              '1'
                                                                          ? sum_pvat_up.toPrecision(
                                                                              1)
                                                                          : sum_pvat
                                                                              .toPrecision(1);
                                                                      var sum_vat_up = round_p ==
                                                                              '1'
                                                                          ? sum_pvat_up.toPrecision(1) *
                                                                              7 /
                                                                              100
                                                                          : sum_pvat.toPrecision(1) *
                                                                              7 /
                                                                              100;

                                                                      String
                                                                          url =
                                                                          '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                                      try {
                                                                        var response =
                                                                            await http.get(Uri.parse(url));

                                                                        var result =
                                                                            json.decode(response.body);
                                                                        if (result.toString() ==
                                                                            'true') {
                                                                          setState(
                                                                              () {
                                                                            red_Trans_select_up();
                                                                            red_Invoice_up();
                                                                          });
                                                                        }
                                                                      } catch (e) {}
                                                                    }
                                                                  } else {
                                                                    Dialog_updegree();
                                                                  }
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .unfold_more,
                                                                ),
                                                              ),
                                                        Text(
                                                          'บาท',
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
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'ภาษีมูลค่าเพิ่ม(vat)',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      round_p == '1'
                                                          ? '${nFormat.format(sum_vat_up)}'
                                                          : '${nFormat.format(sum_vat)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'หัก ณ ที่จ่าย',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '${nFormat.format(sum_wht)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'ยอดรวม',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '${nFormat.format(sum_amt)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'ส่วนลด',
                                                          textAlign:
                                                              TextAlign.start,
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
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              total_amt == 0.00
                                                  ? SizedBox()
                                                  : Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            'หักชำระ',
                                                            textAlign:
                                                                TextAlign.start,
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
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${nFormat.format(total_amt)}',
                                                            textAlign:
                                                                TextAlign.end,
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
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'บาท',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'ยอดชำระรวม',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      // '${nFormat.format(sum_amt - sum_disamt)}',
                                                      '${nFormat.format(sum_amt - sum_disamt - total_amt)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      'รูปแบบการชำระ',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 4,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        for (var i = 0;
                                                            i <
                                                                finnancetransModels
                                                                    .length;
                                                            i++)
                                                          finnancetransModels[i]
                                                                      .dtype ==
                                                                  'KP'
                                                              ? AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      15,
                                                                  finnancetransModels[i]
                                                                              .type ==
                                                                          'CASH'
                                                                      ? '${finnancetransModels[i].type} (เงินสด)'
                                                                      : '${finnancetransModels[i].type} (เงินโอน)',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: TextStyle(
                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                )
                                                              : AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      15,
                                                                  '${finnancetransModels[i].remark}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: TextStyle(
                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              for (var i = 0;
                                                  i <
                                                      finnancetransModels
                                                          .length;
                                                  i++)
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 15,
                                                        textAlign:
                                                            TextAlign.start,
                                                        nFormat.format(sum_amt -
                                                                    sum_disamt -
                                                                    total_amt) ==
                                                                nFormat.format(
                                                                    double.parse(
                                                                        finnancetransModels[i]
                                                                            .amt!))
                                                            ? ''
                                                            : 'ยอดรับชำระไม่กับยอดชำระ',
                                                        style: TextStyle(
                                                            color: Colors.red,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 15,
                                                        textAlign:
                                                            TextAlign.end,
                                                        'จำนวน',
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
                                                      child: AutoSizeText(
                                                        minFontSize: 10,
                                                        maxFontSize: 15,
                                                        '${nFormat.format(double.parse(finnancetransModels[i].amt!))}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                            color: nFormat.format(sum_amt -
                                                                        sum_disamt -
                                                                        total_amt) ==
                                                                    nFormat.format(double.parse(
                                                                        finnancetransModels[i]
                                                                            .amt!))
                                                                ? PeopleChaoScreen_Color
                                                                    .Colors_Text2_
                                                                : Colors.red,
                                                            //fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        'บาท',
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
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        left: 8, right: 8, bottom: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            children: [
                                              Divider(),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'รวม(บาท)',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '${nFormat.format(pvat_cn)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'ภาษีมูลค่าเพิ่ม(vat)',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '${nFormat.format(vat_cn)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'หัก ณ ที่จ่าย',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '${nFormat.format(wht_cn)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'ยอดรวม',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      '${nFormat.format(amt_cn)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'ยอดลดหนี้รวม',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      // '${nFormat.format(sum_amt - sum_disamt)}',
                                                      '${nFormat.format(amt_cn)}',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
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
                                  )
                  ],
                ))
          ])),
    );
  }

  Padding page_detel_Dicount() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          width: (Responsive.isDesktop(context))
              ? MediaQuery.of(context).size.width * 0.52
              : 900,
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
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
                      child: Text(
                        'รายละเอียดรายการลดหนี้',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                numinvoice == null
                    ? SizedBox()
                    : Expanded(
                        flex: 2,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.orange[100],

                            // border: Border.all(
                            //     color: Colors.grey, width: 1),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              // border: Border.all(
                              //     color: Colors.grey, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                numdoctax == ''
                                    ? 'บิลเลขที่ $numinvoice'
                                    : 'บิลเลขที่ $numdoctax', //
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text1_,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: FontWeight_.Fonts_T
                                    //fontSize: 10.0
                                    //fontSize: 10.0
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    // padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'ลำดับ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'เลขตั้งหนี้',
                        // 'รายการ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'รายการ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                // Expanded(
                //   flex: 1,
                //   child: Container(
                //     height: 50,
                //     color: Colors.brown[200],
                //     padding: const EdgeInsets.all(8.0),
                //     child: const Center(
                //       child: AutoSizeText(
                //         minFontSize: 10,
                //         maxFontSize: 15,
                //         maxLines: 1,
                //         'ประเภท',
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //             color: PeopleChaoScreen_Color.Colors_Text1_,
                //             fontWeight: FontWeight.bold,
                //             fontFamily: FontWeight_.Fonts_T
                //             //fontSize: 10.0
                //             //fontSize: 10.0
                //             ),
                //       ),
                //     ),
                //   ),
                // ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'ยอดก่อน VAT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'VAT(%)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'VAT(฿)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'WHT(%)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'WHT(฿)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 50,
                    color: Colors.brown[200],
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        maxLines: 1,
                        'ยอดสุทธิ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: dis_bill == 1
                  ? 210
                  : dis_bill == 2
                      ? 340
                      : 440,
              decoration: BoxDecoration(
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
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _TransReBillHistoryModels.length,
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    color: _TransModels.any((item) =>
                                item.refno ==
                                _TransReBillHistoryModels[index].refno) ==
                            true
                        ? Colors.orange.shade100
                        : AppbackgroundColor.Sub_Abg_Colors,
                    child: ListTile(
                      onTap: () {
                        if (dis_bill == 1) {
                          var docno_se = _TransReBillHistoryModels[index].ser;
                          var refno_se = _TransReBillHistoryModels[index].refno;

                          if (_TransModels.any(
                              (item) => item.refno == refno_se)) {
                          } else {
                            in_dis_select(docno_se!, 1);
                          }
                        }
                      },
                      title: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,
                              '${index + 1}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,
                              '${_TransReBillHistoryModels[index].refno}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,
                              '${_TransReBillHistoryModels[index].expname}',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child: AutoSizeText(
                          //     minFontSize: 10,
                          //     maxFontSize: 15,
                          //     maxLines: 1,
                          //     '${_TransReBillHistoryModels[index].vtype}',
                          //     textAlign: TextAlign.center,
                          //     overflow: TextOverflow.ellipsis,
                          //     style: const TextStyle(
                          //         color: PeopleChaoScreen_Color.Colors_Text2_,
                          //         //fontWeight: FontWeight.bold,
                          //         fontFamily: Font_.Fonts_T),
                          //   ),
                          // ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                AutoSizeText(
                                  minFontSize: 4,
                                  maxFontSize: 10,
                                  maxLines: 1,
                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].amt!))} ( ${_TransReBillHistoryModels[index].vtype} )',
                                  // '${_TransReBillHistoryModels[index].nvat}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: Font_.Fonts_T),
                                ),
                                AutoSizeText(
                                  minFontSize: 10,
                                  maxFontSize: 15,
                                  maxLines: 1,

                                  '${nFormat.format(double.parse(_TransReBillHistoryModels[index].pvat!))}',
                                  // '${_TransReBillHistoryModels[index].nvat}',
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,

                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nvat!))}',
                              // '${_TransReBillHistoryModels[index].nvat}',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,

                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].vat!))}',
                              // '${_TransReBillHistoryModels[index].nvat}',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,

                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].nwht!))}',
                              // '${_TransReBillHistoryModels[index].wht}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,

                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].wht!))}',
                              // '${_TransReBillHistoryModels[index].wht}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: AutoSizeText(
                              minFontSize: 10,
                              maxFontSize: 15,
                              maxLines: 1,
                              '${nFormat.format(double.parse(_TransReBillHistoryModels[index].total_t!))}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            dis_bill == 0 ? SizedBox() : Divider(),
            dis_bill == 0
                ? SizedBox()
                : Container(
                    height: dis_bill == 1
                        ? 210
                        : dis_bill == 2
                            ? 80
                            : 440,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
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
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _TransModels.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Material(
                          color: Colors.green.shade50,
                          child: ListTile(
                            onTap: () {
                              if (dis_bill == 1) {
                                PanaraConfirmDialog.showAnimatedGrow(
                                  context,
                                  title: "ทำรายการ",
                                  message: "ปรับส่วนลด หรือ ลบรายการ",
                                  confirmButtonText: "ลบรายการ",
                                  cancelButtonText: "ปรับส่วนลด",
                                  onTapConfirm: () async {
                                    var t_ser = _TransModels[index].ser;
                                    de_Trans_CN(t_ser!);
                                    Navigator.pop(context);
                                  },
                                  onTapCancel: () {
                                    Navigator.pop(context);
                                    showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20.0))),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Translate
                                                    .TranslateAndSetText(
                                                        'ส่วนลดรายการ : ${nFormat.format(double.parse(_TransModels[index].ocost!) == 0 ? double.parse(_TransModels[index].amt!) : double.parse(_TransModels[index].ocost!))}',
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                        TextAlign.center,
                                                        null,
                                                        Font_.Fonts_T,
                                                        13,
                                                        1),
                                                //  Text(
                                                //   'ส่วนลดรายการ', // Navigator.pop(context, 'OK');
                                                //   style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                // ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          Formposlokdispri_
                                                              .clear();
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(Icons.close,
                                                          color: Colors.black)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          Form(
                                            key: _formKey,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: TextFormField(
                                                    controller:
                                                        Formposlokdispri_,
                                                    // obscureText:
                                                    //     true,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return ' ';
                                                      }
                                                      // if (int.parse(value.toString()) < 13) {
                                                      //   return '< 13';
                                                      // }
                                                      return null;
                                                    },

                                                    onFieldSubmitted:
                                                        (val) async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        SharedPreferences
                                                            preferences =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        var ren = preferences
                                                            .getString(
                                                                'renTalSer');
                                                        var user = preferences
                                                            .getString('ser');

                                                        var sertran =
                                                            _TransModels[index]
                                                                .ser;
                                                        var vel =
                                                            Formposlokdispri_
                                                                .text
                                                                .trim();
                                                        if (double.parse(vel) <=
                                                            double.parse(
                                                                _TransModels[
                                                                        index]
                                                                    .total!)) {
                                                          // print('vel>>>>$vel');
                                                          String url =
                                                              '${MyConstant().domain}/c_trans_select_dis_cn.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';

                                                          try {
                                                            var response =
                                                                await http.get(
                                                                    Uri.parse(
                                                                        url));

                                                            var result = json
                                                                .decode(response
                                                                    .body);
                                                            // print(result);
                                                            if (result
                                                                    .toString() ==
                                                                'true') {
                                                              setState(() {
                                                                red_Trans_CN();
                                                                Formposlokdispri_
                                                                    .clear();
                                                              });
                                                              Navigator.pop(
                                                                  context);
                                                            } else {
                                                              setState(() {
                                                                Formposlokdispri_
                                                                    .clear();
                                                              });

                                                              Navigator.pop(
                                                                  context);
                                                            }
                                                          } catch (e) {}
                                                        } else {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Total Error',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontFamily:
                                                                            Font_.Fonts_T))),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    cursorColor: Colors.green,
                                                    decoration: InputDecoration(
                                                        fillColor: Colors.white
                                                            .withOpacity(0.3),
                                                        filled: true,
                                                        // prefixIcon: const Icon(Icons.water,
                                                        //     color: Colors.blue),
                                                        // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                        focusedBorder:
                                                            const OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    15),
                                                            topLeft:
                                                                Radius.circular(
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
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        enabledBorder:
                                                            const OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topRight:
                                                                Radius.circular(
                                                                    15),
                                                            topLeft:
                                                                Radius.circular(
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
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                        labelText: 'Total',
                                                        labelStyle:
                                                            const TextStyle(
                                                          color:
                                                              ManageScreen_Color
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
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        width: 150,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius: BorderRadius.only(
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
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                              SharedPreferences
                                                                  preferences =
                                                                  await SharedPreferences
                                                                      .getInstance();
                                                              var ren = preferences
                                                                  .getString(
                                                                      'renTalSer');
                                                              var user =
                                                                  preferences
                                                                      .getString(
                                                                          'ser');

                                                              var sertran =
                                                                  _TransModels[
                                                                          index]
                                                                      .ser;
                                                              var vel =
                                                                  Formposlokdispri_
                                                                      .text
                                                                      .trim();
                                                              if (double.parse(
                                                                      vel) <=
                                                                  double.parse(
                                                                      _TransModels[
                                                                              index]
                                                                          .total!)) {
                                                                // print('vel>>>>$vel');
                                                                String url =
                                                                    '${MyConstant().domain}/c_trans_select_dis_cn.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';

                                                                try {
                                                                  var response =
                                                                      await http.get(
                                                                          Uri.parse(
                                                                              url));

                                                                  var result =
                                                                      json.decode(
                                                                          response
                                                                              .body);
                                                                  // print(result);
                                                                  if (result
                                                                          .toString() ==
                                                                      'true') {
                                                                    setState(
                                                                        () {
                                                                      red_Trans_CN();
                                                                      Formposlokdispri_
                                                                          .clear();
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      Formposlokdispri_
                                                                          .clear();
                                                                    });

                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                } catch (e) {}
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                      content: Text(
                                                                          'Total Error',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontFamily: Font_.Fonts_T))),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Submit',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T),
                                                          ),
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
                                    );
                                  },
                                  panaraDialogType: PanaraDialogType.warning,
                                );
                              }
                            },
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    dis_bill == 1 ? '${index + 1}' : '',
                                    // '${index + 1}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    dis_bill == 1
                                        ? '${_TransModels[index].refno!}'
                                        : '',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${_TransModels[index].name}',
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                // Expanded(
                                //   flex: 1,
                                //   child: AutoSizeText(
                                //     minFontSize: 10,
                                //     maxFontSize: 15,
                                //     maxLines: 1,
                                //     '${_TransReBillHistoryModels[index].vtype}',
                                //     textAlign: TextAlign.center,
                                //     overflow: TextOverflow.ellipsis,
                                //     style: const TextStyle(
                                //         color: PeopleChaoScreen_Color.Colors_Text2_,
                                //         //fontWeight: FontWeight.bold,
                                //         fontFamily: Font_.Fonts_T),
                                //   ),
                                // ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AutoSizeText(
                                        minFontSize: 4,
                                        maxFontSize: 10,
                                        maxLines: 1,
                                        '${nFormat.format(double.parse(_TransModels[index].ocost!) == 0 ? double.parse(_TransModels[index].amt!) : double.parse(_TransModels[index].ocost!))} ( ${_TransModels[index].vtype} )',
                                        // '${_TransReBillHistoryModels[index].nvat}',
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                      AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 15,
                                        maxLines: 1,

                                        '${nFormat.format(double.parse(_TransModels[index].pvat!))}',
                                        // '${_TransReBillHistoryModels[index].nvat}',
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            //fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    dis_bill == 1
                                        ? '${nFormat.format(double.parse(_TransModels[index].nvat!))}'
                                        : '',
                                    // '${_TransReBillHistoryModels[index].nvat}',
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,

                                    '${nFormat.format(double.parse(_TransModels[index].vat!))}',
                                    // '${_TransReBillHistoryModels[index].nvat}',
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    dis_bill == 1
                                        ? '${nFormat.format(double.parse(_TransModels[index].nwht!))}'
                                        : '',
                                    // '${_TransReBillHistoryModels[index].wht}',
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,

                                    '${nFormat.format(double.parse(_TransModels[index].wht!))}',
                                    // '${_TransReBillHistoryModels[index].wht}',
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 10,
                                    maxFontSize: 15,
                                    maxLines: 1,
                                    '${nFormat.format(double.parse(_TransModels[index].total!))}',
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            Container(
                width: (Responsive.isDesktop(context))
                    ? MediaQuery.of(context).size.width * 0.52
                    : 900,
                decoration: const BoxDecoration(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                ),
                child: Column(
                  children: [
                    dtypeselect == '!Z'
                        ? SizedBox()
                        : _TransReBillHistoryModels.length == 0
                            ? SizedBox()
                            : Column(
                                children: [
                                  Divider(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 8, left: 8, right: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _TransReBillHistoryModels
                                                      .length ==
                                                  0
                                              ? SizedBox()
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        discount_page = 0;
                                                        dis_bill = 0;
                                                      });
                                                    },
                                                    child: Container(
                                                        height: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .orange.shade900,
                                                          borderRadius: BorderRadius.only(
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
                                                          // border: Border.all(color: Colors.white, width: 1),
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Center(
                                                            child: Text(
                                                          'ยกเลิกทำรายการลดหนี้',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T),
                                                        ))),
                                                  ),
                                                ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: SizedBox(),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () {
                                                if (_TransModels.isNotEmpty) {
                                                  de_Trans_CN('0');
                                                }
                                                setState(() {
                                                  if (dis_bill == 1) {
                                                    dis_bill = 0;
                                                  } else {
                                                    dis_bill = 1;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: dis_bill == 1
                                                        ? Colors.purple.shade900
                                                        : Colors.grey.shade500,
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
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Text(
                                                    'ลดหนี้บางรายการ',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: FontWeight_
                                                            .Fonts_T),
                                                  ))),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: InkWell(
                                              onTap: () {
                                                if (_TransModels.isNotEmpty) {
                                                  de_Trans_CN('0');
                                                }

                                                setState(() {
                                                  if (dis_bill == 2) {
                                                    dis_bill = 0;
                                                  } else {
                                                    dis_bill = 2;
                                                    var docno_se =
                                                        numdoctax == ''
                                                            ? numinvoice
                                                            : numdoctax;

                                                    in_dis_select(
                                                        docno_se!, dis_bill);
                                                  }
                                                });
                                              },
                                              child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: dis_bill == 2
                                                        ? Colors.green.shade900
                                                        : Colors.grey.shade500,
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
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Text(
                                                    'ลดหนี้ทั้งบิล',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: FontWeight_
                                                            .Fonts_T),
                                                  ))),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                    dtypeselect == '!Z'
                        ? SizedBox()
                        : _TransReBillHistoryModels.length == 0
                            ? SizedBox()
                            : Padding(
                                padding: EdgeInsets.only(
                                    left: 8, right: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 4,
                                                  child: Remark_ == ''
                                                      ? SizedBox()
                                                      : Text(
                                                          'หมายเหตุ : $Remark_',
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.orange,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        )),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  'รวม(บาท)',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  round_p == '1'
                                                      ? '${nFormat.format(sum_pvat_up)}'
                                                      : '${nFormat.format(sum_pvat)}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    rental_ser != '106'
                                                        ? SizedBox()
                                                        : IconButton(
                                                            onPressed:
                                                                () async {
                                                              // print(_TransReBillModels[
                                                              //         index]
                                                              //     .docno);
                                                              if (renTal_lavel >
                                                                  3) {
                                                                if (rental_degree_up ==
                                                                    '1') {
                                                                  new_dereee
                                                                      .text = round_p ==
                                                                          '1'
                                                                      ? sum_pvat_up
                                                                          .toString()
                                                                          .substring(sum_pvat_up.toString().indexOf('.') +
                                                                              1)
                                                                      : sum_pvat
                                                                          .toString()
                                                                          .substring(sum_pvat.toString().indexOf('.') +
                                                                              1);
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder: (context) => AlertDialog(
                                                                        title: Center(
                                                                          child:
                                                                              Text(
                                                                            'ปรับจุดทศนิยม',
                                                                            maxLines:
                                                                                1,
                                                                            textAlign:
                                                                                TextAlign.start,
                                                                            style: const TextStyle(
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                                fontSize: 20),
                                                                          ),
                                                                        ),
                                                                        content: Stack(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          children: <Widget>[
                                                                            Container(
                                                                                width: 250,
                                                                                decoration: const BoxDecoration(
                                                                                  // color: Colors.black,
                                                                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                ),
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      flex: 3,
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          Padding(
                                                                                            padding: const EdgeInsets.all(8.0),
                                                                                            child: Text(
                                                                                              round_p == '1' ? '${sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1)}' : '${sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1)}',
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    Expanded(
                                                                                      flex: 2,
                                                                                      child: TextFormField(
                                                                                        //keyboardType: TextInputType.none,
                                                                                        controller: new_dereee,
                                                                                        // onChanged: (value) => value.trim(),
                                                                                        onFieldSubmitted: (value) async {
                                                                                          var new_amt = round_p == '1' ? sum_pvat_up.toString().substring(0, sum_pvat_up.toString().indexOf('.') + 1) + value : sum_pvat.toString().substring(0, sum_pvat.toString().indexOf('.') + 1) + value;

                                                                                          print(docnoin_up);
                                                                                          SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                          var ren = preferences.getString('renTalSer');
                                                                                          var docno = docnoin_up;
                                                                                          var sum_amt_up = double.parse(new_amt);
                                                                                          var sum_vat_up = double.parse(new_amt.toString()) * 7 / 100;

                                                                                          String url = '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                                                          try {
                                                                                            var response = await http.get(Uri.parse(url));

                                                                                            var result = json.decode(response.body);
                                                                                            if (result.toString() == 'true') {
                                                                                              setState(() {
                                                                                                red_Trans_select_up();
                                                                                                red_Invoice_up();

                                                                                                // Form_payment1.text = (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum).toStringAsFixed(2).toString();
                                                                                              });
                                                                                            }
                                                                                          } catch (e) {}

                                                                                          Navigator.pop(context, 'OK');
                                                                                        },
                                                                                        // maxLength: 13,
                                                                                        cursorColor: Colors.green,
                                                                                        decoration: InputDecoration(
                                                                                          fillColor: Colors.white.withOpacity(0.3),
                                                                                          filled: true,
                                                                                          // prefixIcon: const Icon(Icons.person, color: Colors.black),
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
                                                                                          errorStyle: TextStyle(fontFamily: Font_.Fonts_T),
                                                                                          enabledBorder: const OutlineInputBorder(
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
                                                                                          // labelText: 'USERNAME',
                                                                                          labelStyle: const TextStyle(
                                                                                            fontSize: 14,
                                                                                            color: Colors.black54,
                                                                                            fontFamily: Font_.Fonts_T,
                                                                                          ),
                                                                                        ),
                                                                                        inputFormatters: <TextInputFormatter>[
                                                                                          //   // for below version 2 use this
                                                                                          //   FilteringTextInputFormatter(RegExp("[a-zA-Z1-9@.]"),
                                                                                          //       allow: true),
                                                                                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                                                                          //for version 2 and greater youcan also use this
                                                                                          FilteringTextInputFormatter.digitsOnly
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                ))
                                                                          ],
                                                                        ),
                                                                        actions: <Widget>[
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(8.0),
                                                                                child: Container(
                                                                                  width: 100,
                                                                                  decoration: const BoxDecoration(
                                                                                    color: Colors.black,
                                                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                  ),
                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                  child: TextButton(
                                                                                    onPressed: () => Navigator.pop(context, 'OK'),
                                                                                    child: Translate.TranslateAndSetText('ปิด', Colors.white, TextAlign.start, FontWeight.bold, FontWeight_.Fonts_T, 14, 1),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ]),
                                                                  );
                                                                } else if (rental_degree_up ==
                                                                    '2') {
                                                                  print(
                                                                      docnoin_up);
                                                                  SharedPreferences
                                                                      preferences =
                                                                      await SharedPreferences
                                                                          .getInstance();
                                                                  var ren = preferences
                                                                      .getString(
                                                                          'renTalSer');
                                                                  var docno =
                                                                      docnoin_up;
                                                                  var sum_amt_up = round_p ==
                                                                          '1'
                                                                      ? sum_pvat_up
                                                                          .toPrecision(
                                                                              1)
                                                                      : sum_pvat
                                                                          .toPrecision(
                                                                              1);
                                                                  var sum_vat_up = round_p ==
                                                                          '1'
                                                                      ? sum_pvat_up.toPrecision(
                                                                              1) *
                                                                          7 /
                                                                          100
                                                                      : sum_pvat
                                                                              .toPrecision(1) *
                                                                          7 /
                                                                          100;

                                                                  String url =
                                                                      '${MyConstant().domain}/Up_degree.php?isAdd=true&ren=$ren&docno=$docno&sum_vat_up=$sum_vat_up&sum_amt_up=$sum_amt_up';
                                                                  try {
                                                                    var response =
                                                                        await http
                                                                            .get(Uri.parse(url));

                                                                    var result =
                                                                        json.decode(
                                                                            response.body);
                                                                    if (result
                                                                            .toString() ==
                                                                        'true') {
                                                                      setState(
                                                                          () {
                                                                        red_Trans_select_up();
                                                                        red_Invoice_up();
                                                                      });
                                                                    }
                                                                  } catch (e) {}
                                                                }
                                                              } else {
                                                                Dialog_updegree();
                                                              }
                                                            },
                                                            icon: Icon(
                                                              Icons.unfold_more,
                                                            ),
                                                          ),
                                                    Text(
                                                      'บาท',
                                                      textAlign: TextAlign.end,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          // fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  'ภาษีมูลค่าเพิ่ม(vat)',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  round_p == '1'
                                                      ? '${nFormat.format(sum_vat_up)}'
                                                      : '${nFormat.format(sum_vat)}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'บาท',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  'หัก ณ ที่จ่าย',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${nFormat.format(sum_wht)}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'บาท',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  'ยอดรวม',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  '${nFormat.format(sum_amt)}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'บาท',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      'ส่วนลด',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text1_,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T
                                                          //fontSize: 10.0
                                                          ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      '$sum_disp  %',
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
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
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'บาท',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          total_amt == 0.00
                                              ? SizedBox()
                                              : Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        'หักชำระ',
                                                        textAlign:
                                                            TextAlign.start,
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
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        '${nFormat.format(total_amt)}',
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
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        'บาท',
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
                                                  ],
                                                ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  'ยอดชำระรวม',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  // '${nFormat.format(sum_amt - sum_disamt)}',
                                                  '${nFormat.format(sum_amt - sum_disamt - total_amt)}',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  'บาท',
                                                  textAlign: TextAlign.end,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      // fontWeight: FontWeight.bold,
                                                      fontFamily: Font_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'รูปแบบการชำระ',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          FontWeight_.Fonts_T
                                                      //fontSize: 10.0
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    for (var i = 0;
                                                        i <
                                                            finnancetransModels
                                                                .length;
                                                        i++)
                                                      finnancetransModels[i]
                                                                  .dtype ==
                                                              'KP'
                                                          ? AutoSizeText(
                                                              minFontSize: 10,
                                                              maxFontSize: 15,
                                                              finnancetransModels[
                                                                              i]
                                                                          .type ==
                                                                      'CASH'
                                                                  ? '${finnancetransModels[i].type} (เงินสด)'
                                                                  : '${finnancetransModels[i].type} (เงินโอน)',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                            )
                                                          : AutoSizeText(
                                                              minFontSize: 10,
                                                              maxFontSize: 15,
                                                              '${finnancetransModels[i].remark}',
                                                              textAlign:
                                                                  TextAlign.end,
                                                              style: TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                            ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          for (var i = 0;
                                              i < finnancetransModels.length;
                                              i++)
                                            Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    textAlign: TextAlign.start,
                                                    nFormat.format(sum_amt -
                                                                sum_disamt -
                                                                total_amt) ==
                                                            nFormat.format(
                                                                double.parse(
                                                                    finnancetransModels[
                                                                            i]
                                                                        .amt!))
                                                        ? ''
                                                        : 'ยอดรับชำระไม่กับยอดชำระ',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        //fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    textAlign: TextAlign.end,
                                                    'จำนวน',
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
                                                  child: AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    '${nFormat.format(double.parse(finnancetransModels[i].amt!))}',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color: nFormat.format(sum_amt -
                                                                    sum_disamt -
                                                                    total_amt) ==
                                                                nFormat.format(
                                                                    double.parse(
                                                                        finnancetransModels[i]
                                                                            .amt!))
                                                            ? PeopleChaoScreen_Color
                                                                .Colors_Text2_
                                                            : Colors.red,
                                                        //fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'บาท',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text1_,
                                                        // fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T
                                                        //fontSize: 10.0
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    dis_bill == 0
                                        ? SizedBox()
                                        : Expanded(
                                            flex: 4,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Container(
                                                height: 280,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 4,
                                                            child: SizedBox()),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '',
                                                            textAlign:
                                                                TextAlign.end,
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
                                                      ],
                                                    ),
                                                    // Divider(),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            'รวม(บาท)',
                                                            textAlign:
                                                                TextAlign.start,
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
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${nFormat.format(sum_pvat_cn)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'บาท',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            'ภาษีมูลค่าเพิ่ม(vat)',
                                                            textAlign:
                                                                TextAlign.start,
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
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${nFormat.format(sum_vat_cn)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'บาท',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            'หัก ณ ที่จ่าย',
                                                            textAlign:
                                                                TextAlign.start,
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
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${nFormat.format(sum_wht_cn)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'บาท',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            'ยอดรวม',
                                                            textAlign:
                                                                TextAlign.start,
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
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${nFormat.format(sum_amt_cn)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'บาท',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                'ส่วนลด',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
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
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                '$sum_disp_cn  %',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text1_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily: FontWeight_.Fonts_T
                                                                    //fontSize: 10.0
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            '${nFormat.format(sum_disamt_cn)}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'บาท',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                            'ยอดบิลรวม(ลดหนี้)',
                                                            textAlign:
                                                                TextAlign.start,
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
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            // '${nFormat.format(sum_amt - sum_disamt)}',
                                                            '${nFormat.format((sum_Total_cn))}',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .green,
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
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'บาท',
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                                color: PeopleChaoScreen_Color
                                                                    .Colors_Text1_,
                                                                // fontWeight: FontWeight.bold,
                                                                fontFamily:
                                                                    Font_
                                                                        .Fonts_T
                                                                //fontSize: 10.0
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            '',
                                                            textAlign:
                                                                TextAlign.start,
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
                                                        Expanded(
                                                          flex: 4,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: InkWell(
                                                              onTap: () {
                                                                List
                                                                    newValuePDFimg =
                                                                    [];
                                                                if (renTalModels[
                                                                            0]
                                                                        .imglogo!
                                                                        .trim() ==
                                                                    '') {
                                                                } else {
                                                                  newValuePDFimg
                                                                      .add(
                                                                          '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}');
                                                                }
                                                                in_Trans_invoice_dis(
                                                                    newValuePDFimg);
                                                              },
                                                              child: Container(
                                                                  height: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .blue
                                                                        .shade900,
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
                                                                            Radius.circular(10)),
                                                                    // border: Border.all(color: Colors.white, width: 1),
                                                                  ),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    'ยืนยันการทำรายการ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T),
                                                                  ))),
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
                                  ],
                                ),
                              )
                  ],
                ))
          ])),
    );
  }

  Future<Null> in_Trans_invoice_dis(newValuePDFimg) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var renTal_name = preferences.getString('renTalName');
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = dis_bill;
    var sumdis = '0';
    var sumdisp = '0';
    var c_payment_Ser = '0';
    String? inv_num_, docno_inv_;

    String url =
        '${MyConstant().domain}/In_tran_invoice_dis.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&pay_Ser1=$c_payment_Ser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print('result>In_tran_invoice_dis>>> $result');
      if (result.toString() != 'No') {
        for (var map in result) {
          InvoiceModel InvoiceModels = InvoiceModel.fromJson(map);
          setState(() {
            inv_num_ = InvoiceModels.inv;
            docno_inv_ = InvoiceModels.docno;
            _InvoiceModels.clear();
            _InvoiceHistoryModels.clear();
            _TransReBillHistoryModels.clear();
            numinvoice = null;
            numdoctax = null;
            selece_bill = 1;
            discount_page = 0;
            dis_bill = 0;
            sum_pvat = 0.00;
            sum_vat = 0.00;
            sum_wht = 0.00;
            sum_amt = 0.00;
            sum_dis = 0.00;
            sum_disamt = 0.00;
            sum_disp = 0;
            select_page = 0;
            red_Trans_bill();
          });
          print('zzzzasaaa123454>>>>  $inv_num_ ');
          print('docnodocnodocnodocnodocno123456>>>>  ${docno_inv_}');

          Insert_log.Insert_logs('ลดหนี้',
              'ทำรายการใบลดหนี้:${InvoiceModels.inv} > ${InvoiceModels.docno} ยืนยันทำใบลดหนี้');
        }
        /////////------------------------------------>
        Insert_log.Insert_logs(
            'ผู้เช่า', 'ใบลดหนี้>>บันทึก(${docno_inv_.toString()})');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('บันทึกรายการใบลดหนี้สำเร็จ',
                  style: TextStyle(
                      color: Colors.white, fontFamily: Font_.Fonts_T))),
        );
      }
    } catch (e) {}
  }

  Future<Null> in_dis_select(String docno_se, int dis_bill) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = dis_bill.toString();
    var tdocno = docno_se;
    String url =
        '${MyConstant().domain}/In_dis_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tdocno=$tdocno&user=$user';
    print('url $qutser >> $docno_se');
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('rr>>>>>> $result');
      if (result.toString() == 'true') {
        // setState(() {
        red_Trans_CN();
        // });
      }
    } catch (e) {}
  }

  Future<Null> edit_Trans_CN(String tran_ser) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = tran_ser;

    String url =
        '${MyConstant().domain}/De_trans_select_CN.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&user=$user&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_CN();
        });
      }
    } catch (e) {}
  }

  Future<Null> de_Trans_CN(String tran_ser) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = tran_ser;

    String url =
        '${MyConstant().domain}/De_trans_select_CN.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&user=$user&qutser=$qutser';
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_CN();
        });
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_CN() async {
    if (_TransModels.isNotEmpty) {
      setState(() {
        _TransModels.clear();
        sum_pvat_cn = 0;
        sum_vat_cn = 0;
        sum_wht_cn = 0;
        sum_amt_cn = 0;
        sum_Total_cn = 0;
        sum_disamt_cn = 0;
        sum_disp_cn = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = '';

    String url =
        '${MyConstant().domain}/GC_tran_select_CN.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc'; //GC_tran_select_fin
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        setState(() {
          _TransModels.clear();
          sum_amt_cn = 0;
        });
        for (var map in result) {
          TransModel _TransModel = TransModel.fromJson(map);

          var sum_pvatx = double.parse(_TransModel.pvat!);
          var sum_vatxx = double.parse(_TransModel.vat!);
          var sum_whtx = double.parse(_TransModel.wht!);
          var sum_amtxx = double.parse(_TransModel.total!);
          var discountxx = double.parse(_TransModel.discount!);
          var disendbillxx = double.parse(_TransModel.disendbill!);
          var disxx = double.parse(_TransModel.dis!);

          setState(() {
            sum_pvat_cn = sum_pvat_cn + sum_pvatx;
            sum_vat_cn = sum_vat_cn + sum_vatxx;
            sum_wht_cn = sum_wht_cn + sum_whtx;
            sum_amt_cn = sum_amt_cn + sum_amtxx;
            sum_disamt_cn = sum_disamt_cn + disendbillxx + disxx;
            sum_disp_cn = discountxx;
            // sum_Total_cn = sum_amt_cn + sum_amtxx;
            _TransModels.add(_TransModel);
          });
        }
      }
    } catch (e) {}

    setState(() {
      sum_Total_cn = sum_amt_cn - sum_disamt_cn;
    });
    print('sum_amt_cn >>> $sum_amt_cn');
  }

  Dialog_updegree() async {
    PanaraInfoDialog.showAnimatedGrow(
      context,
      title: "Oops",
      message: "User ของท่านไม่สามารถทำการปรับจุดทศนิยมได้ !!",
      buttonText: "รับทราบ",
      onTapDismiss: () async {
        Navigator.pop(context);
      },
      panaraDialogType: PanaraDialogType.error,
      barrierDismissible: false,
    );
  }

  Future<Null> pPC_finantIbillREbill() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    // var ciddoc = widget.Get_Value_cid;
    // var qutser = widget.Get_Value_NameShop_index;

    var numin = numinvoice;
    print('>>>zzzz>>>>>> $numin');

    String url =
        '${MyConstant().domain}/UPC_finant_billREbill.php?isAdd=true&ren=$ren&user=$user&numin=$numin';
    print(url);
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result.toString() != 'No') {
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
          red_Trans_bill();
          finnancetransModels.clear();
        });
        print('rrrrrrrrrrrrrr');
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
    try {
      var response = await http.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
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
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ////////////------------------------------------------------------>(Export file)
  Future<void> showMyDialog_SAVE(
      tableData00, newValuePDFimg, room_number_BillHistory) async {
    String _ReportValue_type = "ไม่ระบุ";
    String _verticalGroupValue_NameFile = "จากระบบ";
    String Value_Report = ' ';
    String NameFile_ = '';
    String Pre_and_Dow = '';
    String? TitleType_Default_Receipt_Name;
    final _formKey = GlobalKey<FormState>();
    final FormNameFile_text = TextEditingController();
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
                  child: ListBody(
                    children: <Widget>[
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
                          items: const <String>[
                            'ไม่ระบุ',
                            'ต้นฉบับ',
                            'คู่ฉบับ',
                            'สำเนา',
                            'สำเนาคู่ฉบับ',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            if (Receipt_type == 'Credit_Note') {
                              Receipt_Credit_Notebill(
                                  tableData00,
                                  newValuePDFimg,
                                  room_number_BillHistory,
                                  TitleType_Default_Receipt_Name);
                            } else {
                              Receipt_his_statusbill(
                                  tableData00,
                                  newValuePDFimg,
                                  room_number_BillHistory,
                                  TitleType_Default_Receipt_Name);
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
                            child: Center(
                              child: Text(
                                'พิมพ์',
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
    Future.delayed(Duration(milliseconds: 500), () async {
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

  //////////////-------------------------------------------------------------> ( รายการประวัติบิล ใบลดหนี้)
  Future<Null> Receipt_Credit_Notebill(tableData00, newValuePDFimg,
      room_number_BillHistory, TitleType_Default_Receipt_Name) async {
    var date_Transaction = (finnancetransModels.length == 0)
        ? ''
        : '${finnancetransModels[0].daterec}';
    var date_pay = (finnancetransModels.length == 0)
        ? ''
        : '${finnancetransModels[0].dateacc}';
    var cFinn_S = (numinvoice != '') ? numinvoice : numdoctax;
    Navigator.pop(context, 'OK');
    Future.delayed(Duration(milliseconds: 500), () async {
      ManCredit_Note_PDF.Man_creditnote_PDF(
          '${cFinn_S}',
          '${reduce_bill_doc}',
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
}
