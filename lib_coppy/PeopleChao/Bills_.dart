// ignore_for_file: unused_import, unused_local_variable, unnecessary_null_comparison, unused_field, override_on_non_overriding_member, duplicate_import, must_be_immutable, body_might_complete_normally_nullable
import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:chaoperty_floating_loader/chaoperty_floating_loader.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Constant/Myconstant.dart';
import '../Constant/global_http.dart';
import '../INSERT_Log/Insert_log.dart';
import '../Man_PDF/Man_BillingNoteInvlice_PDF.dart';
import '../Model/GetCFinnancetrans_Model.dart';
import '../Model/GetContractx_Fine_Model.dart';
import '../Model/GetExp_Model.dart';
import '../Model/GetPayMent_Model.dart';
import '../Model/GetRenTal_Model.dart';
import '../Model/GetTeNant_Model.dart';
import '../Model/GetTranBill_model.dart';
import '../Model/GetTrans_Model.dart';
import '../Model/GetTrans_fine_Model.dart';
import '../Model/GetVocher_Model.dart';
import '../PDF/PDF_Billing/pdf_BillingNote_IV.dart';
import '../PDF_TP2/PDF_Billing_TP2/pdf_BillingNote_IV_TP2.dart';
import '../PDF_TP3/PDF_Billing_TP3/pdf_BillingNote_IV_TP3.dart';
import '../PDF_TP4/PDF_Billing_TP4/pdf_BillingNote_IV_TP4.dart';
import '../PDF_TP5/PDF_Billing_TP5/pdf_BillingNote_IV_TP5.dart';

import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import '../main.dart';
import 'Bills_history.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class Bills extends StatefulWidget {
  final Get_Value_NameShop_index;
  final Get_Value_cid;
  final namenew;
  final sname_;
  final addr_;
  final tel_;
  final email_;
  final tax_;
  final cname_;
  const Bills({
    super.key,
    this.Get_Value_NameShop_index,
    this.Get_Value_cid,
    this.namenew,
    this.sname_,
    this.addr_,
    this.tel_,
    this.email_,
    this.tax_,
    this.cname_,
  });

  @override
  State<Bills> createState() => _BillsState();
}

class _BillsState extends State<Bills> {
  DateTime newDatetime = DateTime.now();
  var nFormat = NumberFormat("#,##0.00", "en_US");
  var End_Bill_Paydate;

  @override
  ScrollController _scrollController1 = ScrollController();
  ScrollController _scrollController2 = ScrollController();
  List<TransBillModel> _TransBillModels = [];
  List<ContractxFineModel> contractxFineModels = [];
  List<TransModel> _TransModels = [];
  List<TeNantModel> teNantModels = [];
  List<RenTalModel> renTalModels = [];
  List<PayMentModel> _PayMentModels = [];
  List<TransFineModel> transFineModels = [];
  List<VocherModel> _VocherModels = [];

  List<ExpModel> expModels = [];
  final sum_disamt = TextEditingController();
  final sum_disp = TextEditingController();
  final text_add = TextEditingController();
  final price_add = TextEditingController();
  final Formpasslok_ = TextEditingController();
  final Formposlok_ = TextEditingController();
  final Formposlokpri_ = TextEditingController();
  final Formposlokdispri_ = TextEditingController();
  final Formterm_ = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_tran_fine = 0,
      sum_tran_fine_amt = 0,
      fine_total = 0,
      fine_total2 = 0,
      sum_tran_fine_vat = 0,
      sum_tran_dis = 0,
      sum_matjum = 0.00,
      sum_vat_list = 0;
  double? total_dislist = 0;
  int indexbill = 0, select_meter = 0, open_dislis = 0;
  String? numinvoice;
  String? Form_nameshop,
      Form_typeshop,
      Form_bussshop,
      Form_bussscontact,
      Form_address,
      Form_tel,
      Form_email,
      Form_tax,
      rental_count_text,
      Form_area,
      Form_ln,
      Form_sdate,
      Form_ldate,
      Form_period,
      Form_rtname,
      Form_docno,
      Form_zn,
      Form_aser,
      Form_qty;
  String? rtname, type, typex, renname, pkname, ser_Zonex, ser_vocher;
  int? pkqty, pkuser, countarae;
  String? base64_Imgmap, foder;
  String? tel_user, img_, img_logo, tem_page_ser;
  String? selectedValue;
  String? paymentSer1, paymentName1, paymentSer2, paymentName2;
  int TitleType_Default_Receipt = 0;
  List TitleType_Default_Receipt_ = [
    'ไม่ระบุ',
    'ต้นฉบับ',
    'สำเนา',
  ];
  // Networking
  late final Dio _dio;
  final CancelToken _cancelToken =
      CancelToken(); // ยกเลิกทุก request ตอน dispose
  // ===== =====
  bool _tapBusy = false;
  bool _dialogOpen = false;
  bool _dialogRefresh = false;
// ================== lifecycle ==================
  @override
  void initState() {
    _dio = Dio(BaseOptions(
      baseUrl: MyConstant().domain,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
      // ให้เราตรวจจับ 4xx/5xx เอง (จะไม่ throw อัตโนมัติ)
      validateStatus: (code) => code != null && code >= 200 && code < 500,
    ))
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            final auth = Security.generateAuthHeaders();
            options.headers.addAll(auth);
            // options.headers['Content-Type'] ??= 'application/json';
            return handler.next(options);
          },
        ),
      );
    End_Bill_Paydate = DateFormat('yyyy-MM-dd').format(newDatetime);
    super.initState();
    red_Trans_bill();
    red_Trans_select();
    sum_disamt.text = '0.00';
    read_data();
    read_GC_rental();
    red_payMent();
    read_GC_Exp();
    read_GC_fine();
    red_Vocher();
  }

  @override
  void dispose() {
    // ยกเลิก request ค้าง (กัน callback หลังถูก dispose)
    if (!_cancelToken.isCancelled) {
      _cancelToken.cancel('dispose');
    }

    // เคลียร์ controllers กัน memory leak

    Formposlok_.dispose();

    super.dispose();
  }

  Future<Null> red_Vocher() async {
    if (_VocherModels.length != 0) {
      setState(() {
        _VocherModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_Voucher.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          VocherModel _VocherModel = VocherModel.fromJson(map);
          setState(() {
            _VocherModels.add(_VocherModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> read_GC_fine() async {
    if (contractxFineModels.isNotEmpty) {
      setState(() {
        contractxFineModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = 1;

    String url =
        '${MyConstant().domain}/GC_fine.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

      if (result.toString() != 'true') {
        for (var map in result) {
          ContractxFineModel contractxFineModel =
              ContractxFineModel.fromJson(map);

          setState(() {
            contractxFineModels.add(contractxFineModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> read_GC_Exp() async {
    if (expModels.isNotEmpty) {
      setState(() {
        expModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');

    String url =
        '${MyConstant().domain}/GC_exp_setring.php?isAdd=true&ren=$ren';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
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

  Future<Null> red_payMent() async {
    if (_PayMentModels.length != 0) {
      setState(() {
        _PayMentModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren}';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
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

        PayMentModel _PayMentModel = PayMentModel.fromJson(map);
        setState(() {
          _PayMentModels.add(_PayMentModel);
        });

        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var serx = _PayMentModel.ser;
          var ptnamex = _PayMentModel.ptname;
          setState(() {
            _PayMentModels.add(_PayMentModel);
            if (autox == '1') {
              paymentSer1 = serx.toString();
              paymentName1 = ptnamex.toString();
            }
          });
          if (_PayMentModel.btser.toString() == '1') {
          } else {}
        }

        if (paymentName1 == null) {
          paymentSer1 = 0.toString();
          paymentName1 = 'เลือก'.toString();
        }
      }
    } catch (e) {}
  }

  Future<Null> read_GC_rental() async {
    if (renTalModels.isNotEmpty) {
      renTalModels.clear();
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    // var seruser = preferences.getString('ser');
    // var utype = preferences.getString('utype');
    // String url =
    //     '${MyConstant().domain}/GC_rental.php?isAdd=true&ser=$seruser&type=$utype';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);
          var rtnamex = renTalModel.rtname;
          var typexs = renTalModel.type;
          var typexx = renTalModel.typex;
          var name = renTalModel.pn!.trim();
          var pkqtyx = int.parse(renTalModel.pkqty!);
          var pkuserx = int.parse(renTalModel.pkuser!);
          var open_dislisx = int.parse(renTalModel.open_dislis!);
          var pkx = renTalModel.pk!.trim();
          var foderx = renTalModel.dbn;
          var img = renTalModel.img;
          var imglogo = renTalModel.imglogo;
          setState(() {
            foder = foderx;
            rtname = rtnamex;
            type = typexs;
            typex = typexx;
            renname = name;
            pkqty = pkqtyx;
            pkuser = pkuserx;
            pkname = pkx;
            img_ = img;
            img_logo = imglogo;
            open_dislis = open_dislisx;
            tem_page_ser = renTalModel.tem_page!.trim();
            renTalModels.add(renTalModel);
          });
        }
      } else {}
    } catch (e) {}
    print('name>>>>>  $renname');
  }
  // Future<Null> read_GC_rental() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();

  //   var seruser = preferences.getString('ser');
  //   var utype = preferences.getString('utype');
  //   String url =
  //       '${MyConstant().domain}/GC_rental.php?isAdd=true&ser=$seruser&type=$utype';

  //   try {
  //     var response = await httpClient.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     print('read_GC_rental///// $result');
  //     for (var map in result) {
  //       RenTalModel renTalModel = RenTalModel.fromJson(map);
  //       setState(() {
  //         renTalModels.add(renTalModel);
  //       });
  //     }
  //   } catch (e) {}
  // }

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
      var response = await httpClient.get(Uri.parse(url));

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
            Form_area = teNantModel.area.toString();
            Form_ln = teNantModel.area_c.toString();

            Form_sdate = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.sdate} 00:00:00'))
                .toString();
            Form_ldate = DateFormat('dd-MM-yyyy')
                .format(DateTime.parse('${teNantModel.ldate} 00:00:00'))
                .toString();
            Form_period = teNantModel.period.toString();
            Form_rtname = teNantModel.rtname.toString();
            Form_docno = teNantModel.docno.toString();
            Form_zn = teNantModel.zn.toString();
            Form_aser = teNantModel.aser.toString();
            Form_qty = teNantModel.qty.toString();
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_select() async {
    setState(() {
      _TransModels.clear();
      sum_pvat = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
      sum_tran_dis = 0;
      sum_matjum = 0;
      sum_vat_list = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;

    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        setState(() {
          _TransModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_tran_dis = 0;
          sum_vat_list = 0;
        });
        for (var map in result) {
          TransModel _TransModel = TransModel.fromJson(map);

          var sum_pvatx = double.parse(_TransModel.pvat!);
          var sum_vatxx = double.parse(_TransModel.vat!);
          var sum_whtx = double.parse(_TransModel.wht!);
          var sum_amtxx = double.parse(_TransModel.total!);
          var sum_disx = double.parse(_TransModel.dis!);
          var sum_amtx = double.parse(_TransModel.total_dis!);
          var sum_vatx = double.parse(_TransModel.dis!) == 0
              ? double.parse(_TransModel.vat!)
              : double.parse(_TransModel.vat_dislit!);
          setState(() {
            sum_vat_list = sum_vat_list + sum_vatxx;
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx - sum_disx;
            sum_tran_dis = sum_tran_dis + sum_disx;
            _TransModels.add(_TransModel);
          });
        }
      }
    } catch (e) {}
    setState(() {
      red_Trans_select2_fin();
    });
  }

  Future<Null> red_Trans_select2_fin() async {
    if (transFineModels.isNotEmpty) {
      setState(() {
        transFineModels.clear();
        sum_tran_fine = 0;
        sum_tran_fine_amt = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tran_select_fin.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        transFineModels.clear();
        sum_tran_fine = 0;
        sum_tran_fine_vat = 0;
        sum_tran_fine_amt = 0;
        for (var map in result) {
          TransFineModel transFineModel = TransFineModel.fromJson(map);

          var sum_totalx = double.parse(transFineModel.total!);
          var sump_pvatx = double.parse(transFineModel.pvat!);
          var sump_vatx = double.parse(transFineModel.vat!);
          setState(() {
            sum_pvat = sum_pvat + sump_pvatx;
            sum_vat = sum_vat + sump_vatx;
            sum_amt = sum_amt + sum_totalx;
            sum_tran_fine_vat = sum_tran_fine_vat + sump_vatx;
            sum_tran_fine_amt = sum_tran_fine_amt + sum_totalx;
            sum_tran_fine = sum_tran_fine + sum_totalx;
            transFineModels.add(transFineModel);
          });
        }
      }
    } catch (e) {}
    // setState(() {
    //   Form_payment1.text =
    //       (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum)
    //           .toStringAsFixed(2)
    //           .toString();
    // });
  }

  Future<Null> red_Trans_bill() async {
    if (_TransBillModels.length != 0) {
      setState(() {
        _TransBillModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tran_bill.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransBillModel _TransBillModel = TransBillModel.fromJson(map);
          setState(() {
            _TransBillModels.add(_TransBillModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_billAll() async {
    setState(() {
      _TransBillModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tran_bill_All.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransBillModel _TransBillModel = TransBillModel.fromJson(map);
          setState(() {
            _TransBillModels.add(_TransBillModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_bill_meter({required String typex}) async {
    setState(() {
      _TransBillModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_tran_bill_miter.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&typex=$typex';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransBillModel _TransBillModel = TransBillModel.fromJson(map);
          setState(() {
            _TransBillModels.add(_TransBillModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<bool> in_Trans_select(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final ren = prefs.getString('renTalSer') ?? '';
    final user = prefs.getString('ser') ?? '';
    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;

    final tser = _TransBillModels[index].ser;
    final tdocno = _TransBillModels[index].docno;

    final uri = Uri.parse('${MyConstant().domain}/In_tran_select.php').replace(
      queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'ciddoc': '$ciddoc',
        'qutser': '$qutser',
        'tser': '$tser',
        'tdocno': '$tdocno',
        'user': user,
      },
    );
    // print(uri);

    String preview(String s, {int max = 200}) => s
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim()
        .substring(0, s.length > max ? max : s.length);

    try {
      final resp =
          await httpClient.get(uri).timeout(const Duration(seconds: 15));
      final rawBody = utf8.decode(resp.bodyBytes, allowMalformed: true).trim();

      // ---- 200 OK: ต้องได้ "true" เท่านั้นถึงจะถือว่าสำเร็จ ----
      if (resp.statusCode == 200) {
        if (rawBody == 'true') return true;

        // เผื่อบางเซิร์ฟเวอร์ส่ง JSON
        dynamic obj;
        try {
          obj = json.decode(rawBody);
        } catch (_) {}
        if (obj == true || obj?.toString() == 'true') return true;

        // 200 แต่ไม่ใช่ true => ไม่สำเร็จ
        Dialog_error(context, 'รูปแบบข้อมูลไม่ถูกต้อง');
        return false;
      }

      // ---- 409 CONFLICT: แสดงรายละเอียด แล้วคืน false ----
      if (resp.statusCode == 409) {
        try {
          final obj = json.decode(rawBody);
          final msg = (obj['error'] ?? 'มีการเลือกรายการที่ค้างไว้').toString();
          final refs = (obj['user_conflicts'] ?? '').toString();
          final emails = (obj['email'] ?? '').toString();
          final dup =
              obj['docno_duplicate'] == true ? ' (docno นี้ถูกเลือกแล้ว)' : '';
          Dialog_error(
              context,
              ['$emails: ' + msg, if (refs.isNotEmpty) ' สัญญา: $refs', dup]
                  .join());
        } catch (_) {
          Dialog_error(context, 'มีการเลือกรายการที่ค้างไว้');
        }
        return false;
      }

      // ---- อื่น ๆ: error ----
      try {
        final obj = json.decode(rawBody);
        final msg = (obj is Map && obj['error'] != null)
            ? obj['error'].toString()
            : preview(rawBody);
        Dialog_error(context, 'HTTP ${resp.statusCode}: $msg');
      } catch (_) {
        Dialog_error(context, 'HTTP ${resp.statusCode}: ${preview(rawBody)}');
      }
      return false;
    } on TimeoutException {
      Dialog_error(context, 'การเชื่อมต่อหมดเวลา');
      return false;
    } catch (e) {
      Dialog_error(context, 'ข้อผิดพลาด: ${e.toString()}');
      return false;
    }
  }

  // Future<Null> in_Trans_select(index) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;

  //   var tser = _TransBillModels[index].ser;
  //   var tdocno = _TransBillModels[index].docno;

  //   print('object $tdocno');
  //   String url =
  //       '${MyConstant().domain}/In_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
  //   print('url $url');
  //   try {
  //     var response = await httpClient.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print(result);
  //     if (result.toString() == 'true') {
  //       setState(() {
  //         red_Trans_select();
  //       });
  //       print('rrrrrrrrrrrrrr');
  //     } else if (result.toString() == 'false') {
  //       setState(() {
  //         red_Trans_select();
  //       });
  //       print('rrrrrrrrrrrrrr');
  //     } else if (result['total_conflicts'].toString() != '') {
  //       String error_text = result['error'].toString();
  //       String conflicts_text = result['conflicts'].toString();
  //       Dialog_error(context, '$error_text สัญญา:$conflicts_text');
  //     } else {
  //       Dialog_error(context, 'มีผู้ใช้อื่นกำลังทำรายการอยู่....');

  //     }
  //   } catch (e) {
  //     Dialog_error(context, 'มีผู้ใช้อื่นกำลังทำรายการอยู่....');

  //   }
  // }

  Future<Null> in_Trans_fine(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var tser = _TransBillModels[index].ser;
    var tdocno = _TransBillModels[index].docno;

    // print('object $tdocno');
    String url =
        '${MyConstant().domain}/In_tran_select_fine.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('rr>>>>>> $result');
      if (result.toString() == 'true') {
        // setState(() {
        //   red_Trans_select2();
        // });
        // print('rrrrrrrrrrrrrr');
      } else if (result.toString() == 'false') {
        //  setState(() {
        //   red_Trans_select2();
        // });
        // print('rrrrrrrrrrrrrrfalse');
      } else {}
    } catch (e) {}
    // setState(() {
    //   red_Trans_select2_fin();
    // });
  }

  Future<Null> de_Trans_select(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var tser = _TransModels[index].ser;
    var tdocno = _TransModels[index].docno;

    print('tser >>.> $tser');

    String url =
        '${MyConstant().domain}/De_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select();
          sum_disamt.text = '0.00';
          sum_disp.clear();
        });
        print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  ///----------------->
  _moveUp1() {
    _scrollController1.animateTo(_scrollController1.offset - 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown1() {
    _scrollController1.animateTo(_scrollController1.offset + 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveUp2() {
    _scrollController2.animateTo(_scrollController2.offset - 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  _moveDown2() {
    _scrollController2.animateTo(_scrollController2.offset + 200,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  final Set<int> _pressedIndices = Set();

  //////------------------------->
  Future<Null> select_Date(BuildContext context) async {
    final Future<DateTime?> picked = showDatePicker(
      // locale: const Locale('th', 'TH'),
      helpText: 'เลือกวันที่ครบกำหนด', confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
      context: context,
      initialDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(
          DateTime.now().year, DateTime.now().month + 6, DateTime.now().day),
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
        var formatter = DateFormat('yyyy-MM-dd');
        print("${formatter.format(result!)}");
        setState(() {
          End_Bill_Paydate = "${formatter.format(result)}";
        });
      }
    });
  }

  Widget Bills_(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: (Responsive.isDesktop(context))
              ? MediaQuery.of(context).size.width / 3.5
              : MediaQuery.of(context).size.width / 2.2,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  blurRadius: 18,
                  color: Colors.black.withOpacity(.06),
                  offset: const Offset(0, 2))
            ],
            border: Border.all(color: Colors.grey.shade400, width: 0.5),
          ),
          child: Column(
            children: [
              // ======== Segmented Tabs (ค่าบริการ | ค่าน้ำ-ค่าไฟ) ========
              Container(
                height: 52,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  // color: Color(0xFFF7F7F7),
                  gradient: LinearGradient(
                    colors: [Colors.orange[100]!, Colors.orange[300]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  children: [
                    _segmentTab(
                      context: context,
                      active: select_meter == 0,
                      activeColor: Colors.brown.shade800,
                      // activeColor: Colors.grey.shade800,
                      icon: Icons.receipt_long_rounded,
                      label: 'ค่าบริการ',
                      onTap: () async {
                        if (select_meter == 0) return;
                        setState(() => select_meter = 0);
                        await red_Trans_bill();
                      },
                    ),
                    const SizedBox(width: 6),
                    _segmentTab(
                      context: context,
                      active: select_meter == 1,
                      activeColor: Colors.brown.shade800,
                      // activeColor: Colors.lightBlue.shade500,
                      icon: Icons.ev_station_rounded,
                      label: 'ค่าน้ำ - ค่าไฟ',
                      onTap: () async {
                        if (select_meter == 1) return;
                        setState(() => select_meter = 1);
                        await red_Trans_bill_meter(typex: '');
                      },
                    ),
                  ],
                ),
              ),

              // ======== Header Row ========
              _headerRow(
                context: context,
                onChevronTap: () {
                  for (var i = 0; i < _TransBillModels.length; i++) {
                    in_Trans_select(i);
                  }
                },
              ),

              // ======== List ========
              Container(
                height: 474,
                decoration: const BoxDecoration(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                ),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: _TransBillModels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final row = _TransBillModels[index];
                    final selected =
                        _TransModels.any((a) => a.docno == row.docno) &&
                            _TransModels.any((a) => a.date == row.date);

                    final expName = row.dtype == 'KU'
                        ? (row.date == null || row.date == '')
                            ? ''
                            : (row.meter == '')
                                ? '${row.expname} ${DateFormat.MMM('th_TH').format(DateTime.parse('${row.date} 00:00:00'))}'
                                : '${row.expname} ${DateFormat.MMM('th_TH').format(DateTime.parse('${row.date} 00:00:00'))} (${row.meter})'
                        : '${row.expname}';

                    final dueText = row.dtype == 'KU'
                        ? (row.duedate == null || row.duedate == '')
                            ? ''
                            : '${DateFormat('dd-MM').format(DateTime.parse('${row.duedate} 00:00:00'))}-${DateTime.parse('${row.duedate} 00:00:00').year + 0}'
                        : (row.date == null || row.date == '')
                            ? ''
                            : '${DateFormat('dd-MM').format(DateTime.parse('${row.date} 00:00:00'))}-${DateTime.parse('${row.date} 00:00:00').year + 0}';

                    final beforDueText = row.dtype == 'KU'
                        ? (row.befor_duedate == null || row.befor_duedate == '')
                            ? ''
                            : '${DateFormat('dd-MM').format(DateTime.parse('${row.befor_duedate} 00:00:00'))}-${DateTime.parse('${row.befor_duedate} 00:00:00').year + 0}'
                        : (row.befor_date == null || row.befor_date == '')
                            ? ''
                            : '${DateFormat('dd-MM').format(DateTime.parse('${row.befor_date} 00:00:00'))}-${DateTime.parse('${row.befor_date} 00:00:00').year + 0}';
                    final beforTotal =
                        '${nFormat.format(double.tryParse(row.befor_total ?? "0"))} ';
                    return _billRowTile(
                      context: context,
                      selected: selected,
                      expName: expName,
                      tooltipMain: '${row.expname}',
                      dueText: dueText,
                      beforDueText: beforDueText,
                      beforTotal: beforTotal,
                      docno: row.docno ?? '',
                      refnox: row.refnox ?? '',
                      namex: row.namex ?? '',
                      onTap: (selected)
                          ? () async {}
                          : () async {
                              final ok = await in_Trans_select(index);
                              if (!ok) return;
                              await in_Trans_fine(index);
                              await red_Trans_select();
                              if (mounted) setState(() {});
                            },
                    );
                  },
                ),
              ),

              // ======== Footer Actions ========
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 4),
                decoration: const BoxDecoration(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    _primaryBtn(
                      label: '+ เพิ่มใหม่',
                      color: Colors.green,
                      onTap: addPlaySelect,
                    ),
                    const Spacer(),
                    _ghostBtn(
                      label: select_meter == 1
                          ? 'ค่าน้ำ-ไฟทั้งหมด'
                          : 'ค่าบริการทั้งหมด',
                      onTap: () async {
                        if (select_meter == 1) {
                          await red_Trans_bill_meter(typex: 'All');
                        } else {
                          await red_Trans_billAll();
                        }

                        if (mounted) setState(() {});
                      },
                    ),
                    const SizedBox(width: 8),
                    _accentBtn(
                      label: 'ประวัติวางบิล',
                      color: Colors.amber.shade700,
                      onTap: () => setState(() => indexbill = 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

// -------------------- Widget helpers (no classes) --------------------

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

  Widget _headerRow({
    required BuildContext context,
    VoidCallback? onChevronTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade200, Colors.brown.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: const BorderSide(color: Colors.black12, width: .8),
          // right: rightBorder
          //     ? const BorderSide(color: Colors.white30, width: .8)
          //     : BorderSide.none,
        ),
      ),
      // color: const Color(0xFFF1E8E1),
      child: Row(
        children: [
          _headerCell(label: 'ประเภท', flex: 2),
          _headerCell(label: 'กำหนดชำระ', flex: 1, center: true),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.086,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: const AutoSizeText(
                    'เลขตั้งหนี้',
                    minFontSize: 10,
                    maxFontSize: 25,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onChevronTap,
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.027,
                    child: const Center(child: Icon(Icons.chevron_right)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell({
    required String label,
    int flex = 1,
    bool center = false,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: center ? Alignment.center : Alignment.centerLeft,
        // color: const Color(0xFFF1E8E1),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown.shade200, Colors.brown.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            bottom: const BorderSide(color: Colors.black12, width: .8),
            // right: rightBorder
            //     ? const BorderSide(color: Colors.white30, width: .8)
            //     : BorderSide.none,
          ),
        ),
        child: AutoSizeText(
          label,
          minFontSize: 10,
          maxFontSize: 25,
          maxLines: 1,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            color: PeopleChaoScreen_Color.Colors_Text2_,
            fontWeight: FontWeight.bold,
            fontFamily: Font_.Fonts_T,
          ),
        ),
      ),
    );
  }

  Widget _billRowTile({
    required BuildContext context,
    required bool selected,
    required String expName,
    required String tooltipMain,
    required String dueText,
    required String beforDueText,
    required String beforTotal,
    required String docno,
    required String refnox,
    required String namex,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppbackgroundColor.Sub_Abg_Colors,
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? tappedIndex_Color.tappedIndex_Colors.withOpacity(0.5)
              //  Colors.orange.shade100
              : null,
          border: const Border(
            bottom: BorderSide(color: Colors.grey, width: 0.3),
          ),
        ),
        child: ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          onTap: onTap,
          subtitle: (refnox == 'null' || refnox == '' || refnox.isEmpty)
              ? null
              : Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      color: Colors.grey,
                      size: 16,
                    ),
                    Expanded(
                      flex: 2,
                      child: AutoSizeText(
                        ' [$namex] แบ่งชำระจาก $beforDueText',
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontFamily: Font_.Fonts_T,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    // Expanded(
                    //   flex: 1,
                    //   child: AutoSizeText(
                    //     dueText ?? '',
                    //     minFontSize: 12,
                    //     maxFontSize: 16,
                    //     maxLines: 1,
                    //     textAlign: TextAlign.center,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: const TextStyle(
                    //       fontFamily: Font_.Fonts_T,
                    //       color: Colors.grey,
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      flex: 3,
                      child: Tooltip(
                        message: '$refnox (ยอดสุทธิ $beforTotal)',
                        child: AutoSizeText(
                          '$refnox (ยอดสุทธิ $beforTotal)',
                          // refnox ?? '',
                          minFontSize: 12,
                          maxFontSize: 16,
                          maxLines: 1,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: Font_.Fonts_T,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          title: Row(
            children: [
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: tooltipMain,
                  child: AutoSizeText(
                    expName,
                    minFontSize: 14,
                    maxFontSize: 20,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: AutoSizeText(
                  dueText ?? '',
                  minFontSize: 14,
                  maxFontSize: 20,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Tooltip(
                  message: docno,
                  child: AutoSizeText(
                    docno,
                    minFontSize: 14,
                    maxFontSize: 20,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: Font_.Fonts_T,
                      color: PeopleChaoScreen_Color.Colors_Text2_,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _primaryBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: AutoSizeText(
            label,
            minFontSize: 8,
            maxFontSize: 13,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ghostBtn({
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: AutoSizeText(
            label,
            minFontSize: 10,
            maxFontSize: 15,
            style: const TextStyle(
              color: PeopleChaoScreen_Color.Colors_Text2_,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
      ),
    );
  }

  Widget _accentBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: AutoSizeText(
            label,
            minFontSize: 10,
            maxFontSize: 15,
            style: const TextStyle(
              color: PeopleChaoScreen_Color.Colors_Text2_,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
      ),
    );
  }

// ---------- helper: ย่อหัวคอลัมน์ ----------
  Widget headerCell(
    String text, {
    int flex = 1,
    double? width,
    TextAlign align = TextAlign.center,
    bool rightBorder = true,
  }) {
    final t = AutoSizeText(
      text,
      minFontSize: 10,
      maxFontSize: 15,
      maxLines: 1,
      textAlign: align,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: PeopleChaoScreen_Color.Colors_Text1_,
        fontWeight: FontWeight.bold,
        fontFamily: FontWeight_.Fonts_T,
      ),
    );

    final cell = Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.brown[200],
        border: Border(
          bottom: const BorderSide(color: Colors.black12, width: 0.6),
          right: rightBorder
              ? const BorderSide(color: Colors.white24, width: 0.6)
              : BorderSide.none,
        ),
      ),
      child: Center(child: t),
    );

    if (width != null) {
      return SizedBox(width: width, child: cell);
    }
    return Expanded(flex: flex, child: cell);
  }

// ---------- widget: หัวตาราง ----------
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

  Widget _hdrIconCell({
    required IconData icon,
    double width = 44,
    VoidCallback? onTap,
    bool rightBorder = false,
    String? tooltip,
  }) {
    final content =
        Icon(icon, size: 18, color: PeopleChaoScreen_Color.Colors_Text1_);
    final box = Container(
      height: 44,
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
      child: Center(child: content),
    );
    final body = onTap == null
        ? box
        : InkWell(onTap: onTap, hoverColor: Colors.black12, child: box);
    return SizedBox(
      width: width,
      child: tooltip == null ? body : Tooltip(message: tooltip, child: body),
    );
  }

// ---------- หัวตารางแบบสวยขึ้น ----------
  Widget billHeaderTable(BuildContext context) {
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
              children: const [
                // SizedBox(width: 12),
                // Icon(Icons.receipt_long,
                //     size: 20, color: PeopleChaoScreen_Color.Colors_Text1_),
                // SizedBox(width: 8),
                Expanded(
                  child: AutoSizeText(
                    'รายละเอียดบิล',
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
              _hdrCell('ลำดับ', width: 56),
              _hdrCell('กำหนดชำระ', flex: 1, align: TextAlign.left),
              _hdrCell('รายการ', flex: 2),
              _hdrCell('จำนวน', flex: 1, align: TextAlign.right),
              _hdrCell('หน่วย', flex: 1, align: TextAlign.right),
              _hdrCell('ก่อนVAT', flex: 1, align: TextAlign.right),
              _hdrCell('VAT', flex: 1, align: TextAlign.right),
              _hdrCell('WHT', flex: 1, align: TextAlign.right),
              _hdrCell('ยอดสุทธิ',
                  flex: 1, align: TextAlign.right, rightBorder: false),
              _hdrIconCell(
                icon: Icons.close_rounded,
                width: 44,
                tooltip: 'ล้างการเลือก',
                onTap: () => deall_Trans_select(), // ถ้าไม่ใช้ context ให้ลบออก
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool isSidebarOpen = true; // state
  //////------------------------->
  @override
  Widget build(BuildContext context) {
    final isOpen =
        context.watch<SidebarController>().isOpen; // ← อ่านสถานะข้ามหน้า
    // final w = MediaQuery.of(context).size.width;
    return indexbill == 1
        ? Column(
            children: [
              // Bills_(context),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 20),
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      // color: AppbackgroundColor.Sub_Abg_Colors,
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              indexbill = 0;
                                              red_Trans_bill();
                                              red_Trans_select();
                                              red_Vocher();
                                              ser_vocher = '0';
                                              sum_disamt.text = '0.00';
                                              sum_disp.clear();
                                            });
                                          },
                                          child: Container(
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.yellow.shade700,
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
                                              // border: Border.all(color: Colors.white, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.chevron_left),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  const AutoSizeText(
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    'วางบิล',
                                                    style: TextStyle(
                                                        color:
                                                            PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                        //fontWeight: FontWeight.bold,
                                                        fontFamily:
                                                            Font_.Fonts_T),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ],
                    )),
              ),
              BillsHistory(
                Get_Value_cid: widget.Get_Value_cid,
                Get_Value_NameShop_index: widget.Get_Value_NameShop_index,
                namenew: widget.namenew,
              ),
            ],
          )
        : LayoutBuilder(
            builder: (context, constraints) {
              // ถ้า AdminScaffold "ไม่ตัด sidebar ให้" ต้องลบเอง
              final viewportW = Responsive.isDesktop(context)
                  ? (isOpen
                      ? constraints.maxWidth - 295
                      : constraints.maxWidth - 260)
                  : 1200.00;

              return ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // อย่าใช้ Expanded ใต้ ScrollView แนวนอน → กำหนด width เองด้วย SizedBox
                            Bills_(context),

                            Expanded(
                              // flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
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
                                        color: Colors.grey.shade400,
                                        width: 0.5),
                                  ),
                                  // width: MediaQuery.of(context).size.width * 0.52,
                                  child: Column(
                                    children: [
                                      billHeaderTable(context),
                                      Container(
                                        height: 290,
                                        decoration: const BoxDecoration(
                                          color:
                                              AppbackgroundColor.Sub_Abg_Colors,
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
                                          // controller: _scrollController2,
                                          // itemExtent: 50,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: _TransModels.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
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
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        child: open_dislis == 0
                                                            ? AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 15,
                                                                maxLines: 1,
                                                                '${index + 1}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: const TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              )
                                                            : PopupMenuButton(
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context) =>
                                                                        [
                                                                  PopupMenuItem(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () async {
                                                                        // ใช้ context ของหน้า ไม่ใช่ของเมนู
                                                                        final pageCtx =
                                                                            this.context;

                                                                        // ปิดเมนู (ถ้ามี)
                                                                        if (Navigator.of(context,
                                                                                rootNavigator: true)
                                                                            .canPop()) {
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .pop('OK');
                                                                        }

                                                                        if (_tapBusy ||
                                                                            _dialogOpen)
                                                                          return;
                                                                        setState(
                                                                            () {
                                                                          _tapBusy =
                                                                              true;
                                                                          Formposlok_.text =
                                                                              '';
                                                                        });
                                                                        _dialogOpen =
                                                                            true;

                                                                        try {
                                                                          await showDialog<
                                                                              String>(
                                                                            context:
                                                                                pageCtx,
                                                                            useRootNavigator:
                                                                                true,
                                                                            barrierDismissible:
                                                                                false,
                                                                            builder:
                                                                                (BuildContext dialogCtx) {
                                                                              final formKey = GlobalKey<FormState>();
                                                                              final isLoadingVN = ValueNotifier<bool>(false); // ✅ แทน setStateDialog

                                                                              Future<void> _submit() async {
                                                                                if (isLoadingVN.value) return;

                                                                                final okForm = formKey.currentState?.validate() ?? false;
                                                                                if (!okForm) return;

                                                                                ChaoAppLoader.show(
                                                                                  asset: 'images/LOGO.png', // หรือ .gif ก็ได้
                                                                                  assetFromPackage: false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                                                                  useCard: false,
                                                                                  dimBackground: true,
                                                                                  dismissible: false,
                                                                                  message: 'กำลังโหลด...',
                                                                                  messageStyle: const TextStyle(
                                                                                    fontSize: 16,
                                                                                    fontWeight: FontWeight.bold,
                                                                                    color: Colors.black,
                                                                                    fontFamily: FontWeight_.Fonts_T,
                                                                                  ),
                                                                                  motion: Motion.pingPong,
                                                                                  rangeMinAt: 0.48,
                                                                                  rangeMaxAt: 0.52,
                                                                                  slideMs: 1800,
                                                                                  verticalFactor: 0.5,
                                                                                  size: 150,
                                                                                );
                                                                                isLoadingVN.value = true;

                                                                                bool didSuccess = false;
                                                                                final item = _TransModels[index];
                                                                                final docno = item.docno?.toString() ?? '';
                                                                                final ser = item.ser?.toString() ?? ''; // ถ้าฟังก์ชันลบต้องการ ser
                                                                                try {
                                                                                  // ✅ งานหลัก
                                                                                  await de_Trans_item(index);

                                                                                  if (mounted) {
                                                                                    Formposlok_.clear();
                                                                                    Formterm_.clear();
                                                                                  }

                                                                                  // // รีเฟรชข้อมูล
                                                                                  // if (select_meter == 1) {
                                                                                  //   await red_Trans_bill_meter(typex: 'All');
                                                                                  // } else {
                                                                                  //   await red_Trans_billAll();
                                                                                  // }
                                                                                  // await red_Trans_select();

                                                                                  // ปิด dialog แล้วค่อยโชว์ success
                                                                                  if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                                                                                    Navigator.of(dialogCtx, rootNavigator: true).pop('OK');
                                                                                  }
                                                                                  if (mounted) {
                                                                                    Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>ลบรายการตั้งหนี้($docno)');
                                                                                    await Dialog_success(pageCtx, 'ทำรายการสำเร็จ');
                                                                                  }
                                                                                  didSuccess = true;
                                                                                } catch (e) {
                                                                                  await Dialog_error(dialogCtx, 'ทำรายการไม่สำเร็จ: $e');
                                                                                } finally {
                                                                                  ChaoAppLoader.hide();

                                                                                  if (select_meter == 1) {
                                                                                    await red_Trans_bill_meter(typex: 'All');
                                                                                  } else {
                                                                                    await red_Trans_billAll();
                                                                                  }
                                                                                  await red_Trans_select();

                                                                                  if (isLoadingVN.value) isLoadingVN.value = false;
                                                                                }
                                                                              }

                                                                              return WillPopScope(
                                                                                onWillPop: () async => !isLoadingVN.value,
                                                                                child: AlertDialog(
                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                  backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                                                                                  titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                                                                  contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                                                                  actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                                                  title: Row(
                                                                                    children: [
                                                                                      Container(
                                                                                        height: 36,
                                                                                        width: 36,
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.red.withOpacity(0.10),
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                        child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                                                                                      ),
                                                                                      const SizedBox(width: 10),
                                                                                      const Expanded(
                                                                                        child: Text(
                                                                                          'ลบรายการ',
                                                                                          style: TextStyle(
                                                                                            color: Colors.black87,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontSize: 18,
                                                                                            fontFamily: FontWeight_.Fonts_T,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      // ปุ่มปิด (ปิดได้เมื่อไม่โหลด)
                                                                                      ValueListenableBuilder<bool>(
                                                                                        valueListenable: isLoadingVN,
                                                                                        builder: (_, isLoading, __) => InkWell(
                                                                                          borderRadius: BorderRadius.circular(20),
                                                                                          onTap: isLoading ? null : () => Navigator.of(dialogCtx, rootNavigator: true).pop(),
                                                                                          child: const Padding(
                                                                                            padding: EdgeInsets.all(6.0),
                                                                                            child: Icon(Icons.close, size: 22, color: Colors.red),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  content: SingleChildScrollView(
                                                                                    child: Form(
                                                                                      key: formKey,
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                        children: [
                                                                                          // chip แสดง docno
                                                                                          Container(
                                                                                            width: double.infinity,
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                                                                                    border: Border.all(color: Colors.blue.withOpacity(0.25)),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    '${_TransModels[index].expname}',
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
                                                                                                    'รายการตั้งหนี้ : ${_TransModels[index].docno}',
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

                                                                                          // คำเตือน
                                                                                          Container(
                                                                                            width: double.infinity,
                                                                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                            decoration: BoxDecoration(
                                                                                              color: Colors.red.withOpacity(0.06),
                                                                                              borderRadius: BorderRadius.circular(10),
                                                                                              border: Border.all(color: Colors.red.withOpacity(0.18)),
                                                                                            ),
                                                                                            child: Text(
                                                                                              'ระบุเหตุผลการยกเลิกให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                                                                                              style: TextStyle(
                                                                                                color: Colors.red.shade700,
                                                                                                fontFamily: Font_.Fonts_T,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 12),

                                                                                          // หมายเหตุ (ต้องกรอก)
                                                                                          Text(
                                                                                            'ใส่หมายเหตุ',
                                                                                            style: TextStyle(
                                                                                              color: ManageScreen_Color.Colors_Text2_,
                                                                                              fontFamily: Font_.Fonts_T,
                                                                                              fontWeight: FontWeight.w600,
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 6),
                                                                                          TextFormField(
                                                                                            controller: Formposlok_,
                                                                                            maxLines: 2,
                                                                                            maxLength: 200,
                                                                                            cursorColor: Colors.blueGrey,
                                                                                            validator: (v) => (v == null || v.trim().isEmpty) ? 'ใส่ข้อมูลให้ครบถ้วน' : null,
                                                                                            decoration: InputDecoration(
                                                                                              hintText: 'ระบุเหตุผลการลบรายการ',
                                                                                              counterText: '',
                                                                                              isDense: true,
                                                                                              filled: true,
                                                                                              fillColor: Colors.white.withOpacity(0.3),
                                                                                              labelText: 'หมายเหตุ',
                                                                                              labelStyle: TextStyle(
                                                                                                color: ManageScreen_Color.Colors_Text2_,
                                                                                                fontFamily: Font_.Fonts_T,
                                                                                              ),
                                                                                              enabledBorder: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                borderSide: const BorderSide(color: Colors.grey, width: 1),
                                                                                              ),
                                                                                              focusedBorder: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                borderSide: const BorderSide(color: Colors.black, width: 1),
                                                                                              ),
                                                                                              errorBorder: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                                borderSide: const BorderSide(color: Colors.red, width: 1),
                                                                                              ),
                                                                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),

                                                                                  // ปุ่มยืนยัน
                                                                                  actions: [
                                                                                    // actions: [...]
                                                                                    AnimatedBuilder(
                                                                                      animation: Listenable.merge([
                                                                                        Formposlok_,
                                                                                        isLoadingVN
                                                                                      ]),
                                                                                      builder: (ctx, _) {
                                                                                        final isLoading = isLoadingVN.value; // อ่านค่าปัจจุบันของโหลด
                                                                                        final disabled = Formposlok_.text.trim().isEmpty || isLoading;

                                                                                        return SizedBox(
                                                                                          width: double.infinity,
                                                                                          child: ElevatedButton.icon(
                                                                                            icon: isLoading
                                                                                                ? const SizedBox(
                                                                                                    height: 18,
                                                                                                    width: 18,
                                                                                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                                                                  )
                                                                                                : const Icon(Icons.check_circle_outline),
                                                                                            style: ElevatedButton.styleFrom(
                                                                                              backgroundColor: Colors.black,
                                                                                              minimumSize: const Size.fromHeight(44),
                                                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                            ),
                                                                                            onPressed: disabled ? null : _submit,
                                                                                            label: const Text(
                                                                                              'ยืนยัน',
                                                                                              style: TextStyle(
                                                                                                color: Colors.white,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                fontFamily: FontWeight_.Fonts_T,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            },
                                                                          );
                                                                        } finally {
                                                                          _dialogOpen =
                                                                              false;
                                                                          if (mounted)
                                                                            setState(() =>
                                                                                _tapBusy = false);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        padding:
                                                                            const EdgeInsets.all(10),
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Translate.TranslateAndSetText(
                                                                                'ยกเลิกรายการตั้งหนี้',
                                                                                PeopleChaoScreen_Color.Colors_Text1_,
                                                                                TextAlign.center,
                                                                                null,
                                                                                Font_.Fonts_T,
                                                                                13,
                                                                                1,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (_TransModels[
                                                                              index]
                                                                          .ucost ==
                                                                      '0.00')
                                                                    PopupMenuItem(
                                                                      child:
                                                                          InkWell(
                                                                        // ===== onTap ที่แก้ไขแล้ว =====
                                                                        onTap:
                                                                            () async {
                                                                          // context ตรงนี้อยู่ใน PopupMenuItem ซึ่งจะถูก pop ทิ้ง
                                                                          // ใช้ pageCtx จาก State แทน (คอนเท็กซ์ของหน้า ไม่ถูก dispose)
                                                                          final pageCtx =
                                                                              this.context;

                                                                          // ปิดเมนูให้เสร็จก่อน
                                                                          Navigator.of(context, rootNavigator: true)
                                                                              .pop('OK');
                                                                          final FormTotalterm1 =
                                                                              TextEditingController();
                                                                          final FormTotalterm2 =
                                                                              TextEditingController();

                                                                          // เช็คเงื่อนไขห้ามแบ่งชำระ
                                                                          final refnox =
                                                                              _TransModels[index].refnox ?? '';
                                                                          final total =
                                                                              double.tryParse(_TransModels[index].total ?? '0') ?? 0.0;
                                                                          final allowInsta =
                                                                              _TransModels[index].allow_installments;
                                                                          int typeInstall =
                                                                              0;

                                                                          if (refnox.isNotEmpty ||
                                                                              total < 1.0 ||
                                                                              allowInsta.toString() == 'false') {
                                                                            final msg = (total < 1.0)
                                                                                ? 'ไม่สามารถแบ่งชำระได้: ยอดสุทธิต้องมากกว่า 1.00 '
                                                                                : 'ไม่สามารถแบ่งชำระได้(หมายเหตุ: เคยถูกแบ่งชำระมาแล้วหรือประเภทมิเตอร์)';
                                                                            await Dialog_error(pageCtx,
                                                                                msg);
                                                                            return;
                                                                          }

                                                                          if (_tapBusy ||
                                                                              _dialogOpen)
                                                                            return; // กันกดย้ำ/เปิด dialog ซ้อน
                                                                          setState(
                                                                              () {
                                                                            _tapBusy =
                                                                                true;
                                                                            Formterm_.text =
                                                                                '2';
                                                                          });
                                                                          _dialogOpen =
                                                                              true;

                                                                          try {
                                                                            // ตัวช่วย: แบ่งเงินเป็น 2 งวดแบบ 50/50 ปัด 2 ตำแหน่ง แล้วกระจายเศษให้ งวด 2
                                                                            List<double>
                                                                                _splitHalf2(double total) {
                                                                              if (total <= 0)
                                                                                return [
                                                                                  0.0,
                                                                                  0.0
                                                                                ];
                                                                              final half = total / 2.0;
                                                                              final a1 = double.parse(half.toStringAsFixed(2));
                                                                              // ให้ผลรวมเท่ากับ total เป๊ะ โดยปรับงวด 2
                                                                              final a2 = double.parse((total - a1).toStringAsFixed(2));
                                                                              return [
                                                                                a1,
                                                                                a2
                                                                              ];
                                                                            }

                                                                            // ===== Helpers =====
                                                                            final _moneyReg =
                                                                                RegExp(r'^\d{0,12}(\.\d{0,2})?$');
                                                                            double _toAmount(String? s) =>
                                                                                double.tryParse((s ?? '').replaceAll(',', '')) ??
                                                                                0.0;
                                                                            String _fmt2(double x) =>
                                                                                NumberFormat('#,##0.00').format(x);
                                                                            final TextInputFormatter
                                                                                moneyFormatter =
                                                                                TextInputFormatter.withFunction((oldV, newV) {
                                                                              final t = newV.text;
                                                                              if (t.isEmpty)
                                                                                return newV;
                                                                              return _moneyReg.hasMatch(t) ? newV : oldV;
                                                                            });

// จำนวนงวด และรายการ controller สำหรับแต่ละงวด
                                                                            final termCtrl =
                                                                                TextEditingController(text: '2');
                                                                            final List<TextEditingController>
                                                                                _amountCtrls =
                                                                                [];

// ให้มี controller เท่ากับจำนวนงวด
                                                                            void
                                                                                _ensureControllers(int n) {
                                                                              while (_amountCtrls.length < n) {
                                                                                _amountCtrls.add(TextEditingController());
                                                                              }
                                                                              while (_amountCtrls.length > n) {
                                                                                _amountCtrls.removeLast().dispose();
                                                                              }
                                                                            }

// คำนวณยอดรวม และปรับงวดสุดท้ายให้ผลรวม == total
                                                                            void
                                                                                _recalcLast(double total) {
                                                                              final n = _amountCtrls.length;
                                                                              if (n == 0)
                                                                                return;

                                                                              double sumPrev = 0.0;
                                                                              for (int i = 0; i < n - 1; i++) {
                                                                                sumPrev += _toAmount(_amountCtrls[i].text);
                                                                              }
                                                                              // งวดสุดท้าย = total - ผลรวมก่อนหน้า (อย่างน้อย 0)
                                                                              double last = total - sumPrev;
                                                                              if (last < 0)
                                                                                last = 0;
                                                                              _amountCtrls[n - 1].text = last == 0 ? '' : _fmt2(double.parse(last.toStringAsFixed(2)));
                                                                            }

// seed ค่าแบบหารเท่า และ “งวดสุดท้าย” จะชดเชยเศษให้พอดีรวม = total
                                                                            void _seedEven(int n,
                                                                                double total) {
                                                                              if (n <= 0)
                                                                                return;
                                                                              final each = double.parse((total / n).toStringAsFixed(2));
                                                                              for (int i = 0; i < n - 1; i++) {
                                                                                _amountCtrls[i].text = each == 0 ? '' : _fmt2(each);
                                                                              }
                                                                              final last = double.parse((total - each * (n - 1)).toStringAsFixed(2));
                                                                              _amountCtrls[n - 1].text = last == 0 ? '' : _fmt2(last);
                                                                            }

                                                                            await showDialog<String>(
                                                                              context: pageCtx, // ✅ ใช้ pageCtx แทน context เดิม
                                                                              useRootNavigator: true, // ✅ กันไปผูกกับเมนู/overlay
                                                                              barrierDismissible: false, // 🔒 กันปิดด้วยการแตะนอกกรอบระหว่างโหลด
                                                                              builder: (BuildContext dialogCtx) {
                                                                                final formKey = GlobalKey<FormState>();
                                                                                bool isLoading = false;

                                                                                return StatefulBuilder(
                                                                                  builder: (ctx, setStateDialog) {
                                                                                    // ====== ส่งงานเมื่อกด "ยืนยัน" ======
                                                                                    Future<void> _submit() async {
                                                                                      if (isLoading) return;

                                                                                      // 1) Validate
                                                                                      final okForm = formKey.currentState?.validate() ?? false;
                                                                                      if (!okForm) return;

                                                                                      // 2) Loader + สถานะโหลด (ใช้ของคุณเองแทนได้)
                                                                                      ChaoAppLoader.show(
                                                                                        asset: 'images/LOGO.png', // หรือ .gif ก็ได้
                                                                                        assetFromPackage: false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                                                                        useCard: false,
                                                                                        dimBackground: true,
                                                                                        dismissible: false,
                                                                                        message: 'กำลังโหลด...',
                                                                                        messageStyle: const TextStyle(
                                                                                          fontSize: 16,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: Colors.black,
                                                                                          fontFamily: FontWeight_.Fonts_T,
                                                                                        ),
                                                                                        motion: Motion.pingPong,
                                                                                        rangeMinAt: 0.48,
                                                                                        rangeMaxAt: 0.52,
                                                                                        slideMs: 1800,
                                                                                        verticalFactor: 0.5,
                                                                                        size: 150,
                                                                                      );
                                                                                      setStateDialog(() => isLoading = true);

                                                                                      bool didSuccess = false;

                                                                                      try {
                                                                                        final preferences = await SharedPreferences.getInstance();
                                                                                        final ren = preferences.getString('renTalSer') ?? '';
                                                                                        final user = preferences.getString('ser') ?? '';

                                                                                        final sertranDocno = '${_TransModels[index].docno}';
                                                                                        final remark = Formposlok_.text.trim();
                                                                                        final term = Formterm_.text.trim();

                                                                                        final params = <String, String>{
                                                                                          'isAdd': 'true',
                                                                                          'ren': ren,
                                                                                          'puser': user,
                                                                                          'docnotran': sertranDocno,
                                                                                          'remark': remark,
                                                                                          'typeInstall': typeInstall.toString(),
                                                                                        };

                                                                                        if (typeInstall == 0) {
                                                                                          // โหมดตามงวด: ส่งแค่จำนวนงวดให้ PHP ไปแบ่งเอง
                                                                                          final n = int.tryParse(Formterm_.text.trim()) ?? 0;
                                                                                          if (n < 2 || n > 6) {
                                                                                            await Dialog_error(pageCtx, 'จำนวนงวดต้องอยู่ระหว่าง 2–6');
                                                                                            return;
                                                                                          }
                                                                                          params['term'] = n.toString();
                                                                                        } else {
                                                                                          // โหมดตามจำนวนเงิน: ส่ง amounts ให้ครบทุกงวด
                                                                                          final n = int.tryParse(termCtrl.text.trim()) ?? 0;
                                                                                          if (n < 2 || n > 6) {
                                                                                            await Dialog_error(pageCtx, 'จำนวนงวดต้องอยู่ระหว่าง 2–6');
                                                                                            return;
                                                                                          }

                                                                                          // ป้องกัน index error: ให้แน่ใจว่า _amountCtrls มีครบ n ตัว
                                                                                          _ensureControllers(n);

                                                                                          // แปลงเป็นตัวเลข 4 ตำแหน่ง (ฝั่ง PHP รองรับ 4 ตำแหน่ง แล้ว DB จะปัดเป็น 2 เอง)
                                                                                          final amounts = <double>[];
                                                                                          for (int i = 0; i < n; i++) {
                                                                                            final a = double.parse(_toAmount(_amountCtrls[i].text).toStringAsFixed(4));
                                                                                            if (a <= 0) {
                                                                                              await Dialog_error(pageCtx, 'ยอดงวดที่ ${i + 1} ต้องมากกว่า 0');
                                                                                              return;
                                                                                            }
                                                                                            amounts.add(a);
                                                                                          }

                                                                                          // ตรวจผลรวมให้เท่ากับ total (ปัด 2 ตำแหน่ง)
                                                                                          final sum2 = double.parse(amounts.fold<double>(0, (p, v) => p + v).toStringAsFixed(2));
                                                                                          final total2 = double.parse(total.toStringAsFixed(2));
                                                                                          if (sum2 != total2) {
                                                                                            await Dialog_error(pageCtx, 'ยอดรวมทุกงวด (${sum2.toStringAsFixed(2)}) ไม่เท่ากับยอดรวมเดิม (${total2.toStringAsFixed(2)})');
                                                                                            return;
                                                                                          }

                                                                                          params['term'] = n.toString();
                                                                                          params['amounts'] = jsonEncode(amounts); // << ส่ง JSON array
                                                                                        }

// (ทางที่ดี) log แบบย่อ ไม่ print ค่าลับ
                                                                                        debugPrint('POST /c_trans_installments -> typeInstall=$typeInstall, term=${params['term']}');

                                                                                        final resp = await httpClient
                                                                                            .post(
                                                                                              Uri.parse('${MyConstant().domain}/c_trans_installments.php'),
                                                                                              body: params, // form-encoded; PHP อ่าน $_POST ได้
                                                                                            )
                                                                                            .timeout(const Duration(seconds: 20));
                                                                                        // final resp = await http.get(uri).timeout(const Duration(seconds: 20));
                                                                                        if (resp.statusCode != 200) {
                                                                                          final decoded = json.decode(resp.body);
                                                                                          print('${decoded['message']}');
                                                                                          await Dialog_error(dialogCtx, 'แบ่งชำระไม่สำเร็จ: HTTP ${resp.statusCode} : ${decoded['message']}');
                                                                                          return;
                                                                                        }

                                                                                        final decoded = json.decode(resp.body);
                                                                                        if (decoded is! Map || decoded['status'] != 'success') {
                                                                                          await Dialog_error(dialogCtx, 'แบ่งชำระไม่สำเร็จ: ${decoded.toString()}');
                                                                                          return;
                                                                                        }

                                                                                        // เคลียร์ฟอร์ม
                                                                                        if (mounted) {
                                                                                          Formposlok_.clear();
                                                                                          Formterm_.clear();
                                                                                        }

                                                                                        // ✅ รีเฟรชก่อน loop เพื่อให้ _TransBillModels มีเอกสารใหม่
                                                                                        if (select_meter == 1) {
                                                                                          await red_Trans_bill_meter(typex: 'All');
                                                                                        } else {
                                                                                          await red_Trans_billAll();
                                                                                        }
                                                                                        await red_Trans_select();

                                                                                        // ไล่ทำงานทีละใบที่เพิ่งสร้าง
                                                                                        final List<dynamic> newdocsDyn = (decoded['newdocno'] as List?) ?? const [];
                                                                                        for (final e in newdocsDyn) {
                                                                                          final doc = (e is Map && e['docno'] != null) ? e['docno'].toString() : '';
                                                                                          if (doc.isEmpty) continue;

                                                                                          final idx = _TransBillModels.indexWhere((t) => t.docno == doc);
                                                                                          if (idx == -1) continue; // กัน data lag

                                                                                          final selected = await in_Trans_select(idx);
                                                                                          if (selected != true) continue;

                                                                                          if (contractxFineModels.isNotEmpty) {
                                                                                            await in_Trans_fine(idx);
                                                                                          }

                                                                                          await Future.delayed(const Duration(milliseconds: 120)); // ผ่อน UI
                                                                                        }

                                                                                        final msg = (decoded['message'] as String?) ?? 'ทำรายการสำเร็จ';

                                                                                        // ปิด dialog หลักก่อน แล้วค่อยโชว์ success
                                                                                        if (Navigator.of(dialogCtx, rootNavigator: true).canPop()) {
                                                                                          Navigator.of(dialogCtx, rootNavigator: true).pop('OK');
                                                                                        }
                                                                                        if (mounted) {
                                                                                          Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>แบ่งชำระ(${sertranDocno})');
                                                                                          await Dialog_success(pageCtx, msg); // ✅ ใช้ pageCtx (context ระดับหน้า)
                                                                                        }
                                                                                        didSuccess = true;
                                                                                      } catch (e) {
                                                                                        await Dialog_error(dialogCtx, 'แบ่งชำระไม่สำเร็จ: $e'); // ✅ ใช้ dialogCtx
                                                                                      } finally {
                                                                                        ChaoAppLoader.hide();

                                                                                        // ถ้าไม่สำเร็จ รีเฟรชปิดท้ายให้ state กลับมาถูก
                                                                                        // if (!didSuccess) {
                                                                                        if (select_meter == 1) {
                                                                                          await red_Trans_bill_meter(typex: 'All');
                                                                                        } else {
                                                                                          await red_Trans_billAll();
                                                                                        }
                                                                                        await red_Trans_select();
                                                                                        // }

                                                                                        if (mounted) setStateDialog(() => isLoading = false);
                                                                                      }
                                                                                    }

                                                                                    return WillPopScope(
                                                                                      onWillPop: () async => !isLoading, // 🔒 กันกด back ตอนโหลด
                                                                                      child: AlertDialog(
                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                                                        backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                                                                                        titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                                                                        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                                                                                        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                                                                        title: Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              height: 36,
                                                                                              width: 36,
                                                                                              decoration: BoxDecoration(
                                                                                                color: Colors.orange.withOpacity(0.10),
                                                                                                borderRadius: BorderRadius.circular(10),
                                                                                              ),
                                                                                              child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                                                                                            ),
                                                                                            const SizedBox(width: 10),
                                                                                            const Expanded(
                                                                                              child: Text(
                                                                                                'แบ่งชำระ',
                                                                                                style: TextStyle(
                                                                                                  color: Colors.black87,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  fontSize: 18,
                                                                                                  fontFamily: FontWeight_.Fonts_T,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            InkWell(
                                                                                              borderRadius: BorderRadius.circular(20),
                                                                                              onTap: isLoading ? null : () => Navigator.of(dialogCtx, rootNavigator: true).pop(),
                                                                                              child: const Padding(
                                                                                                padding: EdgeInsets.all(6.0),
                                                                                                child: Icon(Icons.close, size: 22, color: Colors.orange),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        content: SingleChildScrollView(
                                                                                          child: Form(
                                                                                            key: formKey,
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                              children: [
                                                                                                // chip แสดง docno
                                                                                                Container(
                                                                                                  width: double.infinity,
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                                                                                          border: Border.all(color: Colors.blue.withOpacity(0.25)),
                                                                                                        ),
                                                                                                        child: Text(
                                                                                                          '${_TransModels[index].expname}',
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
                                                                                                          '${_TransModels[index].docno}',
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
                                                                                                Row(
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      'ประเภท : ',
                                                                                                      style: TextStyle(
                                                                                                        color: ManageScreen_Color.Colors_Text2_,
                                                                                                        fontFamily: Font_.Fonts_T,
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                      ),
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: 3,
                                                                                                    ),
                                                                                                    ElevatedButton(
                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                        backgroundColor: typeInstall == 0 ? Colors.grey.shade600 : Colors.grey,
                                                                                                        foregroundColor: PeopleChaoScreen_Color.Colors_Text3_,
                                                                                                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                                                                        elevation: 0,
                                                                                                      ),
                                                                                                      onPressed: () async {
                                                                                                        setStateDialog(() {
                                                                                                          Formterm_.text = '2';
                                                                                                          typeInstall = 0;
                                                                                                        });
                                                                                                      },
                                                                                                      child: const Padding(
                                                                                                        padding: EdgeInsets.all(2.0),
                                                                                                        child: Text('ตามงวด', style: TextStyle(fontFamily: Font_.Fonts_T)),
                                                                                                      ),
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: 5,
                                                                                                    ),
                                                                                                    ElevatedButton(
                                                                                                      style: ElevatedButton.styleFrom(
                                                                                                        backgroundColor: typeInstall == 1 ? Colors.grey.shade600 : Colors.grey,
                                                                                                        foregroundColor: PeopleChaoScreen_Color.Colors_Text3_,
                                                                                                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                                                                        elevation: 0,
                                                                                                      ),
                                                                                                      onPressed: () async {
                                                                                                        // รวมทุกอย่างใน setStateDialog เดียว
                                                                                                        setStateDialog(() {
                                                                                                          typeInstall = 1;

                                                                                                          // แบ่งครึ่งอย่างมีการปัด และรักษายอดรวม
                                                                                                          final parts = _splitHalf2(total);
                                                                                                          final a1 = parts[0];
                                                                                                          final a2 = parts[1];

                                                                                                          // ใส่ลงช่อง โดยฟอร์แมต 2 ตำแหน่ง
                                                                                                          FormTotalterm1.text = a1 > 0 ? _fmt2(a1) : '';
                                                                                                          FormTotalterm2.text = a2 > 0 ? _fmt2(a2) : '';

                                                                                                          // (ออปชัน) เคลียร์จำนวนงวดทิ้ง เพราะโหมดนี้คุมงวดเป็น 2 งวดตายตัว
                                                                                                          Formterm_.text = '2';
                                                                                                        });
                                                                                                        setStateDialog(() {
                                                                                                          final n = int.tryParse(Formterm_.text) ?? 0;
                                                                                                          if (n >= 2 && n <= 6) {
                                                                                                            // ✅ ทุกอย่างต้องอยู่ใน setStateDialog เดียว
                                                                                                            setStateDialog(() {
                                                                                                              _ensureControllers(n);
                                                                                                              _seedEven(n, total); // เติมค่าเริ่มต้นแบบหารเท่า
                                                                                                              _recalcLast(total); // ชดเชยงวดสุดท้ายให้รวม = total เป๊ะ
                                                                                                            });
                                                                                                          }
                                                                                                        });

                                                                                                        // (ออปชัน) revalidate ฟอร์มทันทีให้ปุ่ม "ยืนยัน" อัปเดต
                                                                                                        // formKey.currentState?.validate();
                                                                                                      },
                                                                                                      child: const Padding(
                                                                                                        padding: EdgeInsets.all(2.0),
                                                                                                        child: Text('ตามจำนวนเงิน', style: TextStyle(fontFamily: Font_.Fonts_T)),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                const SizedBox(height: 12),

                                                                                                // จำนวนงวด
                                                                                                Text(
                                                                                                  (typeInstall == 0) ? 'ระบุจำนวนงวด' : 'ระบุข้อมูลให้ครบถ้วน',
                                                                                                  style: TextStyle(
                                                                                                    color: ManageScreen_Color.Colors_Text2_,
                                                                                                    fontFamily: Font_.Fonts_T,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 8),
                                                                                                if (_dialogRefresh == true) ...[
                                                                                                  CircularProgressIndicator(strokeWidth: 2, color: Colors.green)
                                                                                                ] else if (typeInstall == 0) ...[
                                                                                                  TextFormField(
                                                                                                    controller: Formterm_,
                                                                                                    maxLines: 1,
                                                                                                    maxLength: 1,
                                                                                                    keyboardType: TextInputType.number,
                                                                                                    cursorColor: Colors.blueGrey,
                                                                                                    validator: (v) {
                                                                                                      final t = v?.trim() ?? '';
                                                                                                      final n = int.tryParse(t);
                                                                                                      if (n == null || n < 2 || n > 7) return 'ใส่ข้อมูลให้ครบถ้วน';
                                                                                                      return null;
                                                                                                    },
                                                                                                    onChanged: (v) {
                                                                                                      setStateDialog(() {
                                                                                                        termCtrl.text = v;
                                                                                                      });
                                                                                                    },
                                                                                                    decoration: InputDecoration(
                                                                                                      hintText: 'ระบุจำนวนงวดการแบ่งชำระ',
                                                                                                      counterText: '',
                                                                                                      isDense: true,
                                                                                                      filled: true,
                                                                                                      fillColor: Colors.white.withOpacity(0.3),
                                                                                                      labelText: 'จำนวนงวด',
                                                                                                      labelStyle: TextStyle(
                                                                                                        color: ManageScreen_Color.Colors_Text2_,
                                                                                                        fontFamily: Font_.Fonts_T,
                                                                                                      ),
                                                                                                      enabledBorder: OutlineInputBorder(
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                                                                                                      ),
                                                                                                      focusedBorder: OutlineInputBorder(
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        borderSide: const BorderSide(color: Colors.black, width: 1),
                                                                                                      ),
                                                                                                      errorBorder: OutlineInputBorder(
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        borderSide: const BorderSide(color: Colors.red, width: 1),
                                                                                                      ),
                                                                                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.all(2.0),
                                                                                                    child: Text(
                                                                                                      (typeInstall == 0) ? '# หมายเหตุ:จำนวนงวดต้องอยู่ในช่วงระหว่าง 2 - 6 งวด' : '# หมายเหตุ:ประเภทแบ่งตามจำนวนเงิน จำนวนงวดสูงสุดคือ 2 - 6 งวด',
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 12,
                                                                                                        color: Colors.grey,
                                                                                                        fontFamily: Font_.Fonts_T,
                                                                                                        fontWeight: FontWeight.w400,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ] else ...[
                                                                                                  StatefulBuilder(builder: (ctx, setStateDialog) {
                                                                                                    return SizedBox(
                                                                                                      child: Column(
                                                                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                                        children: [
                                                                                                          // จำนวนงวด
                                                                                                          TextFormField(
                                                                                                            controller: termCtrl,
                                                                                                            maxLines: 1,
                                                                                                            keyboardType: TextInputType.number,
                                                                                                            inputFormatters: [
                                                                                                              FilteringTextInputFormatter.digitsOnly
                                                                                                            ],
                                                                                                            cursorColor: Colors.blueGrey,
                                                                                                            validator: (v) {
                                                                                                              final n = int.tryParse((v ?? '').trim());
                                                                                                              // ✅ ให้สอดคล้องกันทั้งหมด: ใช้ 2–6
                                                                                                              if (n == null || n < 2 || n > 6) return 'ใส่จำนวนงวด 2-6';
                                                                                                              return null;
                                                                                                            },
                                                                                                            onChanged: (v) {
                                                                                                              final n = int.tryParse(v) ?? 0;
                                                                                                              if (n >= 2 && n <= 6) {
                                                                                                                // ✅ ทุกอย่างต้องอยู่ใน setStateDialog เดียว
                                                                                                                setStateDialog(() {
                                                                                                                  Formterm_.text = v;
                                                                                                                  _ensureControllers(n);
                                                                                                                  _seedEven(n, total); // เติมค่าเริ่มต้นแบบหารเท่า
                                                                                                                  _recalcLast(total); // ชดเชยงวดสุดท้ายให้รวม = total เป๊ะ
                                                                                                                });
                                                                                                              }
                                                                                                            },
                                                                                                            decoration: InputDecoration(
                                                                                                              // ✅ hint ให้ตรงกับ validator
                                                                                                              hintText: 'ระบุจำนวนงวดการแบ่งชำระ (2-6)',
                                                                                                              counterText: '',
                                                                                                              isDense: true,
                                                                                                              filled: true,
                                                                                                              fillColor: Colors.white.withOpacity(0.3),
                                                                                                              labelText: 'จำนวนงวด',
                                                                                                              labelStyle: TextStyle(
                                                                                                                color: ManageScreen_Color.Colors_Text2_,
                                                                                                                fontFamily: Font_.Fonts_T,
                                                                                                              ),
                                                                                                              enabledBorder: const OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                                                borderSide: BorderSide(color: Colors.grey, width: 1),
                                                                                                              ),
                                                                                                              focusedBorder: const OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                                                borderSide: BorderSide(color: Colors.black, width: 1),
                                                                                                              ),
                                                                                                              errorBorder: const OutlineInputBorder(
                                                                                                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                                                                borderSide: BorderSide(color: Colors.red, width: 1),
                                                                                                              ),
                                                                                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                            ),
                                                                                                          ),

                                                                                                          const SizedBox(height: 12),
                                                                                                          Align(
                                                                                                            alignment: Alignment.topLeft,
                                                                                                            child: Padding(
                                                                                                              padding: const EdgeInsets.all(2.0),
                                                                                                              child: Text(
                                                                                                                (typeInstall == 0) ? '# หมายเหตุ:จำนวนงวดต้องอยู่ในช่วงระหว่าง 2 - 6 งวด' : '# หมายเหตุ:ประเภทแบ่งตามจำนวนเงิน จำนวนงวดสูงสุดคือ 2 - 6 งวด',
                                                                                                                style: TextStyle(
                                                                                                                  fontSize: 12,
                                                                                                                  color: Colors.grey,
                                                                                                                  fontFamily: Font_.Fonts_T,
                                                                                                                  fontWeight: FontWeight.w400,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          const SizedBox(height: 12),
                                                                                                          // ฟิลด์เงินแต่ละงวด
                                                                                                          Builder(builder: (_) {
                                                                                                            final n = int.tryParse(termCtrl.text.trim()) ?? 0;
                                                                                                            _ensureControllers(n.clamp(0, 7));
                                                                                                            return Column(
                                                                                                              children: [
                                                                                                                for (int i = 0; i < _amountCtrls.length; i++)
                                                                                                                  Padding(
                                                                                                                    padding: const EdgeInsets.only(bottom: 8, top: 2),
                                                                                                                    child: TextFormField(
                                                                                                                      controller: _amountCtrls[i],
                                                                                                                      readOnly: i == _amountCtrls.length - 1, // งวดสุดท้ายปรับอัตโนมัติ
                                                                                                                      maxLines: 1,
                                                                                                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                                                                                      inputFormatters: [moneyFormatter],
                                                                                                                      cursorColor: Colors.blueGrey,
                                                                                                                      validator: (v) {
                                                                                                                        final amt = _toAmount(v);
                                                                                                                        if (amt <= 0) return 'ต้องมากกว่า 0';
                                                                                                                        // ตรวจรวมทั้งชุด = total (ปัด 2 ตำแหน่ง)
                                                                                                                        double sum = 0.0;
                                                                                                                        for (int j = 0; j < _amountCtrls.length; j++) {
                                                                                                                          final val = j == i ? amt : _toAmount(_amountCtrls[j].text);
                                                                                                                          sum += val;
                                                                                                                        }
                                                                                                                        final okSum = double.parse(sum.toStringAsFixed(2)) == double.parse(total.toStringAsFixed(2));
                                                                                                                        if (i == _amountCtrls.length - 1) {
                                                                                                                          // สำหรับงวดสุดท้าย ควรให้ผ่านเฉพาะเมื่อผลรวมตรง
                                                                                                                          if (!okSum) return 'ยอดรวมไม่เท่ากับ ${_fmt2(total)}';
                                                                                                                        }
                                                                                                                        return null;
                                                                                                                      },
                                                                                                                      onChanged: (value) {
                                                                                                                        // ทุกครั้งที่แก้งวดก่อนหน้า ให้คำนวณงวดสุดท้ายใหม่
                                                                                                                        if (i < _amountCtrls.length - 1) {
                                                                                                                          setState(() => _recalcLast(total));
                                                                                                                        }
                                                                                                                      },
                                                                                                                      onEditingComplete: () {
                                                                                                                        // ฟอร์แมตตัวที่แก้ (งวดสุดท้ายถูกฟอร์แมตใน _recalcLast แล้ว)
                                                                                                                        if (i < _amountCtrls.length - 1) {
                                                                                                                          final amt = _toAmount(_amountCtrls[i].text);
                                                                                                                          if (amt > 0) {
                                                                                                                            _amountCtrls[i].text = _fmt2(amt);
                                                                                                                            _recalcLast(total);
                                                                                                                          }
                                                                                                                        }
                                                                                                                      },
                                                                                                                      decoration: InputDecoration(
                                                                                                                        hintText: (i == _amountCtrls.length - 1) ? 'ยอดสุทธิคงเหลืองวดที่ ${i + 1}' : 'ระบุยอดสุทธิงวดที่ ${i + 1}',
                                                                                                                        counterText: '',
                                                                                                                        isDense: true,
                                                                                                                        filled: true,
                                                                                                                        fillColor: Colors.white.withOpacity(0.3),
                                                                                                                        labelText: (i == _amountCtrls.length - 1) ? 'ยอดสุทธิคงเหลืองวดที่ ${i + 1}' : 'ระบุยอดสุทธิงวดที่ ${i + 1}',
                                                                                                                        labelStyle: TextStyle(
                                                                                                                          color: ManageScreen_Color.Colors_Text2_,
                                                                                                                          fontFamily: Font_.Fonts_T,
                                                                                                                        ),
                                                                                                                        enabledBorder: OutlineInputBorder(
                                                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                                                          borderSide: const BorderSide(color: Colors.grey, width: 1),
                                                                                                                        ),
                                                                                                                        focusedBorder: OutlineInputBorder(
                                                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                                                          borderSide: const BorderSide(color: Colors.black, width: 1),
                                                                                                                        ),
                                                                                                                        errorBorder: OutlineInputBorder(
                                                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                                                          borderSide: const BorderSide(color: Colors.red, width: 1),
                                                                                                                        ),
                                                                                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),

                                                                                                                const SizedBox(height: 12),
                                                                                                                // แสดงสรุปรวม
                                                                                                                Builder(builder: (_) {
                                                                                                                  double sum = 0.0;
                                                                                                                  for (final c in _amountCtrls) sum += _toAmount(c.text);
                                                                                                                  return Align(
                                                                                                                    alignment: Alignment.centerRight,
                                                                                                                    child: Text(
                                                                                                                      'รวม: ${_fmt2(sum)} / ต้องการ: ${_fmt2(total)}',
                                                                                                                      style: TextStyle(
                                                                                                                        fontSize: 14,
                                                                                                                        color: Colors.grey,
                                                                                                                        fontFamily: Font_.Fonts_T,
                                                                                                                        fontWeight: FontWeight.w400,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  );
                                                                                                                }),
                                                                                                              ],
                                                                                                            );
                                                                                                          }),
                                                                                                        ],
                                                                                                      ),
                                                                                                    );
                                                                                                  })
                                                                                                ],
                                                                                                // Padding(
                                                                                                //   padding: const EdgeInsets.all(2.0),
                                                                                                //   child: Text(
                                                                                                //     (typeInstall == 0) ? '# หมายเหตุ:จำนวนงวดต้องอยู่ในช่วงระหว่าง 2 - 6 งวด' : '# หมายเหตุ:ประเภทแบ่งตามจำนวนเงิน จำนวนงวดสูงสุดคือ 2 - 6 งวด',
                                                                                                //     style: TextStyle(
                                                                                                //       fontSize: 12,
                                                                                                //       color: Colors.grey,
                                                                                                //       fontFamily: Font_.Fonts_T,
                                                                                                //       fontWeight: FontWeight.w400,
                                                                                                //     ),
                                                                                                //   ),
                                                                                                // ),
                                                                                                const SizedBox(height: 12),

                                                                                                // คำเตือน
                                                                                                Container(
                                                                                                  width: double.infinity,
                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: Colors.orange.withOpacity(0.06),
                                                                                                    borderRadius: BorderRadius.circular(10),
                                                                                                    border: Border.all(color: Colors.orange.withOpacity(0.18)),
                                                                                                  ),
                                                                                                  child: Text(
                                                                                                    'ระบุเหตุผลการแบ่งชำระให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                                                                                                    style: TextStyle(
                                                                                                      color: Colors.orange.shade700,
                                                                                                      fontFamily: Font_.Fonts_T,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 12),

                                                                                                // หมายเหตุ
                                                                                                Text(
                                                                                                  'ใส่หมายเหตุ',
                                                                                                  style: TextStyle(
                                                                                                    color: ManageScreen_Color.Colors_Text2_,
                                                                                                    fontFamily: Font_.Fonts_T,
                                                                                                    fontWeight: FontWeight.w600,
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 6),
                                                                                                TextFormField(
                                                                                                  controller: Formposlok_,
                                                                                                  maxLines: 2,
                                                                                                  maxLength: 200,
                                                                                                  cursorColor: Colors.blueGrey,
                                                                                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'ใส่ข้อมูลให้ครบถ้วน' : null,
                                                                                                  decoration: InputDecoration(
                                                                                                    hintText: 'ระบุเหตุผลการแบ่งชำระ',
                                                                                                    counterText: '',
                                                                                                    isDense: true,
                                                                                                    filled: true,
                                                                                                    fillColor: Colors.white.withOpacity(0.3),
                                                                                                    labelText: 'หมายเหตุ',
                                                                                                    labelStyle: TextStyle(
                                                                                                      color: ManageScreen_Color.Colors_Text2_,
                                                                                                      fontFamily: Font_.Fonts_T,
                                                                                                    ),
                                                                                                    enabledBorder: OutlineInputBorder(
                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                      borderSide: const BorderSide(color: Colors.grey, width: 1),
                                                                                                    ),
                                                                                                    focusedBorder: OutlineInputBorder(
                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                      borderSide: const BorderSide(color: Colors.black, width: 1),
                                                                                                    ),
                                                                                                    errorBorder: OutlineInputBorder(
                                                                                                      borderRadius: BorderRadius.circular(10),
                                                                                                      borderSide: const BorderSide(color: Colors.red, width: 1),
                                                                                                    ),
                                                                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),

                                                                                        // ปุ่มยืนยัน: ฟังทั้ง Formposlok_ และ Formterm_
                                                                                        actions: [
                                                                                          AnimatedBuilder(
                                                                                            animation: Listenable.merge([
                                                                                              Formposlok_,
                                                                                              Formterm_,
                                                                                              FormTotalterm1,
                                                                                              FormTotalterm2
                                                                                            ]),
                                                                                            builder: (ctx, _) {
                                                                                              final hasRemark = Formposlok_.text.trim().isNotEmpty;
                                                                                              bool canSubmit = false;

                                                                                              if (typeInstall == 0) {
                                                                                                final term = int.tryParse(Formterm_.text.trim());
                                                                                                canSubmit = hasRemark && term != null && term >= 2 && term <= 6 && !isLoading;
                                                                                              } else {
                                                                                                final a1 = _toAmount(FormTotalterm1.text);
                                                                                                final a2 = _toAmount(FormTotalterm2.text);
                                                                                                final sumOk = double.parse((a1 + a2).toStringAsFixed(2)) == double.parse(total.toStringAsFixed(2));
                                                                                                canSubmit = hasRemark && a1 > 0 && a2 > 0 && sumOk && !isLoading;
                                                                                              }

                                                                                              return SizedBox(
                                                                                                width: double.infinity,
                                                                                                child: ElevatedButton.icon(
                                                                                                  onPressed: canSubmit ? _submit : null,
                                                                                                  icon: isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline),
                                                                                                  label: const Text('ยืนยัน', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T)),
                                                                                                  style: ElevatedButton.styleFrom(
                                                                                                    backgroundColor: Colors.black,
                                                                                                    minimumSize: const Size.fromHeight(44),
                                                                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                            );
                                                                          } finally {
                                                                            _dialogOpen =
                                                                                false;
                                                                            if (mounted)
                                                                              setState(() => _tapBusy = false);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              const EdgeInsets.all(10),
                                                                          width: MediaQuery.of(context)
                                                                              .size
                                                                              .width,
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Translate.TranslateAndSetText(
                                                                                  'แบ่งชำระ',
                                                                                  PeopleChaoScreen_Color.Colors_Text1_,
                                                                                  TextAlign.center,
                                                                                  null,
                                                                                  Font_.Fonts_T,
                                                                                  13,
                                                                                  1,
                                                                                ),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (_TransModels[
                                                                              index]
                                                                          .ucost ==
                                                                      '0.00')
                                                                    PopupMenuItem(
                                                                      child: InkWell(
                                                                          onTap: () async {
                                                                            String?
                                                                                selectedSer =
                                                                                "1"; // ค่าเริ่มต้น: ser = 1
                                                                            double
                                                                                vatPercent =
                                                                                7;
                                                                            double
                                                                                whtPercent =
                                                                                3;
                                                                            // ตัวอย่างข้อมูล JSON
                                                                            final List<Map<String, String>>
                                                                                vatOptions =
                                                                                [
                                                                              {
                                                                                "ser": "1",
                                                                                "name": "ก่อน VAT"
                                                                              }
                                                                              // ,
                                                                              // {
                                                                              //   "ser": "2",
                                                                              //   "name":
                                                                              //       "ยอดสุทธิ"
                                                                              // },
                                                                              // {
                                                                              //   "ser": "3",
                                                                              //   "name":
                                                                              //       "หลังหักภาษี ณ ที่จ่าย"
                                                                              // },
                                                                            ];
                                                                            int vatRate =
                                                                                0;
                                                                            int whtRate =
                                                                                0;

                                                                            final TextEditingController
                                                                                _pvatController =
                                                                                TextEditingController(text: '0');
                                                                            final TextEditingController
                                                                                _vatController =
                                                                                TextEditingController(text: '0');
                                                                            final TextEditingController
                                                                                _whtController =
                                                                                TextEditingController(text: '0');
                                                                            final _totalController =
                                                                                TextEditingController(text: '0');
                                                                            setState(() {
                                                                              Formposlokdispri_.text = '0.00';
                                                                            });
                                                                            Widget
                                                                                _headerCell(String text) {
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(2.0),
                                                                                child: Text(
                                                                                  text,
                                                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: Font_.Fonts_T),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              );
                                                                            }

                                                                            Widget
                                                                                _valueCell(String value) {
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(2.0),
                                                                                child: Text(
                                                                                  value,
                                                                                  style: TextStyle(fontSize: 12, fontFamily: Font_.Fonts_T),
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              );
                                                                            }

                                                                            Widget _buildPercentageRow(
                                                                                String type,
                                                                                String label,
                                                                                TextEditingController controllers) {
                                                                              return Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  SizedBox(
                                                                                      child: Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        label,
                                                                                        style: TextStyle(fontSize: 14, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                      ),
                                                                                    ],
                                                                                  )),
                                                                                  // InkWell(onTap: () {}, child: Icon(Icons.info_outline)),

                                                                                  Container(
                                                                                    height: 50,
                                                                                    width: 160,
                                                                                    padding: EdgeInsets.all(2),
                                                                                    decoration: BoxDecoration(
                                                                                      color: Colors.grey.shade200,
                                                                                      borderRadius: BorderRadius.circular(6),
                                                                                    ),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          width: 130,
                                                                                          child: TextField(
                                                                                            // controller:
                                                                                            //     _priceController,
                                                                                            textAlign: TextAlign.end,
                                                                                            keyboardType: TextInputType.number,
                                                                                            controller: controllers,
                                                                                            readOnly: true,
                                                                                            style: TextStyle(fontSize: 14, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                            decoration: InputDecoration(
                                                                                              contentPadding: EdgeInsets.zero,
                                                                                              // prefixText: '฿',
                                                                                              border: OutlineInputBorder(),
                                                                                            ),
                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                              // for below version 2 use this
                                                                                              FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
                                                                                              // for version 2 and greater youcan also use this
                                                                                              // FilteringTextInputFormatter.digitsOnly
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        // Text('${percent.toStringAsFixed(0)}'),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(3.0),
                                                                                          child: Text('฿', style: TextStyle(color: Colors.grey)),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              );
                                                                            }

                                                                            showDialog<String>(
                                                                              context: context,
                                                                              builder: (BuildContext context) => StatefulBuilder(builder: (context, setState) {
                                                                                return AlertDialog(
                                                                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                                  backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                                                                                  titlePadding: const EdgeInsets.all(0.0),
                                                                                  contentPadding: const EdgeInsets.all(10.0),
                                                                                  actionsPadding: const EdgeInsets.all(6.0),
                                                                                  title: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                    children: [
                                                                                      InkWell(
                                                                                        onTap: () async {
                                                                                          setState(() {
                                                                                            Formposlokdispri_.clear();
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.all(4.0),
                                                                                          child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  // title:
                                                                                  //     Row(
                                                                                  //   children: [
                                                                                  //     Expanded(
                                                                                  //       child:
                                                                                  //           Center(
                                                                                  //         child: Translate.TranslateAndSetText('ส่วนลดรายการ', PeopleChaoScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 13, 1),
                                                                                  //         //  Text(
                                                                                  //         //   'ส่วนลดรายการ', // Navigator.pop(context, 'OK');
                                                                                  //         //   style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  //         // ),
                                                                                  //       ),
                                                                                  //     ),
                                                                                  //     Expanded(
                                                                                  //       child:
                                                                                  //           Row(
                                                                                  //         mainAxisAlignment: MainAxisAlignment.end,
                                                                                  //         children: [
                                                                                  //           IconButton(
                                                                                  //               onPressed: () {
                                                                                  //                 setState(() {
                                                                                  //                   Formposlokdispri_.clear();
                                                                                  //                 });
                                                                                  //                 Navigator.pop(context);
                                                                                  //               },
                                                                                  //               icon: Icon(Icons.close, color: Colors.black)),
                                                                                  //         ],
                                                                                  //       ),
                                                                                  //     ),
                                                                                  //   ],
                                                                                  // ),
                                                                                  content: SingleChildScrollView(
                                                                                    child: ListBody(
                                                                                      children: <Widget>[
                                                                                        SizedBox(height: 14),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(4),
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Text(
                                                                                                'ส่วนลด',
                                                                                                style: TextStyle(fontSize: 14, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                              ),
                                                                                              // RichText(
                                                                                              //   text: TextSpan(
                                                                                              //     text: 'ราคา ',
                                                                                              //     style: TextStyle(fontSize: 16, color: Colors.black),
                                                                                              //     children: [
                                                                                              //       TextSpan(
                                                                                              //         text: '${vatOptions.firstWhere((element) => element['ser'] == selectedSer)['name']}',
                                                                                              //         style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
                                                                                              //       ),
                                                                                              //     ],
                                                                                              //   ),
                                                                                              // ),
                                                                                              const SizedBox(height: 8),
                                                                                              Container(
                                                                                                width: 260,
                                                                                                height: 40,
                                                                                                padding: EdgeInsets.symmetric(horizontal: 4),
                                                                                                decoration: BoxDecoration(
                                                                                                  color: Colors.white,
                                                                                                  borderRadius: BorderRadius.circular(6),
                                                                                                  border: Border.all(color: Colors.grey.shade300),
                                                                                                ),
                                                                                                child: DropdownButtonHideUnderline(
                                                                                                  child: DropdownButton<String>(
                                                                                                    borderRadius: BorderRadius.all(Radius.circular(8)),
                                                                                                    isExpanded: true,
                                                                                                    value: selectedSer,
                                                                                                    items: vatOptions.map((option) {
                                                                                                      return DropdownMenuItem<String>(
                                                                                                        value: option['ser'],
                                                                                                        child: Text(
                                                                                                          option['name']!,
                                                                                                          style: TextStyle(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
                                                                                                        ),
                                                                                                      );
                                                                                                    }).toList(),
                                                                                                    onChanged: (newValue) {
                                                                                                      setState(() {
                                                                                                        selectedSer = newValue!;
                                                                                                        _pvatController.text = '0.00';
                                                                                                        _vatController.text = '0.00';
                                                                                                        _whtController.text = '0.00';
                                                                                                        _totalController.text = '0.00';
                                                                                                        Formposlokdispri_.text = '0.00';
                                                                                                      });
                                                                                                    },
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 12),
                                                                                        SizedBox(
                                                                                          height: 40,
                                                                                          child: TextField(
                                                                                            // controller:
                                                                                            //     _priceController,
                                                                                            textAlign: TextAlign.end,
                                                                                            keyboardType: TextInputType.number,
                                                                                            controller: Formposlokdispri_,
                                                                                            onChanged: (value) async {
                                                                                              setState(() {
                                                                                                vatRate = double.parse(_TransModels[index].nvat ?? '0').round();
                                                                                                whtRate = double.parse(_TransModels[index].nwht ?? '0').round();
                                                                                              });
                                                                                              var expSerVat = _TransModels[index].vtype;
                                                                                              var expSerWht = _TransModels[index].wht;

                                                                                              double parsedModelPvat = double.tryParse(_TransModels[index].pvat ?? '0') ?? 0;
                                                                                              double parsedModelTotal = double.tryParse(_TransModels[index].total ?? '0') ?? 0;
                                                                                              double parsedValue = double.tryParse(value ?? '0') ?? 0;

                                                                                              double pvat = parsedModelPvat - parsedValue; // ยอดก่อนvat
                                                                                              double total = parsedModelTotal - parsedValue; // ยอดสุทธิ

                                                                                              setState(() {
                                                                                                if (parsedValue > parsedModelPvat) {
                                                                                                  _pvatController.text = '0.00';
                                                                                                  Formposlokdispri_.text = '0.00';
                                                                                                  _vatController.text = '0.00';
                                                                                                  _whtController.text = '0.00';
                                                                                                  _totalController.text = '0.00';
                                                                                                } else if (parsedValue == parsedModelPvat) {
                                                                                                  _pvatController.text = '0.00';
                                                                                                  // Formposlokdispri_.text = '0.00';
                                                                                                  _vatController.text = '0.00';
                                                                                                  _whtController.text = '0.00';
                                                                                                  _totalController.text = '0.00';
                                                                                                } else {
                                                                                                  _pvatController.text = pvat.toStringAsFixed(2);
                                                                                                }
                                                                                              });
                                                                                              if (parsedValue >= parsedModelPvat) {
                                                                                              } else {
                                                                                                if (total != null && total > 0 && selectedSer.toString() == '2') {
                                                                                                  print('✅ คำนวณย้อนกลับ: รู้ยอดสุทธิ → หาก่อน VAT');

                                                                                                  double base = total / (1 + vatRate / 100 - whtRate / 100);
                                                                                                  double vatAmount = base * vatRate / 100;
                                                                                                  double whtAmount = base * whtRate / 100;

                                                                                                  _pvatController.text = base.toStringAsFixed(2);
                                                                                                  _vatController.text = vatAmount.toStringAsFixed(2);
                                                                                                  _whtController.text = whtAmount.toStringAsFixed(2);
                                                                                                  _totalController.text = total.toStringAsFixed(2);
                                                                                                } else if (pvat != null && pvat > 0 && selectedSer.toString() == '1') {
                                                                                                  print('✅ ✅ คำนวณไปข้างหน้า: รู้ก่อน VAT → หายอดสุทธิ');

                                                                                                  double vatAmount = pvat * vatRate / 100;
                                                                                                  double whtAmount = pvat * whtRate / 100;
                                                                                                  double total = pvat + vatAmount - whtAmount;

                                                                                                  _vatController.text = vatAmount.toStringAsFixed(2);
                                                                                                  _whtController.text = whtAmount.toStringAsFixed(2);
                                                                                                  _totalController.text = total.toStringAsFixed(2);
                                                                                                } else {
                                                                                                  print('❌ กรุณากรอกยอดก่อน VAT หรือยอดสุทธิ');
                                                                                                }
                                                                                              }

                                                                                              // if (total != null && total > 0 && selectedSer.toString() == '2') {
                                                                                              //   print('✅ คำนวณย้อนกลับ: รู้ยอดสุทธิ → หาก่อน VAT');
                                                                                              //   double base = total / (1 + (vatRate / 100) - (whtRate / 100));
                                                                                              //   double vatAmount = base * vatRate / 100;
                                                                                              //   double whtAmount = base * whtRate / 100;
                                                                                              //   _pvatController.text = base.toStringAsFixed(2);
                                                                                              //   _vatController.text = vatAmount.toStringAsFixed(2);
                                                                                              //   _whtController.text = whtAmount.toStringAsFixed(2);
                                                                                              //   _totalController.text = total.toStringAsFixed(2);
                                                                                              // } else if (pvat != null && pvat > 0 && selectedSer.toString() == '1') {
                                                                                              //   print('✅ ✅ คำนวณไปข้างหน้า: รู้ก่อน VAT → หายอดสุทธิ');

                                                                                              //   double vatAmount = pvat * vatRate / 100;
                                                                                              //   double whtAmount = pvat * whtRate / 100;
                                                                                              //   double total = pvat + vatAmount - whtAmount;

                                                                                              //   _vatController.text = vatAmount.toStringAsFixed(2);
                                                                                              //   _whtController.text = whtAmount.toStringAsFixed(2);
                                                                                              //   _totalController.text = total.toStringAsFixed(2);
                                                                                              // } else {
                                                                                              //   print('❌ กรุณากรอกยอดก่อน VAT หรือยอดสุทธิ');
                                                                                              // }
                                                                                            },
                                                                                            decoration: InputDecoration(
                                                                                              prefixText: 'ราคา',
                                                                                              border: OutlineInputBorder(),
                                                                                            ),
                                                                                            inputFormatters: <TextInputFormatter>[
                                                                                              // for below version 2 use this
                                                                                              FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
                                                                                              // for version 2 and greater youcan also use this
                                                                                              // FilteringTextInputFormatter.digitsOnly
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 12),
                                                                                        const Divider(),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.all(4.0),
                                                                                          child: Table(
                                                                                            border: TableBorder.symmetric(
                                                                                              inside: BorderSide(width: 0.5, color: Colors.grey.shade400),
                                                                                            ),
                                                                                            columnWidths: const {
                                                                                              0: FlexColumnWidth(),
                                                                                              1: FlexColumnWidth(),
                                                                                              2: FlexColumnWidth(),
                                                                                              3: FlexColumnWidth(),
                                                                                            },
                                                                                            children: [
                                                                                              TableRow(
                                                                                                decoration: BoxDecoration(color: Colors.grey.shade600),
                                                                                                children: [
                                                                                                  _headerCell('ก่อนVAT'),
                                                                                                  _headerCell('VAT'),
                                                                                                  _headerCell('WHT'),
                                                                                                  _headerCell('ยอดสุทธิ'),
                                                                                                ],
                                                                                              ),
                                                                                              TableRow(
                                                                                                decoration: BoxDecoration(color: Colors.grey.shade100),
                                                                                                children: [
                                                                                                  _valueCell('${nFormat.format(double.parse(_TransModels[index].pvat!))}'),
                                                                                                  _valueCell('${nFormat.format(double.parse(_TransModels[index].vat!))}'),
                                                                                                  _valueCell('${nFormat.format(double.parse(_TransModels[index].wht!))}'),
                                                                                                  _valueCell('${nFormat.format(double.parse(_TransModels[index].total!))}'),
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        Center(
                                                                                            child: Icon(
                                                                                          Icons.sync_rounded,
                                                                                          color: Colors.blue,
                                                                                        )),
                                                                                        Center(
                                                                                          child: Text(
                                                                                            'ผลการคำนวน',
                                                                                            style: TextStyle(fontSize: 16, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(height: 12),
                                                                                        _buildPercentageRow('', 'ก่อนVAT', _pvatController),
                                                                                        SizedBox(height: 12),
                                                                                        _buildPercentageRow('VAT', 'ภาษีมูลค่าเพิ่ม (VAT $vatRate%)', _vatController),
                                                                                        SizedBox(height: 8),
                                                                                        _buildPercentageRow('WHT', 'หักภาษี ณ ที่จ่าย (WHT $whtRate%)', _whtController),
                                                                                        SizedBox(height: 8),
                                                                                        _buildPercentageRow('Total', 'ยอดสุทธิ', _totalController),
                                                                                        SizedBox(height: 16),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  actions: [
                                                                                    Center(
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                        child: ElevatedButton(
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            backgroundColor: Colors.green,
                                                                                            minimumSize: Size(double.infinity, 48),
                                                                                          ),
                                                                                          onPressed: (Formposlokdispri_.text.isEmpty || double.parse(Formposlokdispri_.text) <= 0)
                                                                                              ? null
                                                                                              : () async {
                                                                                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                                  var ren = preferences.getString('renTalSer');
                                                                                                  var user = preferences.getString('ser');
                                                                                                  var sertran = _TransModels[index].ser;

                                                                                                  final velText = Formposlokdispri_.text.trim();
                                                                                                  final pvatText = _pvatController.text.trim();
                                                                                                  final vatText = _vatController.text.trim();
                                                                                                  final whtText = _whtController.text.trim();
                                                                                                  final totalText = _totalController.text.trim();

                                                                                                  final disuser = double.tryParse(velText);
                                                                                                  final pvat = double.tryParse(pvatText);
                                                                                                  final vat = double.tryParse(vatText);
                                                                                                  final wht = double.tryParse(whtText);
                                                                                                  final total = double.tryParse(totalText);
                                                                                                  // setState(() {
                                                                                                  //   total_dislist = double.tryParse(velText);
                                                                                                  // });

                                                                                                  if (disuser == null || vat == null || wht == null || total == null) {
                                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                                      const SnackBar(
                                                                                                        content: Text('ข้อมูลไม่ถูกต้อง', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
                                                                                                      ),
                                                                                                    );
                                                                                                    return;
                                                                                                  }

                                                                                                  if (vat <= total) {
                                                                                                    final url = Uri.parse('${MyConstant().domain}/c_trans_selectdis_v2.php');
                                                                                                    print('📡 POST to: $url');

                                                                                                    try {
                                                                                                      final response = await httpClient.post(
                                                                                                        url,
                                                                                                        // headers: {
                                                                                                        //   'Content-Type': 'application/x-www-form-urlencoded'
                                                                                                        // },
                                                                                                        body: {
                                                                                                          'isAdd': 'true',
                                                                                                          'ren': ren ?? '',
                                                                                                          'disuser': disuser.toStringAsFixed(2),
                                                                                                          'sertran': sertran ?? '',
                                                                                                          'pvatnew': pvat!.toStringAsFixed(2),
                                                                                                          'vatnew': vat.toStringAsFixed(2),
                                                                                                          'whtnew': wht.toStringAsFixed(2),
                                                                                                          'totalnew': total.toStringAsFixed(2),
                                                                                                        },
                                                                                                      );

                                                                                                      // print({
                                                                                                      //   'isAdd': 'true',
                                                                                                      //   'ren': ren ?? '',
                                                                                                      //   'disuser': disuser.toStringAsFixed(2),
                                                                                                      //   'sertran': sertran ?? '',
                                                                                                      //   'pvatnew': pvat!.toStringAsFixed(2),
                                                                                                      //   'vatnew': vat.toStringAsFixed(2),
                                                                                                      //   'whtnew': wht.toStringAsFixed(2),
                                                                                                      //   'totalnew': total.toStringAsFixed(2),
                                                                                                      //   // 'Formposlokdispri_': Formposlokdispri_.text.trim(),
                                                                                                      // });

                                                                                                      if (response.statusCode == 200) {
                                                                                                        final result = json.decode(response.body);
                                                                                                        // print('✅ RESPONSE: $result');

                                                                                                        if (result['success'].toString() == 'true') {
                                                                                                          setState(() {
                                                                                                            red_Trans_select();
                                                                                                            red_Trans_bill();
                                                                                                            Formposlokdispri_.clear();
                                                                                                          });
                                                                                                        } else {
                                                                                                          setState(() {
                                                                                                            Formposlokdispri_.clear();
                                                                                                          });
                                                                                                        }

                                                                                                        Navigator.pop(context);
                                                                                                      } else {
                                                                                                        print('❌ Server Error: ${response.statusCode}');
                                                                                                        Navigator.pop(context);
                                                                                                      }
                                                                                                    } catch (e) {
                                                                                                      print('❌ Exception: $e');
                                                                                                      Navigator.pop(context);
                                                                                                    }
                                                                                                  } else {
                                                                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                                                                      SnackBar(
                                                                                                        content: Text('Total Error  $disuser // $total ', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
                                                                                                      ),
                                                                                                    );
                                                                                                  }
                                                                                                },
                                                                                          child: Text('บันทึก', style: TextStyle(fontSize: 16)),
                                                                                        ),
                                                                                      ),
                                                                                    )
                                                                                  ],
                                                                                  // actions: <Widget>[
                                                                                  //   Form(
                                                                                  //     key:
                                                                                  //         _formKey,
                                                                                  //     child:
                                                                                  //         Column(
                                                                                  //       children: [
                                                                                  //         Padding(
                                                                                  //           padding: EdgeInsets.all(8.0),
                                                                                  //           child: TextFormField(
                                                                                  //             controller: Formposlokdispri_,
                                                                                  //             // obscureText:
                                                                                  //             //     true,
                                                                                  //             validator: (value) {
                                                                                  //               if (value == null || value.isEmpty) {
                                                                                  //                 return ' ';
                                                                                  //               }
                                                                                  //               // if (int.parse(value.toString()) < 13) {
                                                                                  //               //   return '< 13';
                                                                                  //               // }
                                                                                  //               return null;
                                                                                  //             },

                                                                                  //             onFieldSubmitted: (val) async {
                                                                                  //               if (_formKey.currentState!.validate()) {
                                                                                  //                 SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                  //                 var ren = preferences.getString('renTalSer');
                                                                                  //                 var user = preferences.getString('ser');

                                                                                  //                 var sertran = _TransModels[index].ser;
                                                                                  //                 var vel = Formposlokdispri_.text.trim();
                                                                                  //                 if (double.parse(vel) <= double.parse(_TransModels[index].total!)) {
                                                                                  //                   // print('vel>>>>$vel');
                                                                                  //                   String url = '${MyConstant().domain}/c_trans_select_dis.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';
                                                                                  //                   print('url>>>>$url');
                                                                                  //                   try {
                                                                                  //                     var response = await httpClient.get(Uri.parse(url));

                                                                                  //                     var result = json.decode(response.body);
                                                                                  //                     // print(result);
                                                                                  //                     if (result.toString() == 'true') {
                                                                                  //                       setState(() {
                                                                                  //                         red_Trans_select();
                                                                                  //                         red_Trans_bill();
                                                                                  //                         Formposlokdispri_.clear();
                                                                                  //                       });
                                                                                  //                       Navigator.pop(context);
                                                                                  //                     } else {
                                                                                  //                       setState(() {
                                                                                  //                         Formposlokdispri_.clear();
                                                                                  //                       });

                                                                                  //                       Navigator.pop(context);
                                                                                  //                     }
                                                                                  //                   } catch (e) {}
                                                                                  //                   Navigator.pop(context);
                                                                                  //                 } else {
                                                                                  //                   ScaffoldMessenger.of(context).showSnackBar(
                                                                                  //                     const SnackBar(content: Text('Total Error', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                  //                   );
                                                                                  //                 }
                                                                                  //               }
                                                                                  //             },
                                                                                  //             cursorColor: Colors.green,
                                                                                  //             decoration: InputDecoration(
                                                                                  //                 fillColor: Colors.white.withOpacity(0.3),
                                                                                  //                 filled: true,
                                                                                  //                 // prefixIcon: const Icon(Icons.water,
                                                                                  //                 //     color: Colors.blue),
                                                                                  //                 // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                                  //                 focusedBorder: const OutlineInputBorder(
                                                                                  //                   borderRadius: BorderRadius.only(
                                                                                  //                     topRight: Radius.circular(15),
                                                                                  //                     topLeft: Radius.circular(15),
                                                                                  //                     bottomRight: Radius.circular(15),
                                                                                  //                     bottomLeft: Radius.circular(15),
                                                                                  //                   ),
                                                                                  //                   borderSide: BorderSide(
                                                                                  //                     width: 1,
                                                                                  //                     color: Colors.black,
                                                                                  //                   ),
                                                                                  //                 ),
                                                                                  //                 enabledBorder: const OutlineInputBorder(
                                                                                  //                   borderRadius: BorderRadius.only(
                                                                                  //                     topRight: Radius.circular(15),
                                                                                  //                     topLeft: Radius.circular(15),
                                                                                  //                     bottomRight: Radius.circular(15),
                                                                                  //                     bottomLeft: Radius.circular(15),
                                                                                  //                   ),
                                                                                  //                   borderSide: BorderSide(
                                                                                  //                     width: 1,
                                                                                  //                     color: Colors.grey,
                                                                                  //                   ),
                                                                                  //                 ),
                                                                                  //                 labelText: 'Total',
                                                                                  //                 labelStyle: const TextStyle(
                                                                                  //                   color: ManageScreen_Color.Colors_Text2_,
                                                                                  //                   // fontWeight:
                                                                                  //                   //     FontWeight.bold,
                                                                                  //                   fontFamily: Font_.Fonts_T,
                                                                                  //                 )),
                                                                                  //             // inputFormatters: <TextInputFormatter>[
                                                                                  //             //   // for below version 2 use this
                                                                                  //             //   FilteringTextInputFormatter.allow(
                                                                                  //             //       RegExp(r'[0-9]')),
                                                                                  //             //   // for version 2 and greater youcan also use this
                                                                                  //             //   FilteringTextInputFormatter.digitsOnly
                                                                                  //             // ],
                                                                                  //           ),
                                                                                  //         ),
                                                                                  //         Padding(
                                                                                  //           padding: const EdgeInsets.all(8.0),
                                                                                  //           child: Row(
                                                                                  //             mainAxisAlignment: MainAxisAlignment.center,
                                                                                  //             children: [
                                                                                  //               Container(
                                                                                  //                 width: 150,
                                                                                  //                 decoration: const BoxDecoration(
                                                                                  //                   color: Colors.black,
                                                                                  //                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                                                                                  //                 ),
                                                                                  //                 padding: const EdgeInsets.all(8.0),
                                                                                  //                 child: TextButton(
                                                                                  //                   onPressed: () async {
                                                                                  //                     if (_formKey.currentState!.validate()) {
                                                                                  //                       SharedPreferences preferences = await SharedPreferences.getInstance();
                                                                                  //                       var ren = preferences.getString('renTalSer');
                                                                                  //                       var user = preferences.getString('ser');

                                                                                  //                       var sertran = _TransModels[index].ser;
                                                                                  //                       var vel = Formposlokdispri_.text.trim();
                                                                                  //                       if (double.parse(vel) <= double.parse(_TransModels[index].total!)) {
                                                                                  //                         // print('vel>>>>$vel');
                                                                                  //                         String url = '${MyConstant().domain}/c_trans_select_dis.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';
                                                                                  //                         print('url>>>>$url');
                                                                                  //                         try {
                                                                                  //                           var response = await httpClient.get(Uri.parse(url));

                                                                                  //                           var result = json.decode(response.body);
                                                                                  //                           // print(result);
                                                                                  //                           if (result.toString() == 'true') {
                                                                                  //                             setState(() {
                                                                                  //                               red_Trans_select();
                                                                                  //                               red_Trans_bill();
                                                                                  //                               Formposlokdispri_.clear();
                                                                                  //                             });
                                                                                  //                             Navigator.pop(context);
                                                                                  //                           } else {
                                                                                  //                             setState(() {
                                                                                  //                               Formposlokdispri_.clear();
                                                                                  //                             });

                                                                                  //                             Navigator.pop(context);
                                                                                  //                           }
                                                                                  //                         } catch (e) {}
                                                                                  //                         Navigator.pop(context);
                                                                                  //                       } else {
                                                                                  //                         ScaffoldMessenger.of(context).showSnackBar(
                                                                                  //                           const SnackBar(content: Text('Total Error', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
                                                                                  //                         );
                                                                                  //                       }
                                                                                  //                     }
                                                                                  //                   },
                                                                                  //                   child: const Text(
                                                                                  //                     'Submit',
                                                                                  //                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
                                                                                  //                   ),
                                                                                  //                 ),
                                                                                  //               ),
                                                                                  //             ],
                                                                                  //           ),
                                                                                  //         ),
                                                                                  //       ],
                                                                                  //     ),
                                                                                  //   ),
                                                                                  // ],
                                                                                );
                                                                              }),
                                                                            );
                                                                          },
                                                                          child: Container(
                                                                              padding: const EdgeInsets.all(10),
                                                                              width: MediaQuery.of(context).size.width,
                                                                              child: Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Translate.TranslateAndSetText('ส่วนลดรายการ', PeopleChaoScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 13, 1),
                                                                                  )
                                                                                ],
                                                                              ))),
                                                                    ),
                                                                ],
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      10,
                                                                  maxFontSize:
                                                                      15,
                                                                  maxLines: 1,
                                                                  '${index + 1}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          _TransModels[index]
                                                                      .dtype ==
                                                                  'KU'
                                                              ? '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransModels[index].duedate} 00:00:00'))}'
                                                              : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransModels[index].date} 00:00:00'))}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          '${_TransModels[index].name}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
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
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          '${nFormat.format(double.parse(_TransModels[index].tqty!))}',
                                                          //'${_TransModels[index].tqty}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
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
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          '${_TransModels[index].unit_con}',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.end,
                                                          style:
                                                              const TextStyle(
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
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          nFormat.format(double.tryParse(
                                                                  _TransModels[
                                                                              index]
                                                                          .pvat ??
                                                                      '0') ??
                                                              0),
                                                          // _TransModels[index].qty_con ==
                                                          //         '0.00'
                                                          //     ? '${nFormat.format(double.parse(_TransModels[index].amt_con!))}'
                                                          //     //'${_TransModels[index].amt_con}'
                                                          //     : '${nFormat.format(double.parse(_TransModels[index].qty_con!))}',
                                                          // //'${_TransModels[index].qty_con}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
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
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          '${nFormat.format(double.parse(_TransModels[index].vat!))}',
                                                          //'${_TransModels[index].qty_con}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
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
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          '${nFormat.format(double.parse(_TransModels[index].wht!))}',
                                                          //'${_TransModels[index].qty_con}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
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
                                                          minFontSize: 10,
                                                          maxFontSize: 15,
                                                          maxLines: 1,
                                                          '${nFormat.format(double.parse(_TransModels[index].total!))}',
                                                          // '${_TransModels[index].pvat}',
                                                          textAlign:
                                                              TextAlign.end,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  //fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 44,
                                                        child: Center(
                                                          child: IconButton(
                                                              onPressed: () {
                                                                de_Trans_select(
                                                                    index);
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .remove_circle,
                                                                color:
                                                                    Colors.red,
                                                              )),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  double.parse(_TransModels[
                                                                  index]
                                                              .dis!) ==
                                                          0.0
                                                      ? SizedBox()
                                                      : Row(
                                                          children: [
                                                            Container(
                                                              width: 50,
                                                              child: SizedBox(),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Icon(
                                                                Icons
                                                                    .subdirectory_arrow_right,
                                                                // color: Colors.red,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Translate
                                                                  .TranslateAndSetText(
                                                                      'ส่วนลด',
                                                                      Colors
                                                                          .red,
                                                                      TextAlign
                                                                          .center,
                                                                      null,
                                                                      Font_
                                                                          .Fonts_T,
                                                                      14,
                                                                      1),
                                                              //  AutoSizeText(
                                                              //   minFontSize: 10,
                                                              //   maxFontSize: 15,
                                                              //   maxLines: 1,
                                                              //   'ส่วนลด',
                                                              //   textAlign:
                                                              //       TextAlign.start,
                                                              //   style:
                                                              //       const TextStyle(
                                                              //           color: Colors
                                                              //               .red,
                                                              //           //fontWeight: FontWeight.bold,
                                                              //           fontFamily: Font_
                                                              //               .Fonts_T),
                                                              // ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: SizedBox(),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: SizedBox(),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: SizedBox(),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: SizedBox(),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  AutoSizeText(
                                                                minFontSize: 10,
                                                                maxFontSize: 15,
                                                                maxLines: 1,
                                                                '${nFormat.format(double.parse(_TransModels[index].dis!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: const TextStyle(
                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                    //fontWeight: FontWeight.bold,
                                                                    fontFamily: Font_.Fonts_T),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 1,
                                                                child:
                                                                    SizedBox()
                                                                // Center(
                                                                //   child: IconButton(
                                                                //       onPressed: () {

                                                                //         // de_Trans_select(index);
                                                                //       },
                                                                //       icon: const Icon(
                                                                //         Icons.remove_circle,
                                                                //         color: Colors.red,
                                                                //       )),
                                                                // ),
                                                                ),
                                                          ],
                                                        ),
                                                  for (int inde = 0;
                                                      inde <
                                                          transFineModels
                                                              .length;
                                                      inde++)
                                                    _TransModels[index].docno !=
                                                            transFineModels[
                                                                    inde]
                                                                .docno
                                                        ? SizedBox()
                                                        : Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    SizedBox(),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child:
                                                                    SizedBox(),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      8,
                                                                  maxFontSize:
                                                                      12,
                                                                  maxLines: 1,
                                                                  '${transFineModels[inde].expname}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style: const TextStyle(
                                                                      color: Colors.red,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    SizedBox(),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      8,
                                                                  maxFontSize:
                                                                      12,
                                                                  maxLines: 1,
                                                                  double.parse(transFineModels[inde]
                                                                              .vat!) ==
                                                                          0.0
                                                                      ? ''
                                                                      : '${nFormat.format(double.parse(transFineModels[inde].pvat!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: const TextStyle(
                                                                      color: Colors.red,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      8,
                                                                  maxFontSize:
                                                                      12,
                                                                  maxLines: 1,
                                                                  double.parse(transFineModels[inde]
                                                                              .vat!) ==
                                                                          0.0
                                                                      ? ''
                                                                      : '${nFormat.format(double.parse(transFineModels[inde].vat!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: const TextStyle(
                                                                      color: Colors.red,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    SizedBox(),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    AutoSizeText(
                                                                  minFontSize:
                                                                      8,
                                                                  maxFontSize:
                                                                      12,
                                                                  maxLines: 1,
                                                                  '${nFormat.format(double.parse(transFineModels[inde].total!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
                                                                  textAlign:
                                                                      TextAlign
                                                                          .end,
                                                                  style: const TextStyle(
                                                                      color: Colors.red,
                                                                      //fontWeight: FontWeight.bold,
                                                                      fontFamily: Font_.Fonts_T),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 1,
                                                                child:
                                                                    IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          SharedPreferences
                                                                              preferences =
                                                                              await SharedPreferences.getInstance();
                                                                          var renTal_lavel = int.parse(preferences
                                                                              .getString('lavel')
                                                                              .toString());
                                                                          if (renTal_lavel >=
                                                                              4) {
                                                                            de_Trans_select_fine(inde);
                                                                          } else {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Translate.TranslateAndSetText('User ของท่านไม่สามารถทำการลบค่าปรับเกินกำหนดชำระได้ ', Colors.red, TextAlign.center, null, Font_.Fonts_T, 14, 1),
                                                                                // Text('User ของท่านไม่สามารถทำการลบค่าปรับเกินกำหนดชำระได้ ')
                                                                              ),
                                                                            );
                                                                          }
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .remove_circle,
                                                                          color:
                                                                              Colors.red,
                                                                        )),
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
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: const BoxDecoration(
                                          color:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              topRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                        ),
                                        child: Column(
                                          children: [
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      _VocherModels.length == 0
                                                          ? Expanded(
                                                              child: SizedBox(),
                                                            )
                                                          : Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    Container(
                                                                  height: 150,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Container(
                                                                        width:
                                                                            150,
                                                                        color: Colors
                                                                            .indigo,
                                                                        child:
                                                                            TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                                      // title: const Text('AlertDialog Title'),
                                                                                      content: SingleChildScrollView(
                                                                                          child: Column(
                                                                                        children: [
                                                                                          for (int index = 0; index < _VocherModels.length; index++)
                                                                                            Container(
                                                                                              color: ser_vocher == _VocherModels[index].ser ? Colors.blue.shade100 : Colors.blueGrey.shade100,
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.all(8.0),
                                                                                                child: TextButton(
                                                                                                  onPressed: () {
                                                                                                    print('${_VocherModels[index].ser}');
                                                                                                    Navigator.pop(context);
                                                                                                    var valuenum = double.parse('${_VocherModels[index].pvat}');
                                                                                                    // var sum = ((sum_amt * valuenum) / 100);

                                                                                                    setState(() {
                                                                                                      sum_dis = valuenum;
                                                                                                      sum_disamt.text = valuenum.toStringAsFixed(2).toString();
                                                                                                      ser_vocher = _VocherModels[index].ser;
                                                                                                    });

                                                                                                    print('sum_dis $sum_dis');
                                                                                                  },
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Expanded(
                                                                                                        child: Text(
                                                                                                          '${_VocherModels[index].descr}',
                                                                                                          style: TextStyle(color: Colors.black),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Expanded(
                                                                                                        child: Text(
                                                                                                          nFormat.format(double.parse('${_VocherModels[index].pvat}')),
                                                                                                          textAlign: TextAlign.end,
                                                                                                          style: TextStyle(color: Colors.black),
                                                                                                        ),
                                                                                                      ),
                                                                                                      Expanded(
                                                                                                        child: Icon(
                                                                                                          Icons.arrow_right_alt,
                                                                                                          color: Colors.black,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                        ],
                                                                                      )));
                                                                                });
                                                                          },
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(8.0),
                                                                            child:
                                                                                Text(
                                                                              'Vocher',
                                                                              style: TextStyle(
                                                                                  color: Colors.white,
                                                                                  //fontWeight: FontWeight.bold,
                                                                                  fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                      Expanded(
                                                        child:
                                                            // Container(
                                                            //   color: Colors.grey.shade300,
                                                            //   // height: 100,
                                                            //   width: 600,
                                                            //   padding:
                                                            //       const EdgeInsets.all(8.0),
                                                            Card(
                                                          color: Colors
                                                              .grey.shade300,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                          clipBehavior:
                                                              Clip.antiAlias,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                                children: [
                                                                  sum_tran_fine ==
                                                                          0
                                                                      ? SizedBox()
                                                                      : Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Translate.TranslateAndSetText('ค่าปรับ', Colors.red, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                                                                              // AutoSizeText(
                                                                              //   minFontSize: 10,
                                                                              //   maxFontSize: 15,
                                                                              //   'ค่าปรับ',
                                                                              //   style: TextStyle(
                                                                              //       color: Colors
                                                                              //           .red,
                                                                              //       //fontWeight: FontWeight.bold,
                                                                              //       fontFamily: Font_
                                                                              //           .Fonts_T),
                                                                              // ),
                                                                            ),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: AutoSizeText(
                                                                                minFontSize: 8,
                                                                                maxFontSize: 12,
                                                                                textAlign: TextAlign.end,
                                                                                '${nFormat.format(sum_tran_fine)}',
                                                                                style: const TextStyle(
                                                                                    color: Colors.red,
                                                                                    //fontWeight: FontWeight.bold,
                                                                                    fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                  sum_tran_fine ==
                                                                          0
                                                                      ? SizedBox()
                                                                      : Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Translate.TranslateAndSetText('ยอดค่าบริการ', PeopleChaoScreen_Color.Colors_Text2_, TextAlign.start, null, Font_.Fonts_T, 12, 1),
                                                                              // AutoSizeText(
                                                                              //   minFontSize: 10,
                                                                              //   maxFontSize: 15,
                                                                              //   'ยอดค่าบริการ',
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
                                                                                maxFontSize: 12,
                                                                                textAlign: TextAlign.end,
                                                                                '${nFormat.format(sum_amt - sum_tran_fine)}',
                                                                                style: const TextStyle(
                                                                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                    //fontWeight: FontWeight.bold,
                                                                                    fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                  Row(
                                                                    children: [
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          'รวม(บาท)',
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          '${nFormat.format(sum_pvat)}',
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          'ภาษีมูลค่าเพิ่ม(vat)',
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          '${nFormat.format(sum_vat)}',
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          'หัก ณ ที่จ่าย',
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          '${nFormat.format(sum_wht)}',
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
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
                                                                        child: Translate.TranslateAndSetText(
                                                                            'ส่วนลดรายการ',
                                                                            PeopleChaoScreen_Color.Colors_Text2_,
                                                                            TextAlign.start,
                                                                            null,
                                                                            Font_.Fonts_T,
                                                                            12,
                                                                            1),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          '${nFormat.format(sum_tran_dis)}',
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  // const Divider(),
                                                                  Row(
                                                                    children: [
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          'ยอดรวม',
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          '${nFormat.format(sum_amt)}',
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const AutoSizeText(
                                                                              minFontSize: 12,
                                                                              maxFontSize: 14,
                                                                              'ส่วนลด(ท้ายบิลยอดรวมVat)',
                                                                              // 'ส่วนลด',
                                                                              style: TextStyle(
                                                                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                  //fontWeight: FontWeight.bold,
                                                                                  fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 4,
                                                                            ),
                                                                            SizedBox(
                                                                              width: 60,
                                                                              height: 20,
                                                                              child: TextFormField(
                                                                                keyboardType: TextInputType.number,
                                                                                controller: sum_disp,
                                                                                onFieldSubmitted: (value) async {
                                                                                  var valuenum = double.parse(value);
                                                                                  var sum = ((sum_amt * valuenum) / 100);

                                                                                  setState(() {
                                                                                    red_Vocher();
                                                                                    ser_vocher = '';
                                                                                    sum_dis = sum;
                                                                                    sum_disamt.text = sum.toString();
                                                                                  });

                                                                                  print('sum_dis $sum_dis');
                                                                                },
                                                                                cursorColor: Colors.black,
                                                                                decoration: InputDecoration(
                                                                                    fillColor: Colors.white.withOpacity(0.3),
                                                                                    filled: true,
                                                                                    // prefixIcon:
                                                                                    //     const Icon(Icons.person, color: Colors.black),
                                                                                    // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                                    focusedBorder: const OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.only(
                                                                                        topRight: Radius.circular(5),
                                                                                        topLeft: Radius.circular(5),
                                                                                        bottomRight: Radius.circular(5),
                                                                                        bottomLeft: Radius.circular(5),
                                                                                      ),
                                                                                      borderSide: BorderSide(
                                                                                        width: 1,
                                                                                        color: Colors.black,
                                                                                      ),
                                                                                    ),
                                                                                    enabledBorder: const OutlineInputBorder(
                                                                                      borderRadius: BorderRadius.only(
                                                                                        topRight: Radius.circular(5),
                                                                                        topLeft: Radius.circular(5),
                                                                                        bottomRight: Radius.circular(5),
                                                                                        bottomLeft: Radius.circular(5),
                                                                                      ),
                                                                                      borderSide: BorderSide(
                                                                                        width: 1,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                    // labelText: 'ระบุชื่อร้านค้า',
                                                                                    labelStyle: const TextStyle(
                                                                                        color: Colors.black54,
                                                                                        fontSize: 8,

                                                                                        //fontWeight: FontWeight.bold,
                                                                                        fontFamily: Font_.Fonts_T)),
                                                                                inputFormatters: <TextInputFormatter>[
                                                                                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
                                                                                  // FilteringTextInputFormatter.digitsOnly
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const AutoSizeText(
                                                                              minFontSize: 12,
                                                                              maxFontSize: 14,
                                                                              '%',
                                                                              style: TextStyle(
                                                                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                                  //fontWeight: FontWeight.bold,
                                                                                  fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              20,
                                                                          height:
                                                                              20,
                                                                          child:
                                                                              TextFormField(
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            showCursor:
                                                                                true,
                                                                            //add this line
                                                                            readOnly:
                                                                                false,

                                                                            // initialValue: sum_disamt.text,
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                            controller:
                                                                                sum_disamt,
                                                                            onFieldSubmitted:
                                                                                (value) async {
                                                                              var valuenum = double.parse(value);

                                                                              setState(() {
                                                                                sum_dis = valuenum;
                                                                                // sum_disamt.text =
                                                                                //     nFormat.format(sum_disamt);
                                                                                sum_disp.clear();
                                                                              });

                                                                              print('sum_dis $sum_dis');
                                                                            },
                                                                            cursorColor:
                                                                                Colors.black,
                                                                            decoration: InputDecoration(
                                                                                fillColor: Colors.white.withOpacity(0.3),
                                                                                filled: true,
                                                                                // prefixIcon:
                                                                                //     const Icon(Icons.person, color: Colors.black),
                                                                                // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                                focusedBorder: const OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.only(
                                                                                    topRight: Radius.circular(5),
                                                                                    topLeft: Radius.circular(5),
                                                                                    bottomRight: Radius.circular(5),
                                                                                    bottomLeft: Radius.circular(5),
                                                                                  ),
                                                                                  borderSide: BorderSide(
                                                                                    width: 1,
                                                                                    color: Colors.black,
                                                                                  ),
                                                                                ),
                                                                                enabledBorder: const OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.only(
                                                                                    topRight: Radius.circular(5),
                                                                                    topLeft: Radius.circular(5),
                                                                                    bottomRight: Radius.circular(5),
                                                                                    bottomLeft: Radius.circular(5),
                                                                                  ),
                                                                                  borderSide: BorderSide(
                                                                                    // width: 1,
                                                                                    color: Colors.grey,
                                                                                  ),
                                                                                ),
                                                                                // labelText: 'ระบุชื่อร้านค้า',
                                                                                labelStyle: const TextStyle(
                                                                                    color: Colors.black54,
                                                                                    fontSize: 8,

                                                                                    //fontWeight: FontWeight.bold,
                                                                                    fontFamily: Font_.Fonts_T)),
                                                                            inputFormatters: <TextInputFormatter>[
                                                                              FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
                                                                              // FilteringTextInputFormatter.digitsOnly
                                                                            ],
                                                                          ),
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
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          'ยอดชำระ',
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                          '${nFormat.format(sum_amt - double.parse(sum_disamt.text))}',
                                                                          style: const TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              //fontWeight: FontWeight.bold,
                                                                              fontFamily: Font_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
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
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              12,
                                                                          maxFontSize:
                                                                              14,
                                                                          'รายการทั้งหมด : ${_TransModels.length}',
                                                                          style: TextStyle(
                                                                              color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontFamily: FontWeight_.Fonts_T),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: ElevatedButton
                                                                            .icon(
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.green,
                                                                            foregroundColor:
                                                                                Colors.white,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(6),
                                                                            ),
                                                                          ),
                                                                          icon: const Icon(
                                                                              Icons.receipt_outlined,
                                                                              size: 18),
                                                                          label: const Text(
                                                                              'ดำเนินการต่อ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T)),
                                                                          onPressed: _TransModels.length < 1
                                                                              ? null
                                                                              : () async {
                                                                                  dialogOk(context);
                                                                                },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ]),
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );

    // Container(
    //   // height: MediaQuery.of(context).size.height,
    //   // width: MediaQuery.of(context).size.width,
    //   child: ScrollConfiguration(
    //     behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
    //       PointerDeviceKind.touch,
    //       PointerDeviceKind.mouse,
    //     }),
    //     child: SingleChildScrollView(
    //       scrollDirection: Axis.horizontal,
    //       dragStartBehavior: DragStartBehavior.start,
    //       child: ConstrainedBox(
    //         constraints: BoxConstraints(
    //             maxWidth: MediaQuery.of(context).size.width,
    //             maxHeight: MediaQuery.of(context).size.height),
    //         // height: MediaQuery.of(context).size.height,
    //         // width: MediaQuery.of(context).size.width - 250,
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Expanded(
    //               flex: 1,
    //               child: Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: Container(
    //                   color: Colors.amber, child: Text(w.toString()),
    //                   // ... โค้ดเดิมทั้งหมดของคุณ ...
    //                 ),
    //               ),
    //             ),
    //             Expanded(
    //               flex: 2,
    //               child: Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: Container(
    //                   color: Colors.amber,
    //                   // ... โค้ดเดิมทั้งหมดของคุณ ...
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    // Container(
    //     width: MediaQuery.of(context).size.width,
    //     height: MediaQuery.of(context).size.height,
    //     child:
    // ScrollConfiguration(
    //       behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
    //         PointerDeviceKind.touch,
    //         PointerDeviceKind.mouse,
    //       }),
    //       child: SingleChildScrollView(
    //         scrollDirection: Axis.horizontal,
    //         dragStartBehavior: DragStartBehavior.start,
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             // =============== Pretty Billing (no classes, only widget functions) ===============
    //             Expanded(child: Bills_(context)),
    //             Expanded(
    //               flex: 3,
    //               child:
    // Padding(
    //                 padding: const EdgeInsets.all(8.0),
    //                 child: Container(
    //                   decoration: BoxDecoration(
    //                     color: Colors.white,
    //                     borderRadius: BorderRadius.circular(14),
    //                     boxShadow: [
    //                       BoxShadow(
    //                           blurRadius: 18,
    //                           color: Colors.black.withOpacity(.06),
    //                           offset: const Offset(0, 2))
    //                     ],
    //                     border: Border.all(
    //                         color: Colors.grey.shade400, width: 0.5),
    //                   ),
    //                   // width: MediaQuery.of(context).size.width * 0.52,
    //                   child: Column(
    //                     children: [
    //                       billHeaderTable(context),
    //                       Container(
    //                         height: 290,
    //                         decoration: const BoxDecoration(
    //                           color: AppbackgroundColor.Sub_Abg_Colors,
    //                           borderRadius: BorderRadius.only(
    //                             topLeft: Radius.circular(0),
    //                             topRight: Radius.circular(0),
    //                             bottomLeft: Radius.circular(0),
    //                             bottomRight: Radius.circular(0),
    //                           ),
    //                           // border: Border.all(
    //                           //     color: Colors.grey, width: 1),
    //                         ),
    //                         child: ListView.builder(
    //                           // controller: _scrollController2,
    //                           // itemExtent: 50,
    //                           physics:
    //                               const AlwaysScrollableScrollPhysics(),
    //                           shrinkWrap: true,
    //                           itemCount: _TransModels.length,
    //                           itemBuilder:
    //                               (BuildContext context, int index) {
    //                             return Container(
    //                               padding: EdgeInsets.all(4.0),
    //                               // padding: const EdgeInsets.symmetric(
    //                               //     vertical: 8, horizontal: 16),
    //                               decoration: BoxDecoration(
    //                                 border: const Border(
    //                                   bottom: BorderSide(
    //                                     color: Colors.black12,
    //                                     width: 1,
    //                                   ),
    //                                 ),
    //                               ),
    //                               child: Column(
    //                                 children: [
    //                                   Row(
    //                                     children: [
    //                                       Container(
    //                                         width: 50,
    //                                         child: open_dislis == 0
    //                                             ? AutoSizeText(
    //                                                 minFontSize: 10,
    //                                                 maxFontSize: 15,
    //                                                 maxLines: 1,
    //                                                 '${index + 1}',
    //                                                 textAlign:
    //                                                     TextAlign.center,
    //                                                 overflow: TextOverflow
    //                                                     .ellipsis,
    //                                                 style: const TextStyle(
    //                                                     color: PeopleChaoScreen_Color
    //                                                         .Colors_Text2_,
    //                                                     //fontWeight: FontWeight.bold,
    //                                                     fontFamily:
    //                                                         Font_.Fonts_T),
    //                                               )
    //                                             : PopupMenuButton(
    //                                                 itemBuilder:
    //                                                     (BuildContext
    //                                                             context) =>
    //                                                         [
    //                                                   // PopupMenuItem(
    //                                                   //   child: InkWell(
    //                                                   //       onTap: () async {
    //                                                   //         // de_Trans_item(index);
    //                                                   //         showDialog<
    //                                                   //             String>(
    //                                                   //           context:
    //                                                   //               context,
    //                                                   //           builder: (BuildContext
    //                                                   //                   context) =>
    //                                                   //               AlertDialog(
    //                                                   //             shape: const RoundedRectangleBorder(
    //                                                   //                 borderRadius:
    //                                                   //                     BorderRadius.all(
    //                                                   //                         Radius.circular(20.0))),
    //                                                   //             title: Row(
    //                                                   //               children: [
    //                                                   //                 Expanded(
    //                                                   //                   child:
    //                                                   //                       Center(
    //                                                   //                     child: Translate.TranslateAndSetText(
    //                                                   //                         'รหัสผ่านการทำรายการ',
    //                                                   //                         PeopleChaoScreen_Color.Colors_Text1_,
    //                                                   //                         TextAlign.center,
    //                                                   //                         FontWeight.bold,
    //                                                   //                         FontWeight_.Fonts_T,
    //                                                   //                         13,
    //                                                   //                         1),
    //                                                   //                     //     Text(
    //                                                   //                     //   'รหัสผ่านการทำรายการ', // Navigator.pop(context, 'OK');
    //                                                   //                     //   style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
    //                                                   //                     // ),
    //                                                   //                   ),
    //                                                   //                 ),
    //                                                   //                 Expanded(
    //                                                   //                   child:
    //                                                   //                       Row(
    //                                                   //                     mainAxisAlignment:
    //                                                   //                         MainAxisAlignment.end,
    //                                                   //                     children: [
    //                                                   //                       IconButton(
    //                                                   //                           onPressed: () {
    //                                                   //                             setState(() {
    //                                                   //                               Formpasslok_.clear();
    //                                                   //                               Formposlok_.clear();
    //                                                   //                             });
    //                                                   //                             Navigator.pop(context);
    //                                                   //                           },
    //                                                   //                           icon: Icon(Icons.close, color: Colors.black)),
    //                                                   //                     ],
    //                                                   //                   ),
    //                                                   //                 ),
    //                                                   //               ],
    //                                                   //             ),
    //                                                   //             actions: <Widget>[
    //                                                   //               Form(
    //                                                   //                 key:
    //                                                   //                     _formKey,
    //                                                   //                 child:
    //                                                   //                     Column(
    //                                                   //                   children: [
    //                                                   //                     Padding(
    //                                                   //                       padding:
    //                                                   //                           EdgeInsets.all(8.0),
    //                                                   //                       child:
    //                                                   //                           TextFormField(
    //                                                   //                         controller: Formposlok_,
    //                                                   //                         // obscureText:
    //                                                   //                         //     true,
    //                                                   //                         validator: (value) {
    //                                                   //                           if (value == null || value.isEmpty) {
    //                                                   //                             return ' ';
    //                                                   //                           }
    //                                                   //                           // if (int.parse(value.toString()) < 13) {
    //                                                   //                           //   return '< 13';
    //                                                   //                           // }
    //                                                   //                           return null;
    //                                                   //                         },

    //                                                   //                         // maxLength: 13,
    //                                                   //                         cursorColor: Colors.green,
    //                                                   //                         decoration: InputDecoration(
    //                                                   //                             fillColor: Colors.white.withOpacity(0.3),
    //                                                   //                             filled: true,
    //                                                   //                             // prefixIcon: const Icon(Icons.water,
    //                                                   //                             //     color: Colors.blue),
    //                                                   //                             // suffixIcon: Icon(Icons.clear, color: Colors.black),
    //                                                   //                             focusedBorder: const OutlineInputBorder(
    //                                                   //                               borderRadius: BorderRadius.only(
    //                                                   //                                 topRight: Radius.circular(15),
    //                                                   //                                 topLeft: Radius.circular(15),
    //                                                   //                                 bottomRight: Radius.circular(15),
    //                                                   //                                 bottomLeft: Radius.circular(15),
    //                                                   //                               ),
    //                                                   //                               borderSide: BorderSide(
    //                                                   //                                 width: 1,
    //                                                   //                                 color: Colors.black,
    //                                                   //                               ),
    //                                                   //                             ),
    //                                                   //                             enabledBorder: const OutlineInputBorder(
    //                                                   //                               borderRadius: BorderRadius.only(
    //                                                   //                                 topRight: Radius.circular(15),
    //                                                   //                                 topLeft: Radius.circular(15),
    //                                                   //                                 bottomRight: Radius.circular(15),
    //                                                   //                                 bottomLeft: Radius.circular(15),
    //                                                   //                               ),
    //                                                   //                               borderSide: BorderSide(
    //                                                   //                                 width: 1,
    //                                                   //                                 color: Colors.grey,
    //                                                   //                               ),
    //                                                   //                             ),
    //                                                   //                             labelText: 'หมายเหตุ-Note',
    //                                                   //                             labelStyle: const TextStyle(
    //                                                   //                               color: ManageScreen_Color.Colors_Text2_,
    //                                                   //                               // fontWeight:
    //                                                   //                               //     FontWeight.bold,
    //                                                   //                               fontFamily: Font_.Fonts_T,
    //                                                   //                             )),
    //                                                   //                         // inputFormatters: <TextInputFormatter>[
    //                                                   //                         //   // for below version 2 use this
    //                                                   //                         //   FilteringTextInputFormatter.allow(
    //                                                   //                         //       RegExp(r'[0-9]')),
    //                                                   //                         //   // for version 2 and greater youcan also use this
    //                                                   //                         //   FilteringTextInputFormatter.digitsOnly
    //                                                   //                         // ],
    //                                                   //                       ),
    //                                                   //                     ),
    //                                                   //                     Padding(
    //                                                   //                       padding:
    //                                                   //                           EdgeInsets.all(8.0),
    //                                                   //                       child:
    //                                                   //                           TextFormField(
    //                                                   //                         keyboardType: TextInputType.number,
    //                                                   //                         controller: Formpasslok_,
    //                                                   //                         obscureText: true,
    //                                                   //                         validator: (value) {
    //                                                   //                           if (value == null || value.isEmpty) {
    //                                                   //                             return ' ';
    //                                                   //                           }
    //                                                   //                           // if (int.parse(value.toString()) < 13) {
    //                                                   //                           //   return '< 13';
    //                                                   //                           // }
    //                                                   //                           return null;
    //                                                   //                         },
    //                                                   //                         onFieldSubmitted: (value) async {
    //                                                   //                           if (_formKey.currentState!.validate()) {
    //                                                   //                             SharedPreferences preferences = await SharedPreferences.getInstance();
    //                                                   //                             var ren = preferences.getString('renTalSer');
    //                                                   //                             var user = preferences.getString('ser');
    //                                                   //                             // print('value>>>>$value');
    //                                                   //                             String url = '${MyConstant().domain}/GC_Passcode.php?isAdd=true&puser=$value&ren=$ren';

    //                                                   //                             try {
    //                                                   //                               var response = await httpClient.get(Uri.parse(url));

    //                                                   //                               var result = json.decode(response.body);
    //                                                   //                               // print(result);
    //                                                   //                               if (result.toString() == 'true') {
    //                                                   //                                 de_Trans_item(index);
    //                                                   //                               } else {
    //                                                   //                                 setState(() {
    //                                                   //                                   Formpasslok_.clear();
    //                                                   //                                   Formposlok_.clear();
    //                                                   //                                 });
    //                                                   //                                 ScaffoldMessenger.of(context).showSnackBar(
    //                                                   //                                   SnackBar(content: Text('Password error !!', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    //                                                   //                                 );
    //                                                   //                                 Navigator.pop(context, 'OK');
    //                                                   //                                 Navigator.pop(context, 'OK');
    //                                                   //                               }
    //                                                   //                             } catch (e) {}
    //                                                   //                           }
    //                                                   //                         },

    //                                                   //                         // maxLength: 13,
    //                                                   //                         cursorColor: Colors.green,
    //                                                   //                         decoration: InputDecoration(
    //                                                   //                             fillColor: Colors.white.withOpacity(0.3),
    //                                                   //                             filled: true,
    //                                                   //                             // prefixIcon: const Icon(Icons.water,
    //                                                   //                             //     color: Colors.blue),
    //                                                   //                             // suffixIcon: Icon(Icons.clear, color: Colors.black),
    //                                                   //                             focusedBorder: const OutlineInputBorder(
    //                                                   //                               borderRadius: BorderRadius.only(
    //                                                   //                                 topRight: Radius.circular(15),
    //                                                   //                                 topLeft: Radius.circular(15),
    //                                                   //                                 bottomRight: Radius.circular(15),
    //                                                   //                                 bottomLeft: Radius.circular(15),
    //                                                   //                               ),
    //                                                   //                               borderSide: BorderSide(
    //                                                   //                                 width: 1,
    //                                                   //                                 color: Colors.black,
    //                                                   //                               ),
    //                                                   //                             ),
    //                                                   //                             enabledBorder: const OutlineInputBorder(
    //                                                   //                               borderRadius: BorderRadius.only(
    //                                                   //                                 topRight: Radius.circular(15),
    //                                                   //                                 topLeft: Radius.circular(15),
    //                                                   //                                 bottomRight: Radius.circular(15),
    //                                                   //                                 bottomLeft: Radius.circular(15),
    //                                                   //                               ),
    //                                                   //                               borderSide: BorderSide(
    //                                                   //                                 width: 1,
    //                                                   //                                 color: Colors.grey,
    //                                                   //                               ),
    //                                                   //                             ),
    //                                                   //                             labelText: 'Password',
    //                                                   //                             labelStyle: const TextStyle(
    //                                                   //                               color: ManageScreen_Color.Colors_Text2_,
    //                                                   //                               // fontWeight:
    //                                                   //                               //     FontWeight.bold,
    //                                                   //                               fontFamily: Font_.Fonts_T,
    //                                                   //                             )),
    //                                                   //                         // inputFormatters: <TextInputFormatter>[
    //                                                   //                         //   // for below version 2 use this
    //                                                   //                         //   FilteringTextInputFormatter.allow(
    //                                                   //                         //       RegExp(r'[0-9]')),
    //                                                   //                         //   // for version 2 and greater youcan also use this
    //                                                   //                         //   FilteringTextInputFormatter.digitsOnly
    //                                                   //                         // ],
    //                                                   //                       ),
    //                                                   //                     ),
    //                                                   //                     Padding(
    //                                                   //                       padding:
    //                                                   //                           const EdgeInsets.all(8.0),
    //                                                   //                       child:
    //                                                   //                           Row(
    //                                                   //                         mainAxisAlignment: MainAxisAlignment.center,
    //                                                   //                         children: [
    //                                                   //                           Container(
    //                                                   //                             width: 150,
    //                                                   //                             decoration: const BoxDecoration(
    //                                                   //                               color: Colors.black,
    //                                                   //                               borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
    //                                                   //                             ),
    //                                                   //                             padding: const EdgeInsets.all(8.0),
    //                                                   //                             child: TextButton(
    //                                                   //                               onPressed: () async {
    //                                                   //                                 if (_formKey.currentState!.validate()) {
    //                                                   //                                   SharedPreferences preferences = await SharedPreferences.getInstance();
    //                                                   //                                   var ren = preferences.getString('renTalSer');
    //                                                   //                                   var user = preferences.getString('ser');
    //                                                   //                                   var vel = Formpasslok_.text.trim();
    //                                                   //                                   // print('vel>>>>$vel');
    //                                                   //                                   String url = '${MyConstant().domain}/GC_Passcode.php?isAdd=true&puser=$vel&ren=$ren';

    //                                                   //                                   try {
    //                                                   //                                     var response = await httpClient.get(Uri.parse(url));

    //                                                   //                                     var result = json.decode(response.body);
    //                                                   //                                     // print(result);
    //                                                   //                                     if (result.toString() == 'true') {
    //                                                   //                                       de_Trans_item(index);
    //                                                   //                                     } else {
    //                                                   //                                       setState(() {
    //                                                   //                                         Formpasslok_.clear();
    //                                                   //                                         Formposlok_.clear();
    //                                                   //                                       });
    //                                                   //                                       ScaffoldMessenger.of(context).showSnackBar(
    //                                                   //                                         SnackBar(content: Text('Password Error !!', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    //                                                   //                                       );
    //                                                   //                                       Navigator.pop(context, 'OK');
    //                                                   //                                       // Navigator.pop(context, 'OK');
    //                                                   //                                     }
    //                                                   //                                   } catch (e) {}
    //                                                   //                                 }
    //                                                   //                               },
    //                                                   //                               child: const Text(
    //                                                   //                                 'Submit',
    //                                                   //                                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
    //                                                   //                               ),
    //                                                   //                             ),
    //                                                   //                           ),
    //                                                   //                         ],
    //                                                   //                       ),
    //                                                   //                     ),
    //                                                   //                   ],
    //                                                   //                 ),
    //                                                   //               ),
    //                                                   //             ],
    //                                                   //           ),
    //                                                   //         );
    //                                                   //       },
    //                                                   //       child: Container(
    //                                                   //           padding:
    //                                                   //               const EdgeInsets
    //                                                   //                       .all(
    //                                                   //                   10),
    //                                                   //           width: MediaQuery.of(
    //                                                   //                   context)
    //                                                   //               .size
    //                                                   //               .width,
    //                                                   //           child: Row(
    //                                                   //             children: [
    //                                                   //               Expanded(
    //                                                   //                 child: Translate.TranslateAndSetText(
    //                                                   //                     'ยกเลิกรายการตั้งหนี้',
    //                                                   //                     PeopleChaoScreen_Color
    //                                                   //                         .Colors_Text1_,
    //                                                   //                     TextAlign
    //                                                   //                         .center,
    //                                                   //                     null,
    //                                                   //                     Font_
    //                                                   //                         .Fonts_T,
    //                                                   //                     13,
    //                                                   //                     1),
    //                                                   //                 //         Text(
    //                                                   //                 //   'ยกเลิกรายการตั้งหนี้',
    //                                                   //                 //   overflow:
    //                                                   //                 //       TextOverflow.ellipsis,
    //                                                   //                 //   style: const TextStyle(
    //                                                   //                 //       color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                   //                 //       //fontWeight: FontWeight.bold,
    //                                                   //                 //       fontFamily: Font_.Fonts_T),
    //                                                   //                 // )
    //                                                   //               )
    //                                                   //             ],
    //                                                   //           ))),
    //                                                   // ),
    //                                                   // if (_TransModels[index]
    //                                                   //         .ucost ==
    //                                                   //     '0.00')
    //                                                   //   PopupMenuItem(
    //                                                   //     child: InkWell(
    //                                                   //         onTap: () async {
    //                                                   //           showDialog<
    //                                                   //               String>(
    //                                                   //             context:
    //                                                   //                 context,
    //                                                   //             builder: (BuildContext
    //                                                   //                     context) =>
    //                                                   //                 AlertDialog(
    //                                                   //               shape: const RoundedRectangleBorder(
    //                                                   //                   borderRadius:
    //                                                   //                       BorderRadius.all(Radius.circular(20.0))),
    //                                                   //               title: Row(
    //                                                   //                 children: [
    //                                                   //                   Expanded(
    //                                                   //                     child:
    //                                                   //                         Center(
    //                                                   //                       child: Translate.TranslateAndSetText(
    //                                                   //                           'แบ่งชำระ',
    //                                                   //                           PeopleChaoScreen_Color.Colors_Text1_,
    //                                                   //                           TextAlign.center,
    //                                                   //                           null,
    //                                                   //                           Font_.Fonts_T,
    //                                                   //                           13,
    //                                                   //                           1),
    //                                                   //                       //  Text(
    //                                                   //                       //   'แบ่งชำระ', // Navigator.pop(context, 'OK');
    //                                                   //                       //   style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
    //                                                   //                       // ),
    //                                                   //                     ),
    //                                                   //                   ),
    //                                                   //                   Expanded(
    //                                                   //                     child:
    //                                                   //                         Row(
    //                                                   //                       mainAxisAlignment:
    //                                                   //                           MainAxisAlignment.end,
    //                                                   //                       children: [
    //                                                   //                         IconButton(
    //                                                   //                             onPressed: () {
    //                                                   //                               setState(() {
    //                                                   //                                 Formposlokpri_.clear();
    //                                                   //                               });
    //                                                   //                               Navigator.pop(context);
    //                                                   //                             },
    //                                                   //                             icon: Icon(Icons.close, color: Colors.black)),
    //                                                   //                       ],
    //                                                   //                     ),
    //                                                   //                   ),
    //                                                   //                 ],
    //                                                   //               ),
    //                                                   //               actions: <Widget>[
    //                                                   //                 Form(
    //                                                   //                   key:
    //                                                   //                       _formKey,
    //                                                   //                   child:
    //                                                   //                       Column(
    //                                                   //                     children: [
    //                                                   //                       Padding(
    //                                                   //                         padding: EdgeInsets.all(8.0),
    //                                                   //                         child: TextFormField(
    //                                                   //                           controller: Formposlokpri_,
    //                                                   //                           // obscureText:
    //                                                   //                           //     true,
    //                                                   //                           validator: (value) {
    //                                                   //                             if (value == null || value.isEmpty) {
    //                                                   //                               return ' ';
    //                                                   //                             }
    //                                                   //                             // if (int.parse(value.toString()) < 13) {
    //                                                   //                             //   return '< 13';
    //                                                   //                             // }
    //                                                   //                             return null;
    //                                                   //                           },

    //                                                   //                           onFieldSubmitted: (val) async {
    //                                                   //                             if (_formKey.currentState!.validate()) {
    //                                                   //                               SharedPreferences preferences = await SharedPreferences.getInstance();
    //                                                   //                               var ren = preferences.getString('renTalSer');
    //                                                   //                               var user = preferences.getString('ser');

    //                                                   //                               var sertran = _TransModels[index].ser;
    //                                                   //                               var vel = Formposlokpri_.text.trim();
    //                                                   //                               // print('vel>>>>$vel');
    //                                                   //                               String url = '${MyConstant().domain}/c_trans_select_sub.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';

    //                                                   //                               try {
    //                                                   //                                 var response = await httpClient.get(Uri.parse(url));

    //                                                   //                                 var result = json.decode(response.body);
    //                                                   //                                 // print(result);
    //                                                   //                                 if (result.toString() == 'true') {
    //                                                   //                                   setState(() {
    //                                                   //                                     red_Trans_select();
    //                                                   //                                     red_Trans_bill();
    //                                                   //                                     Formposlokpri_.clear();
    //                                                   //                                   });
    //                                                   //                                   Navigator.pop(context);
    //                                                   //                                 } else {
    //                                                   //                                   setState(() {
    //                                                   //                                     Formposlokpri_.clear();
    //                                                   //                                   });

    //                                                   //                                   Navigator.pop(context);
    //                                                   //                                 }
    //                                                   //                               } catch (e) {}
    //                                                   //                               Navigator.pop(context);
    //                                                   //                             }
    //                                                   //                           },
    //                                                   //                           cursorColor: Colors.green,
    //                                                   //                           decoration: InputDecoration(
    //                                                   //                               fillColor: Colors.white.withOpacity(0.3),
    //                                                   //                               filled: true,
    //                                                   //                               // prefixIcon: const Icon(Icons.water,
    //                                                   //                               //     color: Colors.blue),
    //                                                   //                               // suffixIcon: Icon(Icons.clear, color: Colors.black),
    //                                                   //                               focusedBorder: const OutlineInputBorder(
    //                                                   //                                 borderRadius: BorderRadius.only(
    //                                                   //                                   topRight: Radius.circular(15),
    //                                                   //                                   topLeft: Radius.circular(15),
    //                                                   //                                   bottomRight: Radius.circular(15),
    //                                                   //                                   bottomLeft: Radius.circular(15),
    //                                                   //                                 ),
    //                                                   //                                 borderSide: BorderSide(
    //                                                   //                                   width: 1,
    //                                                   //                                   color: Colors.black,
    //                                                   //                                 ),
    //                                                   //                               ),
    //                                                   //                               enabledBorder: const OutlineInputBorder(
    //                                                   //                                 borderRadius: BorderRadius.only(
    //                                                   //                                   topRight: Radius.circular(15),
    //                                                   //                                   topLeft: Radius.circular(15),
    //                                                   //                                   bottomRight: Radius.circular(15),
    //                                                   //                                   bottomLeft: Radius.circular(15),
    //                                                   //                                 ),
    //                                                   //                                 borderSide: BorderSide(
    //                                                   //                                   width: 1,
    //                                                   //                                   color: Colors.grey,
    //                                                   //                                 ),
    //                                                   //                               ),
    //                                                   //                               labelText: 'Total',
    //                                                   //                               labelStyle: const TextStyle(
    //                                                   //                                 color: ManageScreen_Color.Colors_Text2_,
    //                                                   //                                 // fontWeight:
    //                                                   //                                 //     FontWeight.bold,
    //                                                   //                                 fontFamily: Font_.Fonts_T,
    //                                                   //                               )),
    //                                                   //                           // inputFormatters: <TextInputFormatter>[
    //                                                   //                           //   // for below version 2 use this
    //                                                   //                           //   FilteringTextInputFormatter.allow(
    //                                                   //                           //       RegExp(r'[0-9]')),
    //                                                   //                           //   // for version 2 and greater youcan also use this
    //                                                   //                           //   FilteringTextInputFormatter.digitsOnly
    //                                                   //                           // ],
    //                                                   //                         ),
    //                                                   //                       ),
    //                                                   //                       Padding(
    //                                                   //                         padding: const EdgeInsets.all(8.0),
    //                                                   //                         child: Row(
    //                                                   //                           mainAxisAlignment: MainAxisAlignment.center,
    //                                                   //                           children: [
    //                                                   //                             Container(
    //                                                   //                               width: 150,
    //                                                   //                               decoration: const BoxDecoration(
    //                                                   //                                 color: Colors.black,
    //                                                   //                                 borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
    //                                                   //                               ),
    //                                                   //                               padding: const EdgeInsets.all(8.0),
    //                                                   //                               child: TextButton(
    //                                                   //                                 onPressed: () async {
    //                                                   //                                   if (_formKey.currentState!.validate()) {
    //                                                   //                                     SharedPreferences preferences = await SharedPreferences.getInstance();
    //                                                   //                                     var ren = preferences.getString('renTalSer');
    //                                                   //                                     var user = preferences.getString('ser');

    //                                                   //                                     var sertran = _TransModels[index].ser;
    //                                                   //                                     var vel = Formposlokpri_.text.trim();
    //                                                   //                                     // print('vel>>>>$vel');
    //                                                   //                                     String url = '${MyConstant().domain}/c_trans_select_sub.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';

    //                                                   //                                     try {
    //                                                   //                                       var response = await httpClient.get(Uri.parse(url));

    //                                                   //                                       var result = json.decode(response.body);
    //                                                   //                                       // print(result);
    //                                                   //                                       if (result.toString() == 'true') {
    //                                                   //                                         setState(() {
    //                                                   //                                           red_Trans_select();
    //                                                   //                                           red_Trans_bill();
    //                                                   //                                           Formposlokpri_.clear();
    //                                                   //                                         });
    //                                                   //                                         Navigator.pop(context);
    //                                                   //                                       } else {
    //                                                   //                                         setState(() {
    //                                                   //                                           Formposlokpri_.clear();
    //                                                   //                                         });

    //                                                   //                                         Navigator.pop(context);
    //                                                   //                                       }
    //                                                   //                                     } catch (e) {}
    //                                                   //                                     Navigator.pop(context);
    //                                                   //                                   }
    //                                                   //                                 },
    //                                                   //                                 child: const Text(
    //                                                   //                                   'Submit',
    //                                                   //                                   style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
    //                                                   //                                 ),
    //                                                   //                               ),
    //                                                   //                             ),
    //                                                   //                           ],
    //                                                   //                         ),
    //                                                   //                       ),
    //                                                   //                     ],
    //                                                   //                   ),
    //                                                   //                 ),
    //                                                   //               ],
    //                                                   //             ),
    //                                                   //           );
    //                                                   //         },
    //                                                   //         child: Container(
    //                                                   //             padding:
    //                                                   //                 const EdgeInsets
    //                                                   //                         .all(
    //                                                   //                     10),
    //                                                   //             width: MediaQuery.of(
    //                                                   //                     context)
    //                                                   //                 .size
    //                                                   //                 .width,
    //                                                   //             child: Row(
    //                                                   //               children: [
    //                                                   //                 Expanded(
    //                                                   //                   child: Translate.TranslateAndSetText(
    //                                                   //                       'แบ่งชำระ',
    //                                                   //                       PeopleChaoScreen_Color.Colors_Text1_,
    //                                                   //                       TextAlign.center,
    //                                                   //                       null,
    //                                                   //                       Font_.Fonts_T,
    //                                                   //                       13,
    //                                                   //                       1),
    //                                                   //                   //     Text(
    //                                                   //                   //   'แบ่งชำระ',
    //                                                   //                   //   overflow: TextOverflow.ellipsis,
    //                                                   //                   //   style: const TextStyle(
    //                                                   //                   //       color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                   //                   //       //fontWeight: FontWeight.bold,
    //                                                   //                   //       fontFamily: Font_.Fonts_T),
    //                                                   //                   // )
    //                                                   //                 )
    //                                                   //               ],
    //                                                   //             ))),
    //                                                   //   ),
    //                                                   if (_TransModels[
    //                                                               index]
    //                                                           .ucost ==
    //                                                       '0.00')
    //                                                     PopupMenuItem(
    //                                                       child: InkWell(
    //                                                           onTap:
    //                                                               () async {
    //                                                             String?
    //                                                                 selectedSer =
    //                                                                 "1"; // ค่าเริ่มต้น: ser = 1
    //                                                             double
    //                                                                 vatPercent =
    //                                                                 7;
    //                                                             double
    //                                                                 whtPercent =
    //                                                                 3;
    //                                                             // ตัวอย่างข้อมูล JSON
    //                                                             final List<
    //                                                                     Map<String,
    //                                                                         String>>
    //                                                                 vatOptions =
    //                                                                 [
    //                                                               {
    //                                                                 "ser":
    //                                                                     "1",
    //                                                                 "name":
    //                                                                     "ก่อน VAT"
    //                                                               }
    //                                                               // ,
    //                                                               // {
    //                                                               //   "ser": "2",
    //                                                               //   "name":
    //                                                               //       "ยอดสุทธิ"
    //                                                               // },
    //                                                               // {
    //                                                               //   "ser": "3",
    //                                                               //   "name":
    //                                                               //       "หลังหักภาษี ณ ที่จ่าย"
    //                                                               // },
    //                                                             ];
    //                                                             int vatRate =
    //                                                                 0;
    //                                                             int whtRate =
    //                                                                 0;

    //                                                             final TextEditingController
    //                                                                 _pvatController =
    //                                                                 TextEditingController(
    //                                                                     text:
    //                                                                         '0');
    //                                                             final TextEditingController
    //                                                                 _vatController =
    //                                                                 TextEditingController(
    //                                                                     text:
    //                                                                         '0');
    //                                                             final TextEditingController
    //                                                                 _whtController =
    //                                                                 TextEditingController(
    //                                                                     text:
    //                                                                         '0');
    //                                                             final _totalController =
    //                                                                 TextEditingController(
    //                                                                     text:
    //                                                                         '0');
    //                                                             setState(
    //                                                                 () {
    //                                                               Formposlokdispri_
    //                                                                       .text =
    //                                                                   '0.00';
    //                                                             });
    //                                                             Widget _headerCell(
    //                                                                 String
    //                                                                     text) {
    //                                                               return Padding(
    //                                                                 padding:
    //                                                                     const EdgeInsets.all(2.0),
    //                                                                 child:
    //                                                                     Text(
    //                                                                   text,
    //                                                                   style: TextStyle(
    //                                                                       fontSize: 12,
    //                                                                       fontWeight: FontWeight.bold,
    //                                                                       color: Colors.white,
    //                                                                       fontFamily: Font_.Fonts_T),
    //                                                                   textAlign:
    //                                                                       TextAlign.center,
    //                                                                 ),
    //                                                               );
    //                                                             }

    //                                                             Widget _valueCell(
    //                                                                 String
    //                                                                     value) {
    //                                                               return Padding(
    //                                                                 padding:
    //                                                                     const EdgeInsets.all(2.0),
    //                                                                 child:
    //                                                                     Text(
    //                                                                   value,
    //                                                                   style: TextStyle(
    //                                                                       fontSize: 12,
    //                                                                       fontFamily: Font_.Fonts_T),
    //                                                                   textAlign:
    //                                                                       TextAlign.center,
    //                                                                 ),
    //                                                               );
    //                                                             }

    //                                                             Widget _buildPercentageRow(
    //                                                                 String
    //                                                                     type,
    //                                                                 String
    //                                                                     label,
    //                                                                 TextEditingController
    //                                                                     controllers) {
    //                                                               return Row(
    //                                                                 mainAxisAlignment:
    //                                                                     MainAxisAlignment.spaceBetween,
    //                                                                 children: [
    //                                                                   SizedBox(
    //                                                                       child: Row(
    //                                                                     children: [
    //                                                                       Text(
    //                                                                         label,
    //                                                                         style: TextStyle(fontSize: 14, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
    //                                                                       ),
    //                                                                     ],
    //                                                                   )),
    //                                                                   // InkWell(onTap: () {}, child: Icon(Icons.info_outline)),

    //                                                                   Container(
    //                                                                     height:
    //                                                                         50,
    //                                                                     width:
    //                                                                         160,
    //                                                                     padding:
    //                                                                         EdgeInsets.all(2),
    //                                                                     decoration:
    //                                                                         BoxDecoration(
    //                                                                       color: Colors.grey.shade200,
    //                                                                       borderRadius: BorderRadius.circular(6),
    //                                                                     ),
    //                                                                     child:
    //                                                                         Row(
    //                                                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                                                       children: [
    //                                                                         SizedBox(
    //                                                                           width: 130,
    //                                                                           child: TextField(
    //                                                                             // controller:
    //                                                                             //     _priceController,
    //                                                                             textAlign: TextAlign.end,
    //                                                                             keyboardType: TextInputType.number,
    //                                                                             controller: controllers,
    //                                                                             readOnly: true,
    //                                                                             style: TextStyle(fontSize: 14, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
    //                                                                             decoration: InputDecoration(
    //                                                                               contentPadding: EdgeInsets.zero,
    //                                                                               // prefixText: '฿',
    //                                                                               border: OutlineInputBorder(),
    //                                                                             ),
    //                                                                             inputFormatters: <TextInputFormatter>[
    //                                                                               // for below version 2 use this
    //                                                                               FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
    //                                                                               // for version 2 and greater youcan also use this
    //                                                                               // FilteringTextInputFormatter.digitsOnly
    //                                                                             ],
    //                                                                           ),
    //                                                                         ),
    //                                                                         // Text('${percent.toStringAsFixed(0)}'),
    //                                                                         Padding(
    //                                                                           padding: const EdgeInsets.all(3.0),
    //                                                                           child: Text('฿', style: TextStyle(color: Colors.grey)),
    //                                                                         ),
    //                                                                       ],
    //                                                                     ),
    //                                                                   ),
    //                                                                 ],
    //                                                               );
    //                                                             }

    //                                                             showDialog<
    //                                                                 String>(
    //                                                               context:
    //                                                                   context,
    //                                                               builder: (BuildContext
    //                                                                       context) =>
    //                                                                   StatefulBuilder(builder:
    //                                                                       (context, setState) {
    //                                                                 return AlertDialog(
    //                                                                   shape:
    //                                                                       const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //                                                                   backgroundColor:
    //                                                                       AppbackgroundColor.Sub_Abg_Colors,
    //                                                                   titlePadding:
    //                                                                       const EdgeInsets.all(0.0),
    //                                                                   contentPadding:
    //                                                                       const EdgeInsets.all(10.0),
    //                                                                   actionsPadding:
    //                                                                       const EdgeInsets.all(6.0),
    //                                                                   title:
    //                                                                       Row(
    //                                                                     mainAxisAlignment:
    //                                                                         MainAxisAlignment.end,
    //                                                                     children: [
    //                                                                       InkWell(
    //                                                                         onTap: () async {
    //                                                                           setState(() {
    //                                                                             Formposlokdispri_.clear();
    //                                                                           });
    //                                                                           Navigator.pop(context);
    //                                                                         },
    //                                                                         child: Padding(
    //                                                                           padding: const EdgeInsets.all(4.0),
    //                                                                           child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
    //                                                                         ),
    //                                                                       ),
    //                                                                     ],
    //                                                                   ),
    //                                                                   // title:
    //                                                                   //     Row(
    //                                                                   //   children: [
    //                                                                   //     Expanded(
    //                                                                   //       child:
    //                                                                   //           Center(
    //                                                                   //         child: Translate.TranslateAndSetText('ส่วนลดรายการ', PeopleChaoScreen_Color.Colors_Text1_, TextAlign.center, null, Font_.Fonts_T, 13, 1),
    //                                                                   //         //  Text(
    //                                                                   //         //   'ส่วนลดรายการ', // Navigator.pop(context, 'OK');
    //                                                                   //         //   style: TextStyle(color: AdminScafScreen_Color.Colors_Text1_, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
    //                                                                   //         // ),
    //                                                                   //       ),
    //                                                                   //     ),
    //                                                                   //     Expanded(
    //                                                                   //       child:
    //                                                                   //           Row(
    //                                                                   //         mainAxisAlignment: MainAxisAlignment.end,
    //                                                                   //         children: [
    //                                                                   //           IconButton(
    //                                                                   //               onPressed: () {
    //                                                                   //                 setState(() {
    //                                                                   //                   Formposlokdispri_.clear();
    //                                                                   //                 });
    //                                                                   //                 Navigator.pop(context);
    //                                                                   //               },
    //                                                                   //               icon: Icon(Icons.close, color: Colors.black)),
    //                                                                   //         ],
    //                                                                   //       ),
    //                                                                   //     ),
    //                                                                   //   ],
    //                                                                   // ),
    //                                                                   content:
    //                                                                       SingleChildScrollView(
    //                                                                     child:
    //                                                                         ListBody(
    //                                                                       children: <Widget>[
    //                                                                         SizedBox(height: 14),
    //                                                                         Padding(
    //                                                                           padding: const EdgeInsets.all(4),
    //                                                                           child: Row(
    //                                                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                                                             children: [
    //                                                                               Text(
    //                                                                                 'ส่วนลด',
    //                                                                                 style: TextStyle(fontSize: 14, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
    //                                                                               ),
    //                                                                               // RichText(
    //                                                                               //   text: TextSpan(
    //                                                                               //     text: 'ราคา ',
    //                                                                               //     style: TextStyle(fontSize: 16, color: Colors.black),
    //                                                                               //     children: [
    //                                                                               //       TextSpan(
    //                                                                               //         text: '${vatOptions.firstWhere((element) => element['ser'] == selectedSer)['name']}',
    //                                                                               //         style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold),
    //                                                                               //       ),
    //                                                                               //     ],
    //                                                                               //   ),
    //                                                                               // ),
    //                                                                               const SizedBox(height: 8),
    //                                                                               Container(
    //                                                                                 width: 260,
    //                                                                                 height: 40,
    //                                                                                 padding: EdgeInsets.symmetric(horizontal: 4),
    //                                                                                 decoration: BoxDecoration(
    //                                                                                   color: Colors.white,
    //                                                                                   borderRadius: BorderRadius.circular(6),
    //                                                                                   border: Border.all(color: Colors.grey.shade300),
    //                                                                                 ),
    //                                                                                 child: DropdownButtonHideUnderline(
    //                                                                                   child: DropdownButton<String>(
    //                                                                                     borderRadius: BorderRadius.all(Radius.circular(8)),
    //                                                                                     isExpanded: true,
    //                                                                                     value: selectedSer,
    //                                                                                     items: vatOptions.map((option) {
    //                                                                                       return DropdownMenuItem<String>(
    //                                                                                         value: option['ser'],
    //                                                                                         child: Text(
    //                                                                                           option['name']!,
    //                                                                                           style: TextStyle(fontSize: 14, color: Colors.green[700], fontWeight: FontWeight.bold, fontFamily: Font_.Fonts_T),
    //                                                                                         ),
    //                                                                                       );
    //                                                                                     }).toList(),
    //                                                                                     onChanged: (newValue) {
    //                                                                                       setState(() {
    //                                                                                         selectedSer = newValue!;
    //                                                                                         _pvatController.text = '0.00';
    //                                                                                         _vatController.text = '0.00';
    //                                                                                         _whtController.text = '0.00';
    //                                                                                         _totalController.text = '0.00';
    //                                                                                         Formposlokdispri_.text = '0.00';
    //                                                                                       });
    //                                                                                     },
    //                                                                                   ),
    //                                                                                 ),
    //                                                                               ),
    //                                                                             ],
    //                                                                           ),
    //                                                                         ),
    //                                                                         SizedBox(height: 12),
    //                                                                         SizedBox(
    //                                                                           height: 40,
    //                                                                           child: TextField(
    //                                                                             // controller:
    //                                                                             //     _priceController,
    //                                                                             textAlign: TextAlign.end,
    //                                                                             keyboardType: TextInputType.number,
    //                                                                             controller: Formposlokdispri_,
    //                                                                             onChanged: (value) async {
    //                                                                               setState(() {
    //                                                                                 vatRate = double.parse(_TransModels[index].nvat ?? '0').round();
    //                                                                                 whtRate = double.parse(_TransModels[index].nwht ?? '0').round();
    //                                                                               });
    //                                                                               var expSerVat = _TransModels[index].vtype;
    //                                                                               var expSerWht = _TransModels[index].wht;

    //                                                                               double parsedModelPvat = double.tryParse(_TransModels[index].pvat ?? '0') ?? 0;
    //                                                                               double parsedModelTotal = double.tryParse(_TransModels[index].total ?? '0') ?? 0;
    //                                                                               double parsedValue = double.tryParse(value ?? '0') ?? 0;

    //                                                                               double pvat = parsedModelPvat - parsedValue; // ยอดก่อนvat
    //                                                                               double total = parsedModelTotal - parsedValue; // ยอดสุทธิ

    //                                                                               setState(() {
    //                                                                                 if (parsedValue > parsedModelPvat) {
    //                                                                                   _pvatController.text = '0.00';
    //                                                                                   Formposlokdispri_.text = '0.00';
    //                                                                                   _vatController.text = '0.00';
    //                                                                                   _whtController.text = '0.00';
    //                                                                                   _totalController.text = '0.00';
    //                                                                                 } else {
    //                                                                                   _pvatController.text = pvat.toStringAsFixed(2);
    //                                                                                 }
    //                                                                               });
    //                                                                               if (total != null && total > 0 && selectedSer.toString() == '2') {
    //                                                                                 print('✅ คำนวณย้อนกลับ: รู้ยอดสุทธิ → หาก่อน VAT');

    //                                                                                 double base = total / (1 + vatRate / 100 - whtRate / 100);
    //                                                                                 double vatAmount = base * vatRate / 100;
    //                                                                                 double whtAmount = base * whtRate / 100;

    //                                                                                 _pvatController.text = base.toStringAsFixed(2);
    //                                                                                 _vatController.text = vatAmount.toStringAsFixed(2);
    //                                                                                 _whtController.text = whtAmount.toStringAsFixed(2);
    //                                                                                 _totalController.text = total.toStringAsFixed(2);
    //                                                                               } else if (pvat != null && pvat > 0 && selectedSer.toString() == '1') {
    //                                                                                 print('✅ ✅ คำนวณไปข้างหน้า: รู้ก่อน VAT → หายอดสุทธิ');

    //                                                                                 double vatAmount = pvat * vatRate / 100;
    //                                                                                 double whtAmount = pvat * whtRate / 100;
    //                                                                                 double total = pvat + vatAmount - whtAmount;

    //                                                                                 _vatController.text = vatAmount.toStringAsFixed(2);
    //                                                                                 _whtController.text = whtAmount.toStringAsFixed(2);
    //                                                                                 _totalController.text = total.toStringAsFixed(2);
    //                                                                               } else {
    //                                                                                 print('❌ กรุณากรอกยอดก่อน VAT หรือยอดสุทธิ');
    //                                                                               }

    //                                                                               // if (total != null && total > 0 && selectedSer.toString() == '2') {
    //                                                                               //   print('✅ คำนวณย้อนกลับ: รู้ยอดสุทธิ → หาก่อน VAT');
    //                                                                               //   double base = total / (1 + (vatRate / 100) - (whtRate / 100));
    //                                                                               //   double vatAmount = base * vatRate / 100;
    //                                                                               //   double whtAmount = base * whtRate / 100;
    //                                                                               //   _pvatController.text = base.toStringAsFixed(2);
    //                                                                               //   _vatController.text = vatAmount.toStringAsFixed(2);
    //                                                                               //   _whtController.text = whtAmount.toStringAsFixed(2);
    //                                                                               //   _totalController.text = total.toStringAsFixed(2);
    //                                                                               // } else if (pvat != null && pvat > 0 && selectedSer.toString() == '1') {
    //                                                                               //   print('✅ ✅ คำนวณไปข้างหน้า: รู้ก่อน VAT → หายอดสุทธิ');

    //                                                                               //   double vatAmount = pvat * vatRate / 100;
    //                                                                               //   double whtAmount = pvat * whtRate / 100;
    //                                                                               //   double total = pvat + vatAmount - whtAmount;

    //                                                                               //   _vatController.text = vatAmount.toStringAsFixed(2);
    //                                                                               //   _whtController.text = whtAmount.toStringAsFixed(2);
    //                                                                               //   _totalController.text = total.toStringAsFixed(2);
    //                                                                               // } else {
    //                                                                               //   print('❌ กรุณากรอกยอดก่อน VAT หรือยอดสุทธิ');
    //                                                                               // }
    //                                                                             },
    //                                                                             decoration: InputDecoration(
    //                                                                               prefixText: 'ราคา',
    //                                                                               border: OutlineInputBorder(),
    //                                                                             ),
    //                                                                             inputFormatters: <TextInputFormatter>[
    //                                                                               // for below version 2 use this
    //                                                                               FilteringTextInputFormatter.allow(RegExp(r'[0-9 .]')),
    //                                                                               // for version 2 and greater youcan also use this
    //                                                                               // FilteringTextInputFormatter.digitsOnly
    //                                                                             ],
    //                                                                           ),
    //                                                                         ),
    //                                                                         SizedBox(height: 12),
    //                                                                         const Divider(),
    //                                                                         Padding(
    //                                                                           padding: const EdgeInsets.all(4.0),
    //                                                                           child: Table(
    //                                                                             border: TableBorder.symmetric(
    //                                                                               inside: BorderSide(width: 0.5, color: Colors.grey.shade400),
    //                                                                             ),
    //                                                                             columnWidths: const {
    //                                                                               0: FlexColumnWidth(),
    //                                                                               1: FlexColumnWidth(),
    //                                                                               2: FlexColumnWidth(),
    //                                                                               3: FlexColumnWidth(),
    //                                                                             },
    //                                                                             children: [
    //                                                                               TableRow(
    //                                                                                 decoration: BoxDecoration(color: Colors.grey.shade600),
    //                                                                                 children: [
    //                                                                                   _headerCell('ก่อนVAT'),
    //                                                                                   _headerCell('VAT'),
    //                                                                                   _headerCell('WHT'),
    //                                                                                   _headerCell('ยอดสุทธิ'),
    //                                                                                 ],
    //                                                                               ),
    //                                                                               TableRow(
    //                                                                                 decoration: BoxDecoration(color: Colors.grey.shade100),
    //                                                                                 children: [
    //                                                                                   _valueCell('${nFormat.format(double.parse(_TransModels[index].pvat!))}'),
    //                                                                                   _valueCell('${nFormat.format(double.parse(_TransModels[index].vat!))}'),
    //                                                                                   _valueCell('${nFormat.format(double.parse(_TransModels[index].wht!))}'),
    //                                                                                   _valueCell('${nFormat.format(double.parse(_TransModels[index].total!))}'),
    //                                                                                 ],
    //                                                                               ),
    //                                                                             ],
    //                                                                           ),
    //                                                                         ),
    //                                                                         Center(
    //                                                                             child: Icon(
    //                                                                           Icons.sync_rounded,
    //                                                                           color: Colors.blue,
    //                                                                         )),
    //                                                                         Center(
    //                                                                           child: Text(
    //                                                                             'ผลการคำนวน',
    //                                                                             style: TextStyle(fontSize: 16, color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
    //                                                                           ),
    //                                                                         ),
    //                                                                         SizedBox(height: 12),
    //                                                                         _buildPercentageRow('', 'ก่อนVAT', _pvatController),
    //                                                                         SizedBox(height: 12),
    //                                                                         _buildPercentageRow('VAT', 'ภาษีมูลค่าเพิ่ม (VAT $vatRate%)', _vatController),
    //                                                                         SizedBox(height: 8),
    //                                                                         _buildPercentageRow('WHT', 'หักภาษี ณ ที่จ่าย (WHT $whtRate%)', _whtController),
    //                                                                         SizedBox(height: 8),
    //                                                                         _buildPercentageRow('Total', 'ยอดสุทธิ', _totalController),
    //                                                                         SizedBox(height: 16),
    //                                                                       ],
    //                                                                     ),
    //                                                                   ),
    //                                                                   actions: [
    //                                                                     Center(
    //                                                                       child: Padding(
    //                                                                         padding: const EdgeInsets.all(8.0),
    //                                                                         child: ElevatedButton(
    //                                                                           style: ElevatedButton.styleFrom(
    //                                                                             backgroundColor: Colors.green,
    //                                                                             minimumSize: Size(double.infinity, 48),
    //                                                                           ),
    //                                                                           onPressed: (Formposlokdispri_.text.isEmpty || double.parse(Formposlokdispri_.text) <= 0)
    //                                                                               ? null
    //                                                                               : () async {
    //                                                                                   SharedPreferences preferences = await SharedPreferences.getInstance();
    //                                                                                   var ren = preferences.getString('renTalSer');
    //                                                                                   var user = preferences.getString('ser');
    //                                                                                   var sertran = _TransModels[index].ser;

    //                                                                                   final velText = Formposlokdispri_.text.trim();
    //                                                                                   final pvatText = _pvatController.text.trim();
    //                                                                                   final vatText = _vatController.text.trim();
    //                                                                                   final whtText = _whtController.text.trim();
    //                                                                                   final totalText = _totalController.text.trim();

    //                                                                                   final disuser = double.tryParse(velText);
    //                                                                                   final pvat = double.tryParse(pvatText);
    //                                                                                   final vat = double.tryParse(vatText);
    //                                                                                   final wht = double.tryParse(whtText);
    //                                                                                   final total = double.tryParse(totalText);
    //                                                                                   // setState(() {
    //                                                                                   //   total_dislist = double.tryParse(velText);
    //                                                                                   // });

    //                                                                                   if (disuser == null || vat == null || wht == null || total == null) {
    //                                                                                     ScaffoldMessenger.of(context).showSnackBar(
    //                                                                                       const SnackBar(
    //                                                                                         content: Text('ข้อมูลไม่ถูกต้อง', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
    //                                                                                       ),
    //                                                                                     );
    //                                                                                     return;
    //                                                                                   }

    //                                                                                   if (vat <= total) {
    //                                                                                     final url = Uri.parse('${MyConstant().domain}/c_trans_selectdis_v2.php');
    //                                                                                     print('📡 POST to: $url');

    //                                                                                     try {
    //                                                                                       final response = await httpClient.post(
    //                                                                                         url,
    //                                                                                         // headers: {
    //                                                                                         //   'Content-Type': 'application/x-www-form-urlencoded'
    //                                                                                         // },
    //                                                                                         body: {
    //                                                                                           'isAdd': 'true',
    //                                                                                           'ren': ren ?? '',
    //                                                                                           'disuser': disuser.toStringAsFixed(2),
    //                                                                                           'sertran': sertran ?? '',
    //                                                                                           'pvatnew': pvat!.toStringAsFixed(2),
    //                                                                                           'vatnew': vat.toStringAsFixed(2),
    //                                                                                           'whtnew': wht.toStringAsFixed(2),
    //                                                                                           'totalnew': total.toStringAsFixed(2),
    //                                                                                         },
    //                                                                                       );

    //                                                                                       print({
    //                                                                                         'isAdd': 'true',
    //                                                                                         'ren': ren ?? '',
    //                                                                                         'disuser': disuser.toStringAsFixed(2),
    //                                                                                         'sertran': sertran ?? '',
    //                                                                                         'pvatnew': pvat!.toStringAsFixed(2),
    //                                                                                         'vatnew': vat.toStringAsFixed(2),
    //                                                                                         'whtnew': wht.toStringAsFixed(2),
    //                                                                                         'totalnew': total.toStringAsFixed(2),
    //                                                                                         // 'Formposlokdispri_': Formposlokdispri_.text.trim(),
    //                                                                                       });

    //                                                                                       if (response.statusCode == 200) {
    //                                                                                         final result = json.decode(response.body);
    //                                                                                         // print('✅ RESPONSE: $result');

    //                                                                                         if (result['success'].toString() == 'true') {
    //                                                                                           setState(() {
    //                                                                                             red_Trans_select();
    //                                                                                             red_Trans_bill();
    //                                                                                             Formposlokdispri_.clear();
    //                                                                                           });
    //                                                                                         } else {
    //                                                                                           setState(() {
    //                                                                                             Formposlokdispri_.clear();
    //                                                                                           });
    //                                                                                         }

    //                                                                                         Navigator.pop(context);
    //                                                                                       } else {
    //                                                                                         print('❌ Server Error: ${response.statusCode}');
    //                                                                                         Navigator.pop(context);
    //                                                                                       }
    //                                                                                     } catch (e) {
    //                                                                                       print('❌ Exception: $e');
    //                                                                                       Navigator.pop(context);
    //                                                                                     }
    //                                                                                   } else {
    //                                                                                     ScaffoldMessenger.of(context).showSnackBar(
    //                                                                                       SnackBar(
    //                                                                                         content: Text('Total Error  $disuser // $total ', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
    //                                                                                       ),
    //                                                                                     );
    //                                                                                   }
    //                                                                                 },
    //                                                                           child: Text('บันทึก', style: TextStyle(fontSize: 16)),
    //                                                                         ),
    //                                                                       ),
    //                                                                     )
    //                                                                   ],
    //                                                                   // actions: <Widget>[
    //                                                                   //   Form(
    //                                                                   //     key:
    //                                                                   //         _formKey,
    //                                                                   //     child:
    //                                                                   //         Column(
    //                                                                   //       children: [
    //                                                                   //         Padding(
    //                                                                   //           padding: EdgeInsets.all(8.0),
    //                                                                   //           child: TextFormField(
    //                                                                   //             controller: Formposlokdispri_,
    //                                                                   //             // obscureText:
    //                                                                   //             //     true,
    //                                                                   //             validator: (value) {
    //                                                                   //               if (value == null || value.isEmpty) {
    //                                                                   //                 return ' ';
    //                                                                   //               }
    //                                                                   //               // if (int.parse(value.toString()) < 13) {
    //                                                                   //               //   return '< 13';
    //                                                                   //               // }
    //                                                                   //               return null;
    //                                                                   //             },

    //                                                                   //             onFieldSubmitted: (val) async {
    //                                                                   //               if (_formKey.currentState!.validate()) {
    //                                                                   //                 SharedPreferences preferences = await SharedPreferences.getInstance();
    //                                                                   //                 var ren = preferences.getString('renTalSer');
    //                                                                   //                 var user = preferences.getString('ser');

    //                                                                   //                 var sertran = _TransModels[index].ser;
    //                                                                   //                 var vel = Formposlokdispri_.text.trim();
    //                                                                   //                 if (double.parse(vel) <= double.parse(_TransModels[index].total!)) {
    //                                                                   //                   // print('vel>>>>$vel');
    //                                                                   //                   String url = '${MyConstant().domain}/c_trans_select_dis.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';
    //                                                                   //                   print('url>>>>$url');
    //                                                                   //                   try {
    //                                                                   //                     var response = await httpClient.get(Uri.parse(url));

    //                                                                   //                     var result = json.decode(response.body);
    //                                                                   //                     // print(result);
    //                                                                   //                     if (result.toString() == 'true') {
    //                                                                   //                       setState(() {
    //                                                                   //                         red_Trans_select();
    //                                                                   //                         red_Trans_bill();
    //                                                                   //                         Formposlokdispri_.clear();
    //                                                                   //                       });
    //                                                                   //                       Navigator.pop(context);
    //                                                                   //                     } else {
    //                                                                   //                       setState(() {
    //                                                                   //                         Formposlokdispri_.clear();
    //                                                                   //                       });

    //                                                                   //                       Navigator.pop(context);
    //                                                                   //                     }
    //                                                                   //                   } catch (e) {}
    //                                                                   //                   Navigator.pop(context);
    //                                                                   //                 } else {
    //                                                                   //                   ScaffoldMessenger.of(context).showSnackBar(
    //                                                                   //                     const SnackBar(content: Text('Total Error', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    //                                                                   //                   );
    //                                                                   //                 }
    //                                                                   //               }
    //                                                                   //             },
    //                                                                   //             cursorColor: Colors.green,
    //                                                                   //             decoration: InputDecoration(
    //                                                                   //                 fillColor: Colors.white.withOpacity(0.3),
    //                                                                   //                 filled: true,
    //                                                                   //                 // prefixIcon: const Icon(Icons.water,
    //                                                                   //                 //     color: Colors.blue),
    //                                                                   //                 // suffixIcon: Icon(Icons.clear, color: Colors.black),
    //                                                                   //                 focusedBorder: const OutlineInputBorder(
    //                                                                   //                   borderRadius: BorderRadius.only(
    //                                                                   //                     topRight: Radius.circular(15),
    //                                                                   //                     topLeft: Radius.circular(15),
    //                                                                   //                     bottomRight: Radius.circular(15),
    //                                                                   //                     bottomLeft: Radius.circular(15),
    //                                                                   //                   ),
    //                                                                   //                   borderSide: BorderSide(
    //                                                                   //                     width: 1,
    //                                                                   //                     color: Colors.black,
    //                                                                   //                   ),
    //                                                                   //                 ),
    //                                                                   //                 enabledBorder: const OutlineInputBorder(
    //                                                                   //                   borderRadius: BorderRadius.only(
    //                                                                   //                     topRight: Radius.circular(15),
    //                                                                   //                     topLeft: Radius.circular(15),
    //                                                                   //                     bottomRight: Radius.circular(15),
    //                                                                   //                     bottomLeft: Radius.circular(15),
    //                                                                   //                   ),
    //                                                                   //                   borderSide: BorderSide(
    //                                                                   //                     width: 1,
    //                                                                   //                     color: Colors.grey,
    //                                                                   //                   ),
    //                                                                   //                 ),
    //                                                                   //                 labelText: 'Total',
    //                                                                   //                 labelStyle: const TextStyle(
    //                                                                   //                   color: ManageScreen_Color.Colors_Text2_,
    //                                                                   //                   // fontWeight:
    //                                                                   //                   //     FontWeight.bold,
    //                                                                   //                   fontFamily: Font_.Fonts_T,
    //                                                                   //                 )),
    //                                                                   //             // inputFormatters: <TextInputFormatter>[
    //                                                                   //             //   // for below version 2 use this
    //                                                                   //             //   FilteringTextInputFormatter.allow(
    //                                                                   //             //       RegExp(r'[0-9]')),
    //                                                                   //             //   // for version 2 and greater youcan also use this
    //                                                                   //             //   FilteringTextInputFormatter.digitsOnly
    //                                                                   //             // ],
    //                                                                   //           ),
    //                                                                   //         ),
    //                                                                   //         Padding(
    //                                                                   //           padding: const EdgeInsets.all(8.0),
    //                                                                   //           child: Row(
    //                                                                   //             mainAxisAlignment: MainAxisAlignment.center,
    //                                                                   //             children: [
    //                                                                   //               Container(
    //                                                                   //                 width: 150,
    //                                                                   //                 decoration: const BoxDecoration(
    //                                                                   //                   color: Colors.black,
    //                                                                   //                   borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
    //                                                                   //                 ),
    //                                                                   //                 padding: const EdgeInsets.all(8.0),
    //                                                                   //                 child: TextButton(
    //                                                                   //                   onPressed: () async {
    //                                                                   //                     if (_formKey.currentState!.validate()) {
    //                                                                   //                       SharedPreferences preferences = await SharedPreferences.getInstance();
    //                                                                   //                       var ren = preferences.getString('renTalSer');
    //                                                                   //                       var user = preferences.getString('ser');

    //                                                                   //                       var sertran = _TransModels[index].ser;
    //                                                                   //                       var vel = Formposlokdispri_.text.trim();
    //                                                                   //                       if (double.parse(vel) <= double.parse(_TransModels[index].total!)) {
    //                                                                   //                         // print('vel>>>>$vel');
    //                                                                   //                         String url = '${MyConstant().domain}/c_trans_select_dis.php?isAdd=true&ren=$ren&puser=$vel&sertran=$sertran';
    //                                                                   //                         print('url>>>>$url');
    //                                                                   //                         try {
    //                                                                   //                           var response = await httpClient.get(Uri.parse(url));

    //                                                                   //                           var result = json.decode(response.body);
    //                                                                   //                           // print(result);
    //                                                                   //                           if (result.toString() == 'true') {
    //                                                                   //                             setState(() {
    //                                                                   //                               red_Trans_select();
    //                                                                   //                               red_Trans_bill();
    //                                                                   //                               Formposlokdispri_.clear();
    //                                                                   //                             });
    //                                                                   //                             Navigator.pop(context);
    //                                                                   //                           } else {
    //                                                                   //                             setState(() {
    //                                                                   //                               Formposlokdispri_.clear();
    //                                                                   //                             });

    //                                                                   //                             Navigator.pop(context);
    //                                                                   //                           }
    //                                                                   //                         } catch (e) {}
    //                                                                   //                         Navigator.pop(context);
    //                                                                   //                       } else {
    //                                                                   //                         ScaffoldMessenger.of(context).showSnackBar(
    //                                                                   //                           const SnackBar(content: Text('Total Error', style: TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
    //                                                                   //                         );
    //                                                                   //                       }
    //                                                                   //                     }
    //                                                                   //                   },
    //                                                                   //                   child: const Text(
    //                                                                   //                     'Submit',
    //                                                                   //                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: FontWeight_.Fonts_T),
    //                                                                   //                   ),
    //                                                                   //                 ),
    //                                                                   //               ),
    //                                                                   //             ],
    //                                                                   //           ),
    //                                                                   //         ),
    //                                                                   //       ],
    //                                                                   //     ),
    //                                                                   //   ),
    //                                                                   // ],
    //                                                                 );
    //                                                               }),
    //                                                             );
    //                                                           },
    //                                                           child: Container(
    //                                                               padding: const EdgeInsets.all(10),
    //                                                               width: MediaQuery.of(context).size.width,
    //                                                               child: Row(
    //                                                                 children: [
    //                                                                   Expanded(
    //                                                                     child: Translate.TranslateAndSetText(
    //                                                                         'ส่วนลดรายการ',
    //                                                                         PeopleChaoScreen_Color.Colors_Text1_,
    //                                                                         TextAlign.center,
    //                                                                         null,
    //                                                                         Font_.Fonts_T,
    //                                                                         13,
    //                                                                         1),
    //                                                                   )
    //                                                                 ],
    //                                                               ))),
    //                                                     ),
    //                                                 ],
    //                                                 child: AutoSizeText(
    //                                                   minFontSize: 10,
    //                                                   maxFontSize: 15,
    //                                                   maxLines: 1,
    //                                                   '${index + 1}',
    //                                                   textAlign:
    //                                                       TextAlign.center,
    //                                                   overflow: TextOverflow
    //                                                       .ellipsis,
    //                                                   style:
    //                                                       const TextStyle(
    //                                                           color: PeopleChaoScreen_Color
    //                                                               .Colors_Text2_,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                 ),
    //                                               ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 1,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           _TransModels[index].dtype ==
    //                                                   'KU'
    //                                               ? '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransModels[index].duedate} 00:00:00'))}'
    //                                               : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransModels[index].date} 00:00:00'))}',
    //                                           textAlign: TextAlign.center,
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 2,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           '${_TransModels[index].name}',
    //                                           textAlign: TextAlign.center,
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 1,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           '${nFormat.format(double.parse(_TransModels[index].tqty!))}',
    //                                           //'${_TransModels[index].tqty}',
    //                                           textAlign: TextAlign.end,
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 1,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           '${_TransModels[index].unit_con}',
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           textAlign: TextAlign.end,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 1,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           nFormat.format(
    //                                               double.tryParse(
    //                                                       _TransModels[
    //                                                                   index]
    //                                                               .pvat ??
    //                                                           '0') ??
    //                                                   0),
    //                                           // _TransModels[index].qty_con ==
    //                                           //         '0.00'
    //                                           //     ? '${nFormat.format(double.parse(_TransModels[index].amt_con!))}'
    //                                           //     //'${_TransModels[index].amt_con}'
    //                                           //     : '${nFormat.format(double.parse(_TransModels[index].qty_con!))}',
    //                                           // //'${_TransModels[index].qty_con}',
    //                                           textAlign: TextAlign.end,
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 1,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           '${nFormat.format(double.parse(_TransModels[index].vat!))}',
    //                                           //'${_TransModels[index].qty_con}',
    //                                           textAlign: TextAlign.end,
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 1,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           '${nFormat.format(double.parse(_TransModels[index].wht!))}',
    //                                           //'${_TransModels[index].qty_con}',
    //                                           textAlign: TextAlign.end,
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       Expanded(
    //                                         flex: 1,
    //                                         child: AutoSizeText(
    //                                           minFontSize: 10,
    //                                           maxFontSize: 15,
    //                                           maxLines: 1,
    //                                           '${nFormat.format(double.parse(_TransModels[index].total!))}',
    //                                           // '${_TransModels[index].pvat}',
    //                                           textAlign: TextAlign.end,
    //                                           overflow:
    //                                               TextOverflow.ellipsis,
    //                                           style: const TextStyle(
    //                                               color:
    //                                                   PeopleChaoScreen_Color
    //                                                       .Colors_Text2_,
    //                                               //fontWeight: FontWeight.bold,
    //                                               fontFamily:
    //                                                   Font_.Fonts_T),
    //                                         ),
    //                                       ),
    //                                       SizedBox(
    //                                         width: 44,
    //                                         child: Center(
    //                                           child: IconButton(
    //                                               onPressed: () {
    //                                                 de_Trans_select(index);
    //                                               },
    //                                               icon: const Icon(
    //                                                 Icons.remove_circle,
    //                                                 color: Colors.red,
    //                                               )),
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                   double.parse(_TransModels[index]
    //                                               .dis!) ==
    //                                           0.0
    //                                       ? SizedBox()
    //                                       : Row(
    //                                           children: [
    //                                             Container(
    //                                               width: 50,
    //                                               child: SizedBox(),
    //                                             ),
    //                                             Expanded(
    //                                               flex: 2,
    //                                               child: Icon(
    //                                                 Icons
    //                                                     .subdirectory_arrow_right,
    //                                                 // color: Colors.red,
    //                                               ),
    //                                             ),
    //                                             Expanded(
    //                                               flex: 2,
    //                                               child: Translate
    //                                                   .TranslateAndSetText(
    //                                                       'ส่วนลด',
    //                                                       Colors.red,
    //                                                       TextAlign.center,
    //                                                       null,
    //                                                       Font_.Fonts_T,
    //                                                       14,
    //                                                       1),
    //                                               //  AutoSizeText(
    //                                               //   minFontSize: 10,
    //                                               //   maxFontSize: 15,
    //                                               //   maxLines: 1,
    //                                               //   'ส่วนลด',
    //                                               //   textAlign:
    //                                               //       TextAlign.start,
    //                                               //   style:
    //                                               //       const TextStyle(
    //                                               //           color: Colors
    //                                               //               .red,
    //                                               //           //fontWeight: FontWeight.bold,
    //                                               //           fontFamily: Font_
    //                                               //               .Fonts_T),
    //                                               // ),
    //                                             ),
    //                                             Expanded(
    //                                               flex: 1,
    //                                               child: SizedBox(),
    //                                             ),
    //                                             Expanded(
    //                                               flex: 1,
    //                                               child: SizedBox(),
    //                                             ),
    //                                             Expanded(
    //                                               flex: 1,
    //                                               child: SizedBox(),
    //                                             ),
    //                                             Expanded(
    //                                               flex: 1,
    //                                               child: SizedBox(),
    //                                             ),
    //                                             Expanded(
    //                                               flex: 1,
    //                                               child: AutoSizeText(
    //                                                 minFontSize: 10,
    //                                                 maxFontSize: 15,
    //                                                 maxLines: 1,
    //                                                 '${nFormat.format(double.parse(_TransModels[index].dis!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
    //                                                 textAlign:
    //                                                     TextAlign.end,
    //                                                 style: const TextStyle(
    //                                                     color: PeopleChaoScreen_Color
    //                                                         .Colors_Text2_,
    //                                                     //fontWeight: FontWeight.bold,
    //                                                     fontFamily:
    //                                                         Font_.Fonts_T),
    //                                               ),
    //                                             ),
    //                                             Expanded(
    //                                                 flex: 1,
    //                                                 child: SizedBox()
    //                                                 // Center(
    //                                                 //   child: IconButton(
    //                                                 //       onPressed: () {

    //                                                 //         // de_Trans_select(index);
    //                                                 //       },
    //                                                 //       icon: const Icon(
    //                                                 //         Icons.remove_circle,
    //                                                 //         color: Colors.red,
    //                                                 //       )),
    //                                                 // ),
    //                                                 ),
    //                                           ],
    //                                         ),
    //                                   for (int inde = 0;
    //                                       inde < transFineModels.length;
    //                                       inde++)
    //                                     _TransModels[index].docno !=
    //                                             transFineModels[inde].docno
    //                                         ? SizedBox()
    //                                         : Row(
    //                                             children: [
    //                                               Expanded(
    //                                                 flex: 1,
    //                                                 child: SizedBox(),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 2,
    //                                                 child: SizedBox(),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 2,
    //                                                 child: AutoSizeText(
    //                                                   minFontSize: 8,
    //                                                   maxFontSize: 12,
    //                                                   maxLines: 1,
    //                                                   '${transFineModels[inde].expname}',
    //                                                   textAlign:
    //                                                       TextAlign.start,
    //                                                   style:
    //                                                       const TextStyle(
    //                                                           color: Colors
    //                                                               .red,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                 ),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 1,
    //                                                 child: SizedBox(),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 1,
    //                                                 child: AutoSizeText(
    //                                                   minFontSize: 8,
    //                                                   maxFontSize: 12,
    //                                                   maxLines: 1,
    //                                                   double.parse(transFineModels[
    //                                                                   inde]
    //                                                               .vat!) ==
    //                                                           0.0
    //                                                       ? ''
    //                                                       : '${nFormat.format(double.parse(transFineModels[inde].pvat!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
    //                                                   textAlign:
    //                                                       TextAlign.end,
    //                                                   style:
    //                                                       const TextStyle(
    //                                                           color: Colors
    //                                                               .red,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                 ),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 1,
    //                                                 child: AutoSizeText(
    //                                                   minFontSize: 8,
    //                                                   maxFontSize: 12,
    //                                                   maxLines: 1,
    //                                                   double.parse(transFineModels[
    //                                                                   inde]
    //                                                               .vat!) ==
    //                                                           0.0
    //                                                       ? ''
    //                                                       : '${nFormat.format(double.parse(transFineModels[inde].vat!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
    //                                                   textAlign:
    //                                                       TextAlign.end,
    //                                                   style:
    //                                                       const TextStyle(
    //                                                           color: Colors
    //                                                               .red,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                 ),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 1,
    //                                                 child: SizedBox(),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 1,
    //                                                 child: AutoSizeText(
    //                                                   minFontSize: 8,
    //                                                   maxFontSize: 12,
    //                                                   maxLines: 1,
    //                                                   '${nFormat.format(double.parse(transFineModels[inde].total!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
    //                                                   textAlign:
    //                                                       TextAlign.end,
    //                                                   style:
    //                                                       const TextStyle(
    //                                                           color: Colors
    //                                                               .red,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                 ),
    //                                               ),
    //                                               Expanded(
    //                                                 flex: 1,
    //                                                 child: IconButton(
    //                                                     onPressed:
    //                                                         () async {
    //                                                       SharedPreferences
    //                                                           preferences =
    //                                                           await SharedPreferences
    //                                                               .getInstance();
    //                                                       var renTal_lavel =
    //                                                           int.parse(preferences
    //                                                               .getString(
    //                                                                   'lavel')
    //                                                               .toString());
    //                                                       if (renTal_lavel >=
    //                                                           4) {
    //                                                         de_Trans_select_fine(
    //                                                             inde);
    //                                                       } else {
    //                                                         ScaffoldMessenger.of(
    //                                                                 context)
    //                                                             .showSnackBar(
    //                                                           SnackBar(
    //                                                             content: Translate.TranslateAndSetText(
    //                                                                 'User ของท่านไม่สามารถทำการลบค่าปรับเกินกำหนดชำระได้ ',
    //                                                                 Colors
    //                                                                     .red,
    //                                                                 TextAlign
    //                                                                     .center,
    //                                                                 null,
    //                                                                 Font_
    //                                                                     .Fonts_T,
    //                                                                 14,
    //                                                                 1),
    //                                                             // Text('User ของท่านไม่สามารถทำการลบค่าปรับเกินกำหนดชำระได้ ')
    //                                                           ),
    //                                                         );
    //                                                       }
    //                                                     },
    //                                                     icon: const Icon(
    //                                                       Icons
    //                                                           .remove_circle,
    //                                                       color: Colors.red,
    //                                                     )),
    //                                               ),
    //                                             ],
    //                                           ),
    //                                 ],
    //                               ),
    //                             );
    //                           },
    //                         ),
    //                       ),
    //                       Container(
    //                         width: MediaQuery.of(context).size.width,
    //                         decoration: const BoxDecoration(
    //                           color: AppbackgroundColor.Sub_Abg_Colors,
    //                           borderRadius: BorderRadius.only(
    //                               topLeft: Radius.circular(0),
    //                               topRight: Radius.circular(0),
    //                               bottomLeft: Radius.circular(10),
    //                               bottomRight: Radius.circular(10)),
    //                         ),
    //                         child: Column(
    //                           children: [
    //                             Align(
    //                               alignment: Alignment.topRight,
    //                               child: Column(
    //                                 children: [
    //                                   Row(
    //                                     children: [
    //                                       _VocherModels.length == 0
    //                                           ? Expanded(
    //                                               child: SizedBox(),
    //                                             )
    //                                           : Expanded(
    //                                               child: Padding(
    //                                                 padding:
    //                                                     const EdgeInsets
    //                                                         .all(8.0),
    //                                                 child: Container(
    //                                                   height: 150,
    //                                                   child: Row(
    //                                                     mainAxisAlignment:
    //                                                         MainAxisAlignment
    //                                                             .end,
    //                                                     crossAxisAlignment:
    //                                                         CrossAxisAlignment
    //                                                             .end,
    //                                                     children: [
    //                                                       Container(
    //                                                         width: 150,
    //                                                         color: Colors
    //                                                             .indigo,
    //                                                         child:
    //                                                             TextButton(
    //                                                           onPressed:
    //                                                               () {
    //                                                             showDialog(
    //                                                                 context:
    //                                                                     context,
    //                                                                 builder:
    //                                                                     (BuildContext
    //                                                                         context) {
    //                                                                   return AlertDialog(
    //                                                                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
    //                                                                       // title: const Text('AlertDialog Title'),
    //                                                                       content: SingleChildScrollView(
    //                                                                           child: Column(
    //                                                                         children: [
    //                                                                           for (int index = 0; index < _VocherModels.length; index++)
    //                                                                             Container(
    //                                                                               color: ser_vocher == _VocherModels[index].ser ? Colors.blue.shade100 : Colors.blueGrey.shade100,
    //                                                                               child: Padding(
    //                                                                                 padding: const EdgeInsets.all(8.0),
    //                                                                                 child: TextButton(
    //                                                                                   onPressed: () {
    //                                                                                     print('${_VocherModels[index].ser}');
    //                                                                                     Navigator.pop(context);
    //                                                                                     var valuenum = double.parse('${_VocherModels[index].pvat}');
    //                                                                                     // var sum = ((sum_amt * valuenum) / 100);

    //                                                                                     setState(() {
    //                                                                                       sum_dis = valuenum;
    //                                                                                       sum_disamt.text = valuenum.toStringAsFixed(2).toString();
    //                                                                                       ser_vocher = _VocherModels[index].ser;
    //                                                                                     });

    //                                                                                     print('sum_dis $sum_dis');
    //                                                                                   },
    //                                                                                   child: Row(
    //                                                                                     children: [
    //                                                                                       Expanded(
    //                                                                                         child: Text(
    //                                                                                           '${_VocherModels[index].descr}',
    //                                                                                           style: TextStyle(color: Colors.black),
    //                                                                                         ),
    //                                                                                       ),
    //                                                                                       Expanded(
    //                                                                                         child: Text(
    //                                                                                           nFormat.format(double.parse('${_VocherModels[index].pvat}')),
    //                                                                                           textAlign: TextAlign.end,
    //                                                                                           style: TextStyle(color: Colors.black),
    //                                                                                         ),
    //                                                                                       ),
    //                                                                                       Expanded(
    //                                                                                         child: Icon(
    //                                                                                           Icons.arrow_right_alt,
    //                                                                                           color: Colors.black,
    //                                                                                         ),
    //                                                                                       ),
    //                                                                                     ],
    //                                                                                   ),
    //                                                                                 ),
    //                                                                               ),
    //                                                                             )
    //                                                                         ],
    //                                                                       )));
    //                                                                 });
    //                                                           },
    //                                                           child:
    //                                                               Padding(
    //                                                             padding:
    //                                                                 const EdgeInsets.all(
    //                                                                     8.0),
    //                                                             child: Text(
    //                                                               'Vocher',
    //                                                               style: TextStyle(
    //                                                                   color: Colors.white,
    //                                                                   //fontWeight: FontWeight.bold,
    //                                                                   fontFamily: Font_.Fonts_T),
    //                                                             ),
    //                                                           ),
    //                                                         ),
    //                                                       )
    //                                                     ],
    //                                                   ),
    //                                                 ),
    //                                               ),
    //                                             ),
    //                                       Expanded(
    //                                         child:
    //                                             // Container(
    //                                             //   color: Colors.grey.shade300,
    //                                             //   // height: 100,
    //                                             //   width: 600,
    //                                             //   padding:
    //                                             //       const EdgeInsets.all(8.0),
    //                                             Card(
    //                                           color: Colors.grey.shade300,
    //                                           shape: RoundedRectangleBorder(
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       8)),
    //                                           clipBehavior: Clip.antiAlias,
    //                                           child: Padding(
    //                                             padding:
    //                                                 const EdgeInsets.all(
    //                                                     8.0),
    //                                             child: Column(children: [
    //                                               sum_tran_fine == 0
    //                                                   ? SizedBox()
    //                                                   : Row(
    //                                                       children: [
    //                                                         Expanded(
    //                                                           flex: 1,
    //                                                           child: Translate.TranslateAndSetText(
    //                                                               'ค่าปรับ',
    //                                                               Colors
    //                                                                   .red,
    //                                                               TextAlign
    //                                                                   .start,
    //                                                               null,
    //                                                               Font_
    //                                                                   .Fonts_T,
    //                                                               12,
    //                                                               1),
    //                                                           // AutoSizeText(
    //                                                           //   minFontSize: 10,
    //                                                           //   maxFontSize: 15,
    //                                                           //   'ค่าปรับ',
    //                                                           //   style: TextStyle(
    //                                                           //       color: Colors
    //                                                           //           .red,
    //                                                           //       //fontWeight: FontWeight.bold,
    //                                                           //       fontFamily: Font_
    //                                                           //           .Fonts_T),
    //                                                           // ),
    //                                                         ),
    //                                                         Expanded(
    //                                                           flex: 1,
    //                                                           child:
    //                                                               AutoSizeText(
    //                                                             minFontSize:
    //                                                                 8,
    //                                                             maxFontSize:
    //                                                                 12,
    //                                                             textAlign:
    //                                                                 TextAlign
    //                                                                     .end,
    //                                                             '${nFormat.format(sum_tran_fine)}',
    //                                                             style: const TextStyle(
    //                                                                 color: Colors.red,
    //                                                                 //fontWeight: FontWeight.bold,
    //                                                                 fontFamily: Font_.Fonts_T),
    //                                                           ),
    //                                                         ),
    //                                                       ],
    //                                                     ),
    //                                               sum_tran_fine == 0
    //                                                   ? SizedBox()
    //                                                   : Row(
    //                                                       children: [
    //                                                         Expanded(
    //                                                           flex: 1,
    //                                                           child: Translate.TranslateAndSetText(
    //                                                               'ยอดค่าบริการ',
    //                                                               PeopleChaoScreen_Color
    //                                                                   .Colors_Text2_,
    //                                                               TextAlign
    //                                                                   .start,
    //                                                               null,
    //                                                               Font_
    //                                                                   .Fonts_T,
    //                                                               12,
    //                                                               1),
    //                                                           // AutoSizeText(
    //                                                           //   minFontSize: 10,
    //                                                           //   maxFontSize: 15,
    //                                                           //   'ยอดค่าบริการ',
    //                                                           //   style: TextStyle(
    //                                                           //       color: PeopleChaoScreen_Color
    //                                                           //           .Colors_Text2_,
    //                                                           //       //fontWeight: FontWeight.bold,
    //                                                           //       fontFamily: Font_
    //                                                           //           .Fonts_T),
    //                                                           // ),
    //                                                         ),
    //                                                         Expanded(
    //                                                           flex: 1,
    //                                                           child:
    //                                                               AutoSizeText(
    //                                                             minFontSize:
    //                                                                 8,
    //                                                             maxFontSize:
    //                                                                 12,
    //                                                             textAlign:
    //                                                                 TextAlign
    //                                                                     .end,
    //                                                             '${nFormat.format(sum_amt - sum_tran_fine)}',
    //                                                             style: const TextStyle(
    //                                                                 color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                                 //fontWeight: FontWeight.bold,
    //                                                                 fontFamily: Font_.Fonts_T),
    //                                                           ),
    //                                                         ),
    //                                                       ],
    //                                                     ),
    //                                               Row(
    //                                                 children: [
    //                                                   const Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       'รวม(บาท)',
    //                                                       style: TextStyle(
    //                                                           color: PeopleChaoScreen_Color
    //                                                               .Colors_Text2_,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       textAlign:
    //                                                           TextAlign.end,
    //                                                       '${nFormat.format(sum_pvat)}',
    //                                                       style:
    //                                                           const TextStyle(
    //                                                               color: PeopleChaoScreen_Color
    //                                                                   .Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily:
    //                                                                   Font_
    //                                                                       .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               Row(
    //                                                 children: [
    //                                                   const Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       'ภาษีมูลค่าเพิ่ม(vat)',
    //                                                       style: TextStyle(
    //                                                           color: PeopleChaoScreen_Color
    //                                                               .Colors_Text2_,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       textAlign:
    //                                                           TextAlign.end,
    //                                                       '${nFormat.format(sum_vat)}',
    //                                                       style:
    //                                                           const TextStyle(
    //                                                               color: PeopleChaoScreen_Color
    //                                                                   .Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily:
    //                                                                   Font_
    //                                                                       .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               Row(
    //                                                 children: [
    //                                                   const Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       'หัก ณ ที่จ่าย',
    //                                                       style: TextStyle(
    //                                                           color: PeopleChaoScreen_Color
    //                                                               .Colors_Text2_,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       textAlign:
    //                                                           TextAlign.end,
    //                                                       '${nFormat.format(sum_wht)}',
    //                                                       style:
    //                                                           const TextStyle(
    //                                                               color: PeopleChaoScreen_Color
    //                                                                   .Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily:
    //                                                                   Font_
    //                                                                       .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               Row(
    //                                                 children: [
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: Translate.TranslateAndSetText(
    //                                                         'ส่วนลดรายการ',
    //                                                         PeopleChaoScreen_Color
    //                                                             .Colors_Text2_,
    //                                                         TextAlign.start,
    //                                                         null,
    //                                                         Font_.Fonts_T,
    //                                                         12,
    //                                                         1),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       textAlign:
    //                                                           TextAlign.end,
    //                                                       '${nFormat.format(sum_tran_dis)}',
    //                                                       style:
    //                                                           const TextStyle(
    //                                                               color: PeopleChaoScreen_Color
    //                                                                   .Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily:
    //                                                                   Font_
    //                                                                       .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               // const Divider(),
    //                                               Row(
    //                                                 children: [
    //                                                   const Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       'ยอดรวม',
    //                                                       style: TextStyle(
    //                                                           color: PeopleChaoScreen_Color
    //                                                               .Colors_Text2_,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       textAlign:
    //                                                           TextAlign.end,
    //                                                       '${nFormat.format(sum_amt)}',
    //                                                       style:
    //                                                           const TextStyle(
    //                                                               color: PeopleChaoScreen_Color
    //                                                                   .Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily:
    //                                                                   Font_
    //                                                                       .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               Row(
    //                                                 children: [
    //                                                   Expanded(
    //                                                     flex: 2,
    //                                                     child: Row(
    //                                                       children: [
    //                                                         const AutoSizeText(
    //                                                           minFontSize:
    //                                                               12,
    //                                                           maxFontSize:
    //                                                               14,
    //                                                           'ส่วนลด',
    //                                                           style: TextStyle(
    //                                                               color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily: Font_.Fonts_T),
    //                                                         ),
    //                                                         const SizedBox(
    //                                                           width: 10,
    //                                                         ),
    //                                                         SizedBox(
    //                                                           width: 60,
    //                                                           height: 20,
    //                                                           child:
    //                                                               TextFormField(
    //                                                             keyboardType:
    //                                                                 TextInputType
    //                                                                     .number,
    //                                                             controller:
    //                                                                 sum_disp,
    //                                                             onFieldSubmitted:
    //                                                                 (value) async {
    //                                                               var valuenum =
    //                                                                   double.parse(
    //                                                                       value);
    //                                                               var sum =
    //                                                                   ((sum_amt * valuenum) /
    //                                                                       100);

    //                                                               setState(
    //                                                                   () {
    //                                                                 red_Vocher();
    //                                                                 ser_vocher =
    //                                                                     '';
    //                                                                 sum_dis =
    //                                                                     sum;
    //                                                                 sum_disamt.text =
    //                                                                     sum.toString();
    //                                                               });

    //                                                               print(
    //                                                                   'sum_dis $sum_dis');
    //                                                             },
    //                                                             cursorColor:
    //                                                                 Colors
    //                                                                     .black,
    //                                                             decoration: InputDecoration(
    //                                                                 fillColor: Colors.white.withOpacity(0.3),
    //                                                                 filled: true,
    //                                                                 // prefixIcon:
    //                                                                 //     const Icon(Icons.person, color: Colors.black),
    //                                                                 // suffixIcon: Icon(Icons.clear, color: Colors.black),
    //                                                                 focusedBorder: const OutlineInputBorder(
    //                                                                   borderRadius:
    //                                                                       BorderRadius.only(
    //                                                                     topRight:
    //                                                                         Radius.circular(5),
    //                                                                     topLeft:
    //                                                                         Radius.circular(5),
    //                                                                     bottomRight:
    //                                                                         Radius.circular(5),
    //                                                                     bottomLeft:
    //                                                                         Radius.circular(5),
    //                                                                   ),
    //                                                                   borderSide:
    //                                                                       BorderSide(
    //                                                                     width:
    //                                                                         1,
    //                                                                     color:
    //                                                                         Colors.black,
    //                                                                   ),
    //                                                                 ),
    //                                                                 enabledBorder: const OutlineInputBorder(
    //                                                                   borderRadius:
    //                                                                       BorderRadius.only(
    //                                                                     topRight:
    //                                                                         Radius.circular(5),
    //                                                                     topLeft:
    //                                                                         Radius.circular(5),
    //                                                                     bottomRight:
    //                                                                         Radius.circular(5),
    //                                                                     bottomLeft:
    //                                                                         Radius.circular(5),
    //                                                                   ),
    //                                                                   borderSide:
    //                                                                       BorderSide(
    //                                                                     width:
    //                                                                         1,
    //                                                                     color:
    //                                                                         Colors.grey,
    //                                                                   ),
    //                                                                 ),
    //                                                                 // labelText: 'ระบุชื่อร้านค้า',
    //                                                                 labelStyle: const TextStyle(
    //                                                                     color: Colors.black54,
    //                                                                     fontSize: 8,

    //                                                                     //fontWeight: FontWeight.bold,
    //                                                                     fontFamily: Font_.Fonts_T)),
    //                                                             inputFormatters: <TextInputFormatter>[
    //                                                               FilteringTextInputFormatter
    //                                                                   .allow(
    //                                                                       RegExp(r'[0-9 .]')),
    //                                                               // FilteringTextInputFormatter.digitsOnly
    //                                                             ],
    //                                                           ),
    //                                                         ),
    //                                                         const SizedBox(
    //                                                           width: 10,
    //                                                         ),
    //                                                         const AutoSizeText(
    //                                                           minFontSize:
    //                                                               12,
    //                                                           maxFontSize:
    //                                                               14,
    //                                                           '%',
    //                                                           style: TextStyle(
    //                                                               color: PeopleChaoScreen_Color.Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily: Font_.Fonts_T),
    //                                                         ),
    //                                                       ],
    //                                                     ),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: SizedBox(
    //                                                       width: 20,
    //                                                       height: 20,
    //                                                       child:
    //                                                           TextFormField(
    //                                                         keyboardType:
    //                                                             TextInputType
    //                                                                 .number,
    //                                                         showCursor:
    //                                                             true,
    //                                                         //add this line
    //                                                         readOnly: false,

    //                                                         // initialValue: sum_disamt.text,
    //                                                         textAlign:
    //                                                             TextAlign
    //                                                                 .end,
    //                                                         controller:
    //                                                             sum_disamt,
    //                                                         onFieldSubmitted:
    //                                                             (value) async {
    //                                                           var valuenum =
    //                                                               double.parse(
    //                                                                   value);

    //                                                           setState(() {
    //                                                             sum_dis =
    //                                                                 valuenum;
    //                                                             // sum_disamt.text =
    //                                                             //     nFormat.format(sum_disamt);
    //                                                             sum_disp
    //                                                                 .clear();
    //                                                           });

    //                                                           print(
    //                                                               'sum_dis $sum_dis');
    //                                                         },
    //                                                         cursorColor:
    //                                                             Colors
    //                                                                 .black,
    //                                                         decoration: InputDecoration(
    //                                                             fillColor: Colors.white.withOpacity(0.3),
    //                                                             filled: true,
    //                                                             // prefixIcon:
    //                                                             //     const Icon(Icons.person, color: Colors.black),
    //                                                             // suffixIcon: Icon(Icons.clear, color: Colors.black),
    //                                                             focusedBorder: const OutlineInputBorder(
    //                                                               borderRadius:
    //                                                                   BorderRadius
    //                                                                       .only(
    //                                                                 topRight:
    //                                                                     Radius.circular(5),
    //                                                                 topLeft:
    //                                                                     Radius.circular(5),
    //                                                                 bottomRight:
    //                                                                     Radius.circular(5),
    //                                                                 bottomLeft:
    //                                                                     Radius.circular(5),
    //                                                               ),
    //                                                               borderSide:
    //                                                                   BorderSide(
    //                                                                 width:
    //                                                                     1,
    //                                                                 color: Colors
    //                                                                     .black,
    //                                                               ),
    //                                                             ),
    //                                                             enabledBorder: const OutlineInputBorder(
    //                                                               borderRadius:
    //                                                                   BorderRadius
    //                                                                       .only(
    //                                                                 topRight:
    //                                                                     Radius.circular(5),
    //                                                                 topLeft:
    //                                                                     Radius.circular(5),
    //                                                                 bottomRight:
    //                                                                     Radius.circular(5),
    //                                                                 bottomLeft:
    //                                                                     Radius.circular(5),
    //                                                               ),
    //                                                               borderSide:
    //                                                                   BorderSide(
    //                                                                 // width: 1,
    //                                                                 color: Colors
    //                                                                     .grey,
    //                                                               ),
    //                                                             ),
    //                                                             // labelText: 'ระบุชื่อร้านค้า',
    //                                                             labelStyle: const TextStyle(
    //                                                                 color: Colors.black54,
    //                                                                 fontSize: 8,

    //                                                                 //fontWeight: FontWeight.bold,
    //                                                                 fontFamily: Font_.Fonts_T)),
    //                                                         inputFormatters: <TextInputFormatter>[
    //                                                           FilteringTextInputFormatter
    //                                                               .allow(RegExp(
    //                                                                   r'[0-9 .]')),
    //                                                           // FilteringTextInputFormatter.digitsOnly
    //                                                         ],
    //                                                       ),
    //                                                     ),
    //                                                     // AutoSizeText(
    //                                                     //   minFontSize: 10,
    //                                                     //   maxFontSize: 15,
    //                                                     //   textAlign: TextAlign.end,
    //                                                     //   '${nFormat.format(0.00)}',
    //                                                     //   style: TextStyle(
    //                                                     //       color: PeopleChaoScreen_Color
    //                                                     //           .Colors_Text2_,
    //                                                     //       //fontWeight: FontWeight.bold,
    //                                                     //       fontFamily: Font_.Fonts_T),
    //                                                     // ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               Row(
    //                                                 children: [
    //                                                   const Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       'ยอดชำระ',
    //                                                       style: TextStyle(
    //                                                           color: PeopleChaoScreen_Color
    //                                                               .Colors_Text2_,
    //                                                           //fontWeight: FontWeight.bold,
    //                                                           fontFamily: Font_
    //                                                               .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       textAlign:
    //                                                           TextAlign.end,
    //                                                       '${nFormat.format(sum_amt - double.parse(sum_disamt.text))}',
    //                                                       style:
    //                                                           const TextStyle(
    //                                                               color: PeopleChaoScreen_Color
    //                                                                   .Colors_Text2_,
    //                                                               //fontWeight: FontWeight.bold,
    //                                                               fontFamily:
    //                                                                   Font_
    //                                                                       .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                               SizedBox(
    //                                                 height: 2,
    //                                               ),
    //                                               const Divider(),
    //                                               SizedBox(
    //                                                 height: 2,
    //                                               ),
    //                                               Row(
    //                                                 children: [
    //                                                   Expanded(
    //                                                     flex: 1,
    //                                                     child: AutoSizeText(
    //                                                       minFontSize: 12,
    //                                                       maxFontSize: 14,
    //                                                       'รายการทั้งหมด : ${_TransModels.length}',
    //                                                       style: TextStyle(
    //                                                           color: PeopleChaoScreen_Color
    //                                                               .Colors_Text2_,
    //                                                           fontWeight:
    //                                                               FontWeight
    //                                                                   .bold,
    //                                                           fontFamily:
    //                                                               FontWeight_
    //                                                                   .Fonts_T),
    //                                                     ),
    //                                                   ),
    //                                                   Expanded(
    //                                                     flex: 2,
    //                                                     child:
    //                                                         ElevatedButton
    //                                                             .icon(
    //                                                       style:
    //                                                           ElevatedButton
    //                                                               .styleFrom(
    //                                                         backgroundColor:
    //                                                             Colors
    //                                                                 .green,
    //                                                         foregroundColor:
    //                                                             Colors
    //                                                                 .white,
    //                                                         shape:
    //                                                             RoundedRectangleBorder(
    //                                                           borderRadius:
    //                                                               BorderRadius
    //                                                                   .circular(
    //                                                                       6),
    //                                                         ),
    //                                                       ),
    //                                                       icon: const Icon(
    //                                                           Icons
    //                                                               .receipt_outlined,
    //                                                           size: 18),
    //                                                       label: const Text(
    //                                                           'ดำเนินการต่อ',
    //                                                           style: TextStyle(
    //                                                               fontWeight:
    //                                                                   FontWeight
    //                                                                       .bold,
    //                                                               fontFamily:
    //                                                                   FontWeight_
    //                                                                       .Fonts_T)),
    //                                                       onPressed: _TransModels
    //                                                                   .length <
    //                                                               1
    //                                                           ? null
    //                                                           : () async {
    //                                                               dialogOk(
    //                                                                   context);
    //                                                             },
    //                                                     ),
    //                                                   ),
    //                                                 ],
    //                                               ),
    //                                             ]),
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ],
    //                                   ),
    //                                 ],
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
  }

///////////////-------------------------------------------->

  Future<void> dialogOk(BuildContext context) {
    // วางนอก onPressed (เช่นเป็นฟิลด์ของ State)
    bool _savingInvoice = false;
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
        return StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
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
                      child: Text(
                        'ยืนยันการวางบิล',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child:
                            Icon(Icons.close, size: 22, color: Colors.black54),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color:
                                          Colors.deepPurple.withOpacity(0.25)),
                                ),
                                child: Text(
                                  'จำนวนรายการ',
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
                                  '${_TransModels.length}',
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
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.18)),
                          ),
                          child: Text(
                            'ตรวจสอบข้อมูลให้ถูกต้องก่อนยืนยันการทำรายการ',
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
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red[50]!.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: Colors.black12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 8),
                                      child: Text(
                                        nFormat.format(
                                          sum_amt -
                                              (double.tryParse(
                                                      sum_disamt.text) ??
                                                  0),
                                        ),
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
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

                              // วันที่ครบกำหนด
                              InkWell(
                                onTap: () async => select_Date(context),
                                borderRadius: BorderRadius.circular(10),
                                child: Row(
                                  children: [
                                    const Text(
                                      'วันที่ครบกำหนดชำระ : ',
                                      style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color:
                                              Colors.blue[50]!.withOpacity(0.6),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border:
                                              Border.all(color: Colors.black12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: StreamBuilder(
                                                    stream: Stream.periodic(
                                                        const Duration(
                                                            seconds: 1)),
                                                    builder:
                                                        (context, snapshot) {
                                                      return Text(
                                                        DateFormat('dd-MM-yyyy')
                                                            .format(DateTime.parse(
                                                                '$End_Bill_Paydate')),
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          fontSize: 13,
                                                        ),
                                                      );
                                                    })),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.arrow_drop_down,
                                                color: Colors.black54),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),

                              // หัวบิล
                              Row(
                                children: [
                                  const Text(
                                    'หัวบิล :',
                                    style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                      items: TitleType_Default_Receipt_.map(
                                          (item) {
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
                                        final i = TitleType_Default_Receipt_
                                            .indexWhere((e) => e == value);
                                        setState(() =>
                                            TitleType_Default_Receipt = i);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // รูปแบบชำระ
                              Row(
                                children: [
                                  const Text(
                                    'รูปแบบชำระ :',
                                    style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      width: 320,
                                      height: 45,
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFFE0E0E0)),
                                      ),
                                      child: DropdownButtonFormField2<String>(
                                        value: selectedPaymentKey,
                                        isExpanded: true,
                                        dropdownMaxHeight: 280,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        hint: Text(paymentName1 ?? 'เลือก',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T)),
                                        icon: const Icon(Icons.arrow_drop_down,
                                            color: Colors.black45),
                                        iconSize: 22,
                                        buttonHeight: 60,
                                        buttonPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10),
                                        dropdownDecoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        items: _PayMentModels.map((it) =>
                                            DropdownMenuItem<String>(
                                              value: '${it.ser}:${it.ptname}',
                                              child: _tile(it),
                                            )).toList(),
                                        selectedItemBuilder: (_) =>
                                            _PayMentModels.map(_tile).toList(),
                                        onChanged: (v) {
                                          if (v == null) return;
                                          final i = v.indexOf(':'),
                                              ser = v.substring(0, i),
                                              name = v.substring(i + 1);
                                          setState(() {
                                            selectedPaymentKey = v;
                                            paymentSer1 = ser;
                                            paymentName1 =
                                                (ser == '0') ? null : name;
                                          });
                                        },
                                      ),
                                    ),
                                    // DropdownButtonFormField2(
                                    //   isExpanded: true,
                                    //   decoration: InputDecoration(
                                    //     isDense: true,
                                    //     contentPadding: EdgeInsets.zero,
                                    //     border: OutlineInputBorder(
                                    //       borderRadius: BorderRadius.circular(12),
                                    //     ),
                                    //   ),
                                    //   hint: Padding(
                                    //     padding: const EdgeInsets.symmetric(
                                    //         horizontal: 10),
                                    //     child: Text(
                                    //       '$paymentName1',
                                    //       style: const TextStyle(
                                    //         fontSize: 14,
                                    //         color:
                                    //             PeopleChaoScreen_Color.Colors_Text2_,
                                    //         fontFamily: Font_.Fonts_T,
                                    //       ),
                                    //     ),
                                    //   ),
                                    //   icon: const Icon(Icons.arrow_drop_down,
                                    //       color: Colors.black45),
                                    //   iconSize: 22,
                                    //   buttonHeight: 44,
                                    //   buttonPadding:
                                    //       const EdgeInsets.symmetric(horizontal: 10),
                                    //   dropdownDecoration: BoxDecoration(
                                    //     borderRadius: BorderRadius.circular(12),
                                    //   ),
                                    //   items: _PayMentModels.map((item) {
                                    //     return DropdownMenuItem<String>(
                                    //       onTap: () => setState(
                                    //           () => selectedValue = item.bno!),
                                    //       value: '${item.ser}:${item.ptname}',
                                    //       child: Row(
                                    //         children: [
                                    //           Expanded(
                                    //             child: Text(
                                    //               '${item.ptname!}',
                                    //               style: const TextStyle(
                                    //                 fontSize: 14,
                                    //                 color: PeopleChaoScreen_Color
                                    //                     .Colors_Text2_,
                                    //                 fontFamily: Font_.Fonts_T,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //           Expanded(
                                    //             child: Text(
                                    //               '${item.bno!}',
                                    //               textAlign: TextAlign.end,
                                    //               style: const TextStyle(
                                    //                 fontSize: 14,
                                    //                 color: PeopleChaoScreen_Color
                                    //                     .Colors_Text2_,
                                    //                 fontFamily: Font_.Fonts_T,
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       ),
                                    //     );
                                    //   }).toList(),
                                    //   onChanged: (value) async {
                                    //     final pos = value!.indexOf(':');
                                    //     final rtnameSer = value.substring(0, pos);
                                    //     final rtnameName = value.substring(pos + 1);
                                    //     setState(() {
                                    //       paymentSer1 = rtnameSer;
                                    //       paymentName1 =
                                    //           (rtnameSer == '0') ? null : rtnameName;
                                    //     });
                                    //   },
                                    // ),
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
                actionsAlignment: MainAxisAlignment
                    .center, // ⬅️ จัดกึ่งกลาง (เฉพาะ AlertDialog)

                actions: [
                  if (paymentName1 == null ||
                      paymentName1.toString() == 'เลือก' ||
                      paymentSer1.toString() == '0' ||
                      paymentSer1 == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '**กรุณาระบุ รูปแบบชำระ',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontFamily: Font_.Fonts_T,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ========== พิมพ์/บันทึก ==========
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor:
                                  PeopleChaoScreen_Color.Colors_Text3_,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: _savingInvoice
                                ? null // กันกดซ้ำระหว่างกำลังบันทึก
                                : () async {
                                    // กันกดซ้ำ
                                    _savingInvoice = true;

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

                                    final navigator =
                                        Navigator.of(ctx); // ใช้ ctx ใน dialog
                                    try {
                                      // 2) เตรียมข้อมูล
                                      final newValuePDFimg = <String>[];
                                      if (renTalModels.isNotEmpty &&
                                          (renTalModels[0].imglogo ?? '')
                                              .trim()
                                              .isNotEmpty) {
                                        newValuePDFimg.add(
                                          '${MyConstant().domain}/files/$foder/logo/${renTalModels[0].imglogo!.trim()}',
                                        );
                                      }

                                      // ใช้ tryParse กันพัง
                                      final tableData003 = [
                                        for (int i = 0;
                                            i < _TransModels.length;
                                            i++)
                                          [
                                            '${i + 1}',
                                            '${_TransModels[i].date}',
                                            '${_TransModels[i].expname}',
                                            nFormat.format(double.tryParse(
                                                    _TransModels[i].nvat ??
                                                        '0') ??
                                                0),
                                            nFormat.format(double.tryParse(
                                                    _TransModels[i].vat ??
                                                        '0') ??
                                                0),
                                            nFormat.format(double.tryParse(
                                                    _TransModels[i].pvat ??
                                                        '0') ??
                                                0),
                                            nFormat.format(double.tryParse(
                                                    _TransModels[i].amt ??
                                                        '0') ??
                                                0),
                                          ],
                                      ];

                                      // 3) งานหลัก
                                      await in_Trans_invoice2(
                                          tableData003, newValuePDFimg);

                                      // 4) ปิด dialog นี้ 1 ครั้งพอ (ถ้ายังเปิด)
                                      if (navigator.canPop()) navigator.pop();

                                      // 5) หน่วง 1 วิ แล้วแจ้งสำเร็จ (ถ้าหน้ายังอยู่)
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      if (ctx.mounted) {
                                        Dialog_success(ctx, 'success');
                                      }
                                    } catch (e) {
                                      debugPrint('in_Trans_invoice error: $e');
                                      if (ctx.mounted) {
                                        Dialog_error(ctx,
                                            'เกิดข้อผิดพลาด: ${e.toString()}');
                                      }
                                    } finally {
                                      // 6) ปิด Loader เสมอ
                                      ChaoAppLoader.hide();

                                      // ปล่อยปุ่มให้กดใหม่ได้
                                      _savingInvoice = false;
                                      if (mounted)
                                        setState(
                                            () {}); // รีเฟรชปุ่ม disabled/enabled
                                    }
                                  },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text('พิมพ์/บันทึก',
                                  style: TextStyle(fontFamily: Font_.Fonts_T)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ========== บันทึก ==========
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800,
                              foregroundColor:
                                  PeopleChaoScreen_Color.Colors_Text3_,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            onPressed: _savingInvoice
                                ? null
                                : () async {
                                    setState(() =>
                                        _savingInvoice = true); // กันกดซ้ำทันที

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

                                    final navigator =
                                        Navigator.of(ctx); // ใช้ ctx ของ dialog

                                    try {
                                      // 2) งานหลัก
                                      await in_Trans_invoice();

                                      // 3) ปิด dialog นี้ 1 ครั้งพอ (ถ้ายังเปิดอยู่)
                                      if (navigator.canPop()) navigator.pop();

                                      // 4) รอ 1 วิ แล้วโชว์ success (ถ้าหน้ายังอยู่)
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      if (ctx.mounted) {
                                        Dialog_success(ctx, 'success');
                                      }
                                    } catch (e) {
                                      debugPrint('in_Trans_invoice error: $e');
                                      if (ctx.mounted) {
                                        Dialog_error(ctx,
                                            'เกิดข้อผิดพลาด: ${e.toString()}');
                                      }
                                    } finally {
                                      // 5) ปิด Loader เสมอ
                                      ChaoAppLoader.hide();

                                      // 6) ปลดล็อกปุ่ม
                                      if (mounted)
                                        setState(() => _savingInvoice = false);
                                    }
                                  },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Text('บันทึก',
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

//////////////////-------------------------------------------->
  Future<Null> de_Trans_select_fine(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var tser = transFineModels[index].ser;
    var tdocno = transFineModels[index].docno;

    // print('tser >>.> $tser');

    String url =
        '${MyConstant().domain}/De_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select();
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<void> addPlaySelect() {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            // title: const Text('AlertDialog Title'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ListBody(
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'เพิ่มรายการชำระ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text1_,
                                fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T
                                //fontSize: 10.0
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          children: [
                            StreamBuilder(
                                stream:
                                    Stream.periodic(const Duration(seconds: 0)),
                                builder: (context, snapshot) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 350,
                                    child: GridView.count(
                                      crossAxisCount:
                                          Responsive.isDesktop(context) ? 5 : 2,
                                      children: [
                                        // Card(
                                        //   child: InkWell(
                                        //     onTap: () async {
                                        //       Navigator.of(context).pop();
                                        //       addPlay();
                                        //     },
                                        //     child:
                                        //         Icon(Icons.add_circle_outline),
                                        //   ),
                                        // ),
                                        for (int i = 0;
                                            i < expModels.length;
                                            i++)
                                          Card(
                                            color: text_add.text ==
                                                    expModels[i].expname
                                                ? Colors.lime
                                                : Colors.white,
                                            child: InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  text_add.text = expModels[i]
                                                      .expname
                                                      .toString();
                                                  price_add.text = expModels[i]
                                                      .pri_auto
                                                      .toString();
                                                });
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      maxLines: 1,
                                                      '${expModels[i].expname}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                    AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 15,
                                                      maxLines: 1,
                                                      '${nFormat.format(double.parse(expModels[i].pri_auto!))}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          //fontWeight: FontWeight.bold,
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Container(
                          height: 350,
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.6 /
                                        2.5,
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        // keyboardType: TextInputType.name,
                                        controller: text_add,

                                        maxLines: 1,
                                        // maxLength: 13,
                                        cursorColor: Colors.green,
                                        decoration: InputDecoration(
                                          fillColor:
                                              Colors.white.withOpacity(0.3),
                                          filled: true,
                                          // prefixIcon:
                                          //     const Icon(Icons.person, color: Colors.black),
                                          // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                          focusedBorder:
                                              const OutlineInputBorder(
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
                                          enabledBorder:
                                              const OutlineInputBorder(
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
                                          labelText: 'รายการชำระ',
                                          labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.6 /
                                        2.5,
                                    height: 50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: price_add,

                                        maxLines: 1,
                                        // maxLength: 13,
                                        cursorColor: Colors.green,
                                        decoration: InputDecoration(
                                          fillColor:
                                              Colors.white.withOpacity(0.3),
                                          filled: true,
                                          // prefixIcon:
                                          //     const Icon(Icons.person, color: Colors.black),
                                          // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                          focusedBorder:
                                              const OutlineInputBorder(
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
                                          enabledBorder:
                                              const OutlineInputBorder(
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
                                          labelText: 'ยอดชำระ',
                                          labelStyle: const TextStyle(
                                            color: PeopleChaoScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight: FontWeight.bold,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        child: Container(
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.green.shade900,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              // border: Border.all(color: Colors.white, width: 1),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Center(
                                child: Text(
                              'ตกลง',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T
                                  //fontSize: 10.0
                                  ),
                            ))),
                        onTap: () {
                          if (text_add.text != '' && price_add.text != '') {
                            if (price_add.text != '0') {
                              in_Trans_add();
                              Navigator.of(context).pop();
                            }
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
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
                              // border: Border.all(color: Colors.white, width: 1),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Center(
                                child: Text(
                              'ปิด',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontWeight_.Fonts_T
                                  //fontSize: 10.0
                                  ),
                            ))),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<Null> de_Trans_item(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var tser = _TransModels[index].ser;
    var tdocno = _TransModels[index].docno;
    var poslok = Formposlok_.text;

    // print('tser >>.> $tser');

    String url =
        '${MyConstant().domain}/De_tran_item.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user&poslok=$poslok';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          // Navigator.pop(context);
          // Navigator.pop(context);
          Formpasslok_.clear();
          Formposlok_.clear();
          red_Trans_select();
          red_Trans_bill();
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> in_Trans_add() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var textadd = text_add.text;
    var priceadd = price_add.text;
    var dtypeadd = '';

    String url =
        '${MyConstant().domain}/In_tran_select_add.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&textadd=$textadd&priceadd=$priceadd&user=$user&dtypeadd=$dtypeadd';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('rr>>>>>> $result');
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_bill();
          red_Trans_select();
          text_add.clear();
          price_add.clear();
        });
        print('rrrrrrrrrrrrrr');
      } else if (result.toString() == 'false') {
        setState(() {
          red_Trans_bill();
          red_Trans_select();
          text_add.clear();
          price_add.clear();
        });
        print('rrrrrrrrrrrrrrfalse');
      } else {
        setState(() {
          red_Trans_bill();
          red_Trans_select();
          text_add.clear();
          price_add.clear();
        });
      }
    } catch (e) {
      print('rrrrrrrrrrrrrr $e');
    }
  }

  Future<Null> deall_Trans_select() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/D_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_bill();
          red_Trans_select();
          sum_disamt.text = '0.00';
          sum_disp.clear();
        });
        print('rrrrrrrrrrrrrr');
      }
    } catch (e) {
      print('rrrrrrrrrrrrrr $e');
    }
  }

  Future<Null> in_Trans_invoice() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var renTal_name = preferences.getString('renTalName');
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    var sumdis = sum_disamt.text;
    var sumdisp = sum_disp.text;
    // var dislist_total = total_dislist;

    var sumtotal = (sum_amt - double.tryParse(sum_disamt.text)!);
    var c_payment_Ser = await paymentSer1;
    var End_Bill_Paydate_ = await End_Bill_Paydate;
    var ser_dis_vocher = ser_vocher;

    String? cFinn;
    String url = '${MyConstant().domain}/In_tran_invoice.php';
    print({
      'isAdd': 'true',
      'ren': ren ?? '',
      'ciddoc': ciddoc ?? '',
      'qutser': qutser ?? '',
      'user': user ?? '',
      'sumdis': sumdis ?? '0',
      'sumdisp': sumdisp ?? '0',
      'pay_Ser1': c_payment_Ser ?? '',
      'pay_date': End_Bill_Paydate_ ?? '',
      'sumtotal': sumtotal.toStringAsFixed(2),
      'ser_dis': ser_dis_vocher ?? '0',
      'dislist': '0',
    });

    try {
      var response = await httpClient.post(
        Uri.parse(url),
        // headers: {
        //   'Content-Type': 'application/x-www-form-urlencoded',
        // },
        body: {
          'isAdd': 'true',
          'ren': ren ?? '',
          'ciddoc': ciddoc ?? '',
          'qutser': qutser ?? '',
          'user': user ?? '',
          'sumdis': sumdis ?? '0',
          'sumdisp': sumdisp ?? '0',
          'pay_Ser1': c_payment_Ser ?? '',
          'pay_date': End_Bill_Paydate_ ?? '',
          'sumtotal': sumtotal.toStringAsFixed(2),
          'ser_dis': ser_dis_vocher ?? '0',
          'dislist': '0',
        },
      );

      var result = json.decode(response.body);
      print('In_tran_invoice response : ${response.body}');
      if (result.toString() != 'No') {
        for (var map in result) {
          TransBillModel transBillModel = TransBillModel.fromJson(map);
          setState(() {
            cFinn = transBillModel.docno;
          });
          print('✅ docno: $cFinn');
        }

        Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>บันทึก($ciddoc)');

        setState(() {
          red_Trans_bill();
          red_Trans_select();
          red_Vocher();
          ser_vocher = '0';
          sum_disamt.text = '0.00';
          sum_disp.clear();
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('บันทึกรายการวางบิลสำเร็จ',
        //         style:
        //             TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T)),
        //   ),
        // );
      }
    } catch (e) {
      print('❌ Error during POST: $e');
    }

    // ✅ fallback ซ้ำหลัง 200ms
    Future.delayed(const Duration(milliseconds: 200), () async {
      setState(() {
        red_Trans_bill();
        red_Trans_select();
        red_Vocher();
        ser_vocher = '0';
        sum_disamt.text = '0.00';
        sum_disp.clear();
      });
    });
  }

  // Future<Null> in_Trans_invoice() async {

  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var renTal_name = preferences.getString('renTalName');
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;
  //   var sumdis = sum_disamt.text;
  //   var sumdisp = sum_disp.text;
  //   var dislist_total = Formposlokdispri_.text;

  //   var sumtotal = (sum_amt - double.parse(sum_disamt.text));
  //   var c_payment_Ser = await paymentSer1;
  //   var End_Bill_Paydate_ = await End_Bill_Paydate;
  //   var ser_dis_vocher = ser_vocher;
  //   print('End_Bill_Paydate_>>>>  $End_Bill_Paydate_');
  //   String? cFinn;
  //   String url =
  //       '${MyConstant().domain}/In_tran_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&pay_Ser1=$c_payment_Ser&pay_date=$End_Bill_Paydate_&sumtotal=$sumtotal&ser_dis=$ser_dis_vocher&dislist=$dislist_total';
  //   try {
  //     var response = await httpClient.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     // print(result);
  //     if (result.toString() != 'No') {
  //       for (var map in result) {
  //         TransBillModel transBillModel = TransBillModel.fromJson(map);
  //         setState(() {
  //           cFinn = transBillModel.docno;
  //         });
  //         print('zzzzasaaa123454>>>>  $cFinn');
  //         print('docnodocnodocnodocnodocno123456>>>>  ${transBillModel.docno}');
  //       }

  //       Insert_log.Insert_logs(
  //           'ผู้เช่า', 'วางบิล>>บันทึก(${ciddoc.toString()})');
  //       setState(() {
  //         red_Trans_bill();
  //         red_Trans_select();
  //         red_Vocher();
  //         ser_vocher = '0';
  //         sum_disamt.text = '0.00';
  //         sum_disp.clear();
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //             content: Text('บันทึกรายการวางบิลสำเร็จ',
  //                 style: TextStyle(
  //                     color: Colors.white, fontFamily: Font_.Fonts_T))),
  //       );
  //       print('rrrrrrrrrrrrrr');
  //     }
  //   } catch (e) {}

  //   Future.delayed(const Duration(milliseconds: 200), () async {
  //     setState(() {
  //       red_Trans_bill();
  //       red_Trans_select();
  //       red_Vocher();
  //       ser_vocher = '0';
  //       sum_disamt.text = '0.00';
  //       sum_disp.clear();
  //     });
  //   });
  // }
  Future<void> in_Trans_invoice2(
      List<List<dynamic>> tableData003, List<String> newValuePDFimg) async {
    final prefs = await SharedPreferences.getInstance();
    final renTalName = prefs.getString('renTalName') ?? '';
    final ren = prefs.getString('renTalSer') ?? '';
    final user = prefs.getString('ser') ?? '';

    final ciddoc = widget.Get_Value_cid;
    final qutser = widget.Get_Value_NameShop_index;

    final sumdis = sum_disamt.text; // จำนวนเงินส่วนลด
    final sumdisp = sum_disp.text; // ส่วนลด %
    final sumtotal = (sum_amt - (double.tryParse(sum_disamt.text) ?? 0));
    final dislistTotal = total_dislist;

    final cPaymentSer = paymentSer1; // ไม่ต้อง await ถ้าเป็น String ปกติ
    final payDate = End_Bill_Paydate; // เช่น '2025-09-29'
    final serDisVoucher = ser_vocher;

    final url = '${MyConstant().domain}/In_tran_invoice.php';

    try {
      final resp = await _dio.post(
        url,
        data: {
          'isAdd': 'true',
          'ren': ren,
          'ciddoc': '$ciddoc',
          'qutser': '$qutser',
          'user': user,
          'sumdis': sumdis.isEmpty ? '0' : sumdis,
          'sumdisp': sumdisp.isEmpty ? '0' : sumdisp,
          'pay_Ser1': cPaymentSer ?? '',
          'pay_date': payDate ?? '',
          'sumtotal': sumtotal.toStringAsFixed(2),
          'ser_dis': serDisVoucher ?? '0',
          'dislist': (dislistTotal ?? '0').toString(),
        },
        options: Options(
          responseType: ResponseType.plain, // PHP ส่ง string/plain
          contentType: Headers.formUrlEncodedContentType, // ส่งแบบ form-encoded
          receiveDataWhenStatusError: true,
        ),
      );

      final code = resp.statusCode;
      final raw = (resp.data ?? '').toString().trim();

      if (code != 200) {
        // HTTP ไม่ใช่ 200
        try {
          final obj = json.decode(raw);
          final msg = (obj is Map && obj['error'] != null)
              ? obj['error'].toString()
              : raw;
          debugPrint('HTTP $code: $msg');
        } catch (_) {
          debugPrint('HTTP $code: $raw');
        }
        return;
      }

      if (raw == 'No') {
        debugPrint('❌ In_tran_invoice.php returned "No"');
        return;
      }

      dynamic result;
      try {
        result = json.decode(raw);
      } catch (_) {
        debugPrint('❌ JSON decode failed: $raw');
        return;
      }

      String? docnoInv;
      if (result is List) {
        for (final map in result) {
          try {
            final model = TransBillModel.fromJson(map as Map<String, dynamic>);
            docnoInv = model.docno;
            debugPrint('✅ docno: $docnoInv');
          } catch (e) {
            debugPrint('parse TransBillModel error: $e');
          }
        }
      }

      Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>บันทึก($docnoInv)');

      // เรียกฟังก์ชันสร้างใบแจ้งหนี้หลัง delay 1 วิ (ไม่บล็อก UI)
      if (docnoInv != null && docnoInv!.isNotEmpty) {
        Future.delayed(const Duration(seconds: 1), () {
          BillingNoteInvlice_Tempage(
            tableData003,
            newValuePDFimg,
            docnoInv!,
            renTalName,
          );
        });
      }

      // รีเฟรชข้อมูลใน UI (รันให้เสร็จจริง)
      await red_Trans_bill();
      await red_Trans_select();
      await red_Vocher();

      // reset ค่าหน้า UI
      if (mounted) {
        setState(() {
          ser_vocher = '0';
          sum_disamt.text = '0.00';
          sum_disp.clear();
        });
      }

      debugPrint('✅ วางบิลสำเร็จ');
    } on DioException catch (e) {
      final type = e.type;
      if (type == DioExceptionType.connectionTimeout ||
          type == DioExceptionType.receiveTimeout ||
          type == DioExceptionType.sendTimeout) {
        debugPrint('⏱️ Timeout: ${e.message}');
      } else {
        debugPrint('❌ Dio error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ in_Trans_invoice2 error: $e');
    }
  }

  // Future<Null> in_Trans_invoice2(tableData003, newValuePDFimg) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var renTal_name = preferences.getString('renTalName');
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;
  //   var sumdis = sum_disamt.text;
  //   var sumdisp = sum_disp.text;
  //   var sumtotal = (sum_amt - double.tryParse(sum_disamt.text)!);
  //   var dislist_total = total_dislist;

  //   var c_payment_Ser = await paymentSer1;
  //   var End_Bill_Paydate_ = await End_Bill_Paydate;
  //   var ser_dis_vocher = ser_vocher;

  //   String url = '${MyConstant().domain}/In_tran_invoice.php';
  //   // print('📡 POST: in_Trans_invoice2');
  //   // print({
  //   //   'isAdd': 'true',
  //   //   'ren': ren ?? '',
  //   //   'ciddoc': ciddoc ?? '',
  //   //   'qutser': qutser ?? '',
  //   //   'user': user ?? '',
  //   //   'sumdis': sumdis ?? '0',
  //   //   'sumdisp': sumdisp ?? '0',
  //   //   'pay_Ser1': c_payment_Ser ?? '',
  //   //   'pay_date': End_Bill_Paydate_ ?? '',
  //   //   'sumtotal': sumtotal.toStringAsFixed(2),
  //   //   'ser_dis': ser_dis_vocher ?? '0',
  //   //   'dislist': dislist_total ?? '0',
  //   // });
  //   try {
  //     final response = await httpClient.post(
  //       Uri.parse(url),
  //       // headers: {
  //       //   'Content-Type': 'application/x-www-form-urlencoded',
  //       // },
  //       body: {
  //         'isAdd': 'true',
  //         'ren': ren ?? '',
  //         'ciddoc': ciddoc ?? '',
  //         'qutser': qutser ?? '',
  //         'user': user ?? '',
  //         'sumdis': sumdis ?? '0',
  //         'sumdisp': sumdisp ?? '0',
  //         'pay_Ser1': c_payment_Ser ?? '',
  //         'pay_date': End_Bill_Paydate_ ?? '',
  //         'sumtotal': sumtotal.toStringAsFixed(2),
  //         'ser_dis': ser_dis_vocher ?? '0',
  //         'dislist': '0',
  //       },
  //     );

  //     final result = json.decode(response.body);

  //     if (result.toString() != 'No') {
  //       String? docno_inv;
  //       print('✅ result: $result');
  //       for (var map in result) {
  //         TransBillModel transBillModel = TransBillModel.fromJson(map);
  //         docno_inv = transBillModel.docno;
  //         print('✅ docno: $docno_inv');
  //       }

  //       Insert_log.Insert_logs('ผู้เช่า', 'วางบิล>>บันทึก($docno_inv)');

  //       // เรียกฟังก์ชันสร้างใบแจ้งหนี้หลัง delay 1 วิ
  //       Future.delayed(const Duration(seconds: 1), () {
  //         if (docno_inv != null && docno_inv.isNotEmpty) {
  //           BillingNoteInvlice_Tempage(
  //             tableData003,
  //             newValuePDFimg,
  //             docno_inv,
  //             renTal_name,
  //           );
  //         }
  //       });

  //       // รีเฟรชข้อมูลใน UI
  //       await red_Trans_bill();
  //       red_Trans_select();
  //       red_Vocher();

  //       setState(() {
  //         ser_vocher = '0';
  //         sum_disamt.text = '0.00';
  //         sum_disp.clear();
  //       });

  //       print('✅ วางบิลสำเร็จ');
  //     }
  //   } catch (e) {
  //     print('❌ POST Error in in_Trans_invoice2: $e');
  //   }
  // }

  // Future<Null> in_Trans_invoice2(tableData003, newValuePDFimg) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var renTal_name = preferences.getString('renTalName');
  //   var ren = preferences.getString('renTalSer');
  //   var user = preferences.getString('ser');
  //   var ciddoc = widget.Get_Value_cid;
  //   var qutser = widget.Get_Value_NameShop_index;
  //   var sumdis = sum_disamt.text;
  //   var sumdisp = sum_disp.text;
  //   var c_payment_Ser = await paymentSer1;
  //   var End_Bill_Paydate_ = await End_Bill_Paydate;
  //   var ser_dis_vocher = ser_vocher;

  //   String? cFinn;
  //   String url =
  //       '${MyConstant().domain}/In_tran_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&user=$user&sumdis=$sumdis&sumdisp=$sumdisp&pay_Ser1=$c_payment_Ser&pay_date=$End_Bill_Paydate_&ser_dis=$ser_dis_vocher';
  //   print('in_Trans_invoice2');
  //   print(url);
  //   try {
  //     var response = await httpClient.get(Uri.parse(url));

  //     var result = json.decode(response.body);
  //     print(result);
  //     if (result.toString() != 'No') {
  //       String? docno_inv;
  //       for (var map in result) {
  //         TransBillModel transBillModel = TransBillModel.fromJson(map);
  //         setState(() {
  //           cFinn = transBillModel.docno;
  //           docno_inv = transBillModel.docno.toString();
  //         });
  //         print('zzzzasaaa123454>>>>  $cFinn');
  //         print('docnodocnodocnodocnodocno123456>>>>  ${transBillModel.docno}');
  //       }
  //       Insert_log.Insert_logs(
  //           'ผู้เช่า', 'วางบิล>>บันทึก(${docno_inv.toString()})');
  //       //////////----------------------->
  //       Future.delayed(const Duration(seconds: 1), () {
  //         print('One second has passed. $docno_inv'); // Prints after 1 second.
  //         if (docno_inv != null && docno_inv != '') {
  //           BillingNoteInvlice_Tempage(
  //               tableData003, newValuePDFimg, docno_inv, renTal_name);
  //         }
  //       });

  //       //////////*////////////----------------------->

  //       setState(() async {
  //         await red_Trans_bill();
  //         red_Trans_select();
  //         red_Vocher();
  //         ser_vocher = '0';
  //         sum_disamt.text = '0.00';
  //         sum_disp.clear();
  //       });
  //       print('rrrrrrrrrrrrrr');
  //     }
  //   } catch (e) {}
  // }

//////////////////////////------------------------------>
  Future<Null> BillingNoteInvlice_Tempage(
      tableData003, newValuePDFimg, cFinn, renTal_name) async {
    String? TitleType_Default_Receipt_Name;
    if (TitleType_Default_Receipt == 0) {
    } else {
      setState(() {
        TitleType_Default_Receipt_Name =
            '${TitleType_Default_Receipt_[TitleType_Default_Receipt]}';
      });
    }
    var selectedValue_bank_bno = selectedValue;
    Man_BillingNoteInvlice_PDF.ManBillingNoteInvlice_PDF(
        TitleType_Default_Receipt_Name,
        foder,
        '${widget.Get_Value_NameShop_index}',
        tem_page_ser,
        context,
        '${widget.Get_Value_cid}',
        '${widget.namenew}',
        '${renTalModels[0].bill_addr}',
        '${renTalModels[0].bill_email}',
        '${renTalModels[0].bill_tel}',
        '${renTalModels[0].bill_tax}',
        '${renTalModels[0].bill_name}',
        newValuePDFimg,
        cFinn,
        '0');
  }
}

// class PreviewPdfgen_Bills extends StatelessWidget {
//   final pw.Document doc;
//   final renTal_name;
//   final nameBills;
//   const PreviewPdfgen_Bills(
//       {Key? key, required this.doc, this.renTal_name, this.nameBills})
//       : super(key: key);

//   static const customSwatch = MaterialColor(
//     0xFF8DB95A,
//     <int, Color>{
//       50: Color(0xFFC2FD7F),
//       100: Color(0xFFB6EE77),
//       200: Color(0xFFB2E875),
//       300: Color(0xFFACDF71),
//       400: Color(0xFFA7DA6E),
//       500: Color(0xFFA1D16A),
//       600: Color(0xFF94BF62),
//       700: Color(0xFF90B961),
//       800: Color(0xFF85AB5A),
//       900: Color(0xFF7A9B54),
//     },
//   );

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       // title: 'Flutter Demo',
//       // theme: ThemeData(
//       //   primarySwatch: customSwatch.withOpacity(0.5),
//       // ),
//       // theme: ThemeData(
//       //   primarySwatch: Colors.green,
//       //   scrollbarTheme: ScrollbarThemeData().copyWith(
//       //     thumbColor: MaterialStateProperty.all(Colors.lightGreen[200]),
//       //   )),
//       debugShowCheckedModeBanner: false,
//       home: Scaffold(
//         appBar: AppBar(
//           backgroundColor: AppBarColors.hexColor,
//           leading: IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(
//               Icons.arrow_back_outlined,
//               color: Colors.white,
//             ),
//           ),
//           centerTitle: true,
//           title: Text(
//             "$nameBills",
//             style: const TextStyle(
//               color: Colors.white,
//               fontFamily: Font_.Fonts_T,
//             ),
//           ),
//         ),
//         body: PdfPreview(
//           build: (format) => doc.save(),
//           allowSharing: true,
//           allowPrinting: true, canDebug: false,
//           canChangeOrientation: false, canChangePageFormat: false,
//           maxPageWidth: MediaQuery.of(context).size.width * 0.6,
//           // scrollViewDecoration:,
//           initialPageFormat: PdfPageFormat.a4,
//           pdfFileName: "$nameBills.pdf",
//         ),
//       ),
//     );
//   }
// }
