import 'dart:async';
import 'dart:html' as html;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:http_parser/http_parser.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:chaoperty_floating_loader/chaoperty_floating_loader.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import '../../APIS-V2/Model-v2/payment-IntentsModel.dart';
import '../../APIS-V2/config-intents.dart';
import '../../APIS-V2/payment-intents.dart';
import '../../CRC_16_Prompay/generate_qrcode.dart';
import '../../ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import '../../Constant/Myconstant.dart';
import '../../Constant/global_http.dart';
import '../../INSERT_Log/Insert_log.dart';
import '../../Model/GetContractx_Fine_Model.dart';
import '../../Model/GetInvoice_Model.dart';
import '../../Model/GetInvoice_diapay_Model.dart';
import '../../Model/GetInvoice_history_Model.dart';
import '../../Model/GetPayMent_Model.dart';
import '../../Model/GetTranBill_model.dart';
import '../../Model/GetTrans_Kon_Model.dart';
import '../../Model/GetTrans_Model.dart';
import '../../Model/GetTrans_fine_Model.dart';
import '../../Model/GetVocher_Model.dart';
import '../../Model/Get_trasn_Matjum_KF_model.dart';
import '../../Model/Get_trasn_matjum_model.dart';
import '../../Model/Get_trasn_pakan_KF_model.dart';
import '../../Model/Get_trasn_pakan_model.dart';
import '../../Model/trans_re_bill_model.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
import 'package:bottom_sheet/bottom_sheet.dart';
import 'dart:ui' as ui;

import 'Model/IntentsContractx_Fine_Model.dart';
import 'Model/IntentsInv_history_Model.dart';
import 'Model/IntentsTrans_Model.dart';
import 'bankCodeMap.dart'; // ✅ use only alias

class PaymentIntentsPage extends StatefulWidget {
  final updateMessage2;
  final index;
  final Get_Value_NameShop_index;
  final Get_Value_cid;
  final Get_Value_custno;
  final namenew;
  final Screen_name;
  final Form_bussshop;
  final Form_address;
  final Form_tax;
  final can;
  final pakan;

  const PaymentIntentsPage({
    super.key,
    this.updateMessage2,
    this.index,
    this.Get_Value_NameShop_index,
    this.Get_Value_cid,
    this.Get_Value_custno,
    this.namenew,
    this.Screen_name,
    this.Form_bussshop,
    this.Form_address,
    this.Form_tax,
    this.can,
    this.pakan,
  });

  @override
  State<PaymentIntentsPage> createState() => _PaymentIntentsPageState();
}

class _PaymentIntentsPageState extends State<PaymentIntentsPage> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  // Constants for colors based on the image
  final Color _primaryPurple =
      const Color(0xFF6200EA); // Approximate deep purple
  final Color _activePurple = const Color(0xFF4A148C);
  final Color _highlightGreen = const Color(0xFF4CAF50);
  final Color _headerBrown =
      const Color(0xFF6D4C41); // Approximate brown/dark grey
  final Color _lightGrey = const Color(0xFFF5F5F5);
  List<TransBillModel> _TransBillModels = [];
  List<IntentsTransModel> _TransModels = [];
  List<InvoiceModel> _InvoiceModels = [];
  List<PaymentIntent> paymentIntents = [];
  List<TransMatjumKFModel> transMatjumKFModels = [];
  List<TransFineModel> transFineModels = [];
  List<TransMatjumModel> transMatjumModels = [];
  List<VocherModel> _VocherModels = [];
  List<IntentsContractxFineModel> contractxFineModels = [];
  List<PayMentModel> _PayMentModels = [];
  List<IntentsInvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<InvoiceDisPayModel> _InvoiceDisPayModels = [];
  List<TransKonModel> transKonModels = [];
  List<TransPakanModel> transPakanModels = [];
  List<TransPakanKFModel> transPakanKFModels = [];
  // ===== =====
  bool _tapBusy = false;
  bool _dialogOpen = false;
  bool _dialogRefresh = false;
  bool didSuccess = false;
  bool _isSelectingAll = false;
// ================== lifecycle ==================
  // Financial calculation variables
  double sum_pvat = 0;
  double sum_dis = 0;

  double sum_vat = 0;
  double sum_wht = 0;
  double sum_amt = 0;
  double sum_disamt = 0;
  double sum_tran_dis = 0;
  double sum_matjum = 0;
  double sum_Matjum_KF = 0;
  double sum_tran_fine = 0;
  double sum_tran_fine_vat = 0;
  double sum_tran_fine_amt = 0;
  double sum_dislist = 0, sum_disp = 0;
// Discount and helper variables
  int dis_matjum = 0;
  double dis_sum_Matjum = 0.0;
  double dis_sum_Pakan = 0.0;
  double dis_Pakan = 0, sum_Pakan = 0, sum_Pakan_KF = 0;
  int _matjum = 0;
  int renTal_lavel = 0;

  int _Pakan = 0;
  double fine_total = 0, fine_total2 = 0;
// Form controllers

  final TextEditingController Form_payment1 = TextEditingController();
  final TextEditingController Form_fine = TextEditingController();
  final Formposlok_ = TextEditingController();
  final Formterm_ = TextEditingController();
  final Formposlokdispri_ = TextEditingController();
  final Formpasslok_ = TextEditingController();
  final sum_dispx = TextEditingController();
  final sum_disamtx = TextEditingController();
  final TextEditingController descripTion = TextEditingController();
// Page selection
  int select_page =
      0; // 0 = รายการตั้งหนี้, 1 = รายการวางบิล, 3 = Payment Intents

  String? numinvoice, intentsCustno, intentPayedtype;
// ==================
  String? return_qr_img,
      qr_payload,
      invoiceAll,
      qr_softExpiresAt,
      qr_expiresAt,
      return_qr_refapi1,
      return_qr_refapi2,
      return_qr_refapi3,
      return_img;

  // Payment slip upload
  Uint8List? _slipImageBytes;
  String? _slipImageName, intentsAttacheSlipNo;
  Map<String, dynamic>? _uploadedSlipData; // Store attaches data
// ==================
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _resetToInitialState(targetPage: 0, billAll: false);
    });
  }

  @override
  void dispose() {
    Form_payment1.dispose();
    Form_fine.dispose();
    sum_disamtx.dispose();
    descripTion.dispose();
    super.dispose();
  }

  Future<void> _resetToInitialState(
      {required int targetPage, required bool billAll}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // 1. Reset Text Controllers
      Form_payment1.clear();
      Form_fine.clear();
      Formposlok_.clear();
      Formterm_.clear();
      Formposlokdispri_.clear();
      Formpasslok_.clear();
      sum_dispx.clear();
      sum_disamtx.text = '0.00';
      descripTion.clear();

      // 2. Clear Lists
      // Note: Some lists might be refilled immediately by the calls below,
      // but we clear them to ensure no stale data.
      _TransBillModels.clear();
      _TransModels.clear();
      _InvoiceModels.clear();
      paymentIntents.clear();
      transMatjumKFModels.clear();
      transFineModels.clear();
      transMatjumModels.clear();
      _VocherModels.clear();
      contractxFineModels.clear();
      _PayMentModels.clear();
      _InvoiceHistoryModels.clear();
      _InvoiceDisPayModels.clear();
      transKonModels.clear();
      transPakanModels.clear();
      transPakanKFModels.clear();

      // 3. Reset Scalars
      sum_pvat = 0;
      sum_dis = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
      sum_disamt = 0;
      sum_tran_dis = 0;
      sum_matjum = 0;
      sum_Matjum_KF = 0;
      sum_tran_fine = 0;
      sum_tran_fine_vat = 0;
      sum_tran_fine_amt = 0;
      sum_dislist = 0;
      sum_disp = 0;

      dis_matjum = 0;
      dis_sum_Matjum = 0.0;
      dis_sum_Pakan = 0.0;
      dis_Pakan = 0;
      sum_Pakan = 0;
      sum_Pakan_KF = 0;
      _matjum = 0;
      renTal_lavel =
          0; // Check if this should be reset or if it's fetched from prefs
      _Pakan = 0;
      fine_total = 0;
      fine_total2 = 0;

      // 4. Reset Other State Variables
      _tapBusy = false;
      _dialogOpen = false;
      _dialogRefresh = false;
      didSuccess = false;
      _isSelectingAll = false;

      numinvoice = null;
      intentsCustno = null;

      return_qr_img = null;
      qr_payload = null;
      invoiceAll = null;
      qr_softExpiresAt = null;
      qr_expiresAt = null;
      return_qr_refapi1 = null;
      return_qr_refapi2 = null;
      return_qr_refapi3 = null;
      return_img = null;

      _slipImageBytes = null;
      _slipImageName = null;
      intentsAttacheSlipNo = null;
      _uploadedSlipData = null;

      payment_ptSer1 = null;
      payment_ptSer2 = null;
      paymentSer1 = null;
      paymentName1 = null;
      paymentbcode1 = null;
      newValuePDFimg_QR = null;
      selectedValue = null;
      selectedValue2 = null;
      bname1 = null;
      bname2 = null;
      selectedPaymentKey = null;

      // 5. Re-fetch Initial Data (Global/Common Data)
      // These were called in initState, so we call them again to restore "fresh" state
      await redPaymentIntents();
      await deall_Trans_select();
      red_payMent();
      red_Trans_billAll(billAll: billAll);
      read_GC_fine();
      red_Trans_Kon();
      read_GC_pkan();
      if (targetPage == 1) {
        red_Invoice();
      }

      // Check if renTal_lavel needs re-fetching
      SharedPreferences.getInstance().then((prefs) {
        if (mounted) {
          setState(() {
            renTal_lavel = int.parse(prefs.getString('lavel').toString());
          });
        }
      });

      if (mounted) {
        setState(() {}); // Ensure UI updates
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  //////---------------------------------->
  String? payment_ptSer1,
      payment_ptSer2,
      paymentSer1,
      paymentName1,
      paymentbcode1;
  String? newValuePDFimg_QR,
      selectedValue,
      selectedValue2,
      bname1,
      bname2,
      selectedPaymentKey;

  Future<Null> red_payMent() async {
    if (_PayMentModels.length != 0) {
      setState(() {
        _PayMentModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');

    var ser_TitleType_Default_Typepay = preferences.getString('Ser_Typepay');
    String url = '${MyConstant().domain}/GC_payMent.php?isAdd=true&ren=$ren';
    // print(url);
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result.toString() != 'null') {
        for (var map in result) {
          PayMentModel _PayMentModel = PayMentModel.fromJson(map);
          var autox = _PayMentModel.auto;
          var serx = _PayMentModel.ser;
          var ptnamex = _PayMentModel.ptname;
          var fine = _PayMentModel.fine;
          var fine_amt = fine == '1'
              ? _PayMentModel.fine_c == '0.00'
                  ? double.parse(_PayMentModel.fine_a!)
                  : (((sum_amt - sum_disamt - dis_sum_Pakan - dis_sum_Matjum) *
                          double.parse(_PayMentModel.fine_c!)) /
                      100)
              : 0.00;

          setState(() {
            _PayMentModels.add(_PayMentModel);

            if (autox == '1' &&
                ser_TitleType_Default_Typepay.toString() == '0') {
              payment_ptSer1 = _PayMentModel.ptser.toString();
              paymentSer1 = serx.toString();
              paymentName1 = ptnamex.toString();
              selectedValue = _PayMentModel.bno.toString();
              newValuePDFimg_QR = _PayMentModel.img.toString();
              bname1 = _PayMentModel.bname.toString();
              fine_total = fine_amt;
              Form_payment1.text =
                  ((sum_amt - sum_disamt - dis_sum_Pakan - dis_sum_Matjum) +
                          fine_amt)
                      .toStringAsFixed(2)
                      .toString();
              paymentbcode1 = _PayMentModel.bcode.toString();
            }
          });
        }

        if (paymentName1 == null) {
          paymentSer1 = 0.toString();
          paymentName1 = 'เลือก'.toString();

          Form_payment1.text =
              (sum_amt - sum_disamt - dis_sum_Pakan - dis_sum_Matjum)
                  .toStringAsFixed(2)
                  .toString();
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
          IntentsContractxFineModel contractxFineModel =
              IntentsContractxFineModel.fromJson(map);

          setState(() {
            contractxFineModels.add(contractxFineModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_Kon() async {
    if (transKonModels.isNotEmpty) {
      setState(() {
        transKonModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = '1';

    String url =
        '${MyConstant().domain}/GC_tran_Kon_pakan.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          TransKonModel transKonModel = TransKonModel.fromJson(map);

          var sum_amtx = double.parse(transKonModel.total!);
          setState(() {
            transKonModels.add(transKonModel);
          });
        }
      }
    } catch (e) {}
  }

  Future<Null> read_GC_pkan() async {
    setState(() {
      _Pakan = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = 1;

    String url =
        '${MyConstant().domain}/GC_Pakan.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('>>>>>>>>>_Pakan>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

      if (result.toString() == 'true') {
        setState(() {
          _Pakan = 1;
          read_GC_pkan_total();
        });
      }
    } catch (e) {}
    setState(() {
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
    });
  }

  Future<Null> read_GC_pkan_total() async {
    setState(() {
      if (transPakanModels.isNotEmpty) {
        setState(() {
          transPakanModels.clear();
        });
      }
      sum_Pakan = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = 1;
    var pay_pakan = widget.pakan.toString();
    String url =
        '${MyConstant().domain}/GC_Pakan_total.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      print(
          '>>>>>>>>>>>>>>>>>>>>>read_GC_pkan_total>>>>>>>>>>>--------------  $pay_pakan');

      if (result.toString() != 'true') {
        for (var map in result) {
          TransPakanModel transPakanModel = TransPakanModel.fromJson(map);
          var sum_P = pay_pakan == '0'
              ? double.parse(transPakanModel.pvat!)
              : double.parse(transPakanModel.total!);

          setState(() {
            sum_Pakan = sum_Pakan + sum_P;
            transPakanModels.add(transPakanModel);
          });
        }
      }
    } catch (e) {}
    setState(() {
      read_GC_pkan_total_KF();
    });
  }

  Future<Null> read_GC_pkan_total_KF() async {
    setState(() {
      if (transPakanKFModels.isNotEmpty) {
        setState(() {
          transPakanKFModels.clear();
        });
      }
      sum_Pakan_KF = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = 1;

    String url =
        '${MyConstant().domain}/GC_Pakan_total_KF.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

      if (result.toString() != 'true') {
        for (var map in result) {
          TransPakanKFModel transPakanKFModel = TransPakanKFModel.fromJson(map);
          var sum_P = double.parse(transPakanKFModel.total!);
          setState(() {
            sum_Pakan_KF = sum_Pakan_KF + sum_P;
            transPakanKFModels.add(transPakanKFModel);
          });
        }
        setState(() {
          sum_Pakan = sum_Pakan - sum_Pakan_KF;
        });
      }
    } catch (e) {}
  }

  //////---------------------------------->
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

  //////---------------------------------->
  Future<void> red_Trans_billAll({required bool billAll}) async {
    if (!mounted) return;

    setState(() {
      _TransBillModels.clear();
    });

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var ren = preferences.getString('renTalSer');
      var ciddoc = widget.Get_Value_cid;
      var qutser = widget.Get_Value_NameShop_index;
      String nameApsBill =
          (billAll != true) ? 'GC_tran_bill' : 'GC_tran_bill_All';

      String url =
          '${MyConstant().domain}/$nameApsBill.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result != null && result.toString() != 'null') {
        for (var map in result) {
          TransBillModel _TransBillModel = TransBillModel.fromJson(map);
          if (mounted) {
            setState(() {
              _TransBillModels.add(_TransBillModel);
            });
          }
        }
      }
    } catch (e) {
      print('Error in red_Trans_billAll: $e');
      // Optionally show error to user if needed
    }
  }

  //////---------------------------------->
  Future<Null> red_Invoice() async {
    setState(() {
      _InvoiceModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    String url =
        '${MyConstant().domain}/GC_bill_invoice.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';
    print(url);
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceModel _InvoiceModel = InvoiceModel.fromJson(map);
          setState(() {
            _InvoiceModels.add(_InvoiceModel);
          });
        }
      }
    } catch (e) {}
  }
  //////---------------------------------->

  Future<void> redPaymentIntents() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var cusno = widget.Get_Value_custno;
    int _toU16(String? v) =>
        (int.tryParse((v ?? '0').trim()) ?? 0) +
        65535; // ✅ 16-bit unsigned (0..65535)

    String? custno16Bit = _toU16('$cusno').toString();
    String? ren16Bit = _toU16('$ren').toString();
    if (mounted) {
      setState(() {
        paymentIntents.clear();
      });
    }
// {"customer_no":"65538","property_no":"65681"
    print('🔄 เรียกใช้งาน redPaymentIntents() ${cusno}');
    final response =
        await postPaymentIntentsState(cusno: custno16Bit, propertyno: ren16Bit);
    final respJson = jsonDecode(response!.body);
    print(respJson);
    try {
      if (response!.body.isEmpty) {
        print('❌ response.body ว่าง');
        return;
      }

      final root = json.decode(response.body);

      if (root is! Map<String, dynamic>) {
        print('❌ รูปแบบ JSON ไม่ใช่ Map<String, dynamic>');
        return;
      }

      final intentsListRaw = root['data'];

      final intents = (intentsListRaw is List
              ? intentsListRaw.whereType<Map<String, dynamic>>()
              : const <Map<String, dynamic>>[])
          .map((m) => PaymentIntent.fromJson(m))
          .toList();

      if (mounted) {
        setState(() {
          paymentIntents = intents;
        });
      }

      print('✅ intents loaded: ${intents.length}');
    } catch (e, stack) {
      print('❌ Exception parsing payment intents: $e');
      print('🧭 StackTrace:\n$stack');
    }
  }

  //////---------------------------------->
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

      // var result = json.decode(response.body);
    } catch (e) {
      // print('rrrrrrrrrrrrrr $e');
    }
  }

  //////---------------------------------->
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

      // ---- 200 OK: ต้องได้ค่า success จึงจะถือว่าสำเร็จ ----
      if (resp.statusCode == 200) {
        final body = rawBody.toLowerCase();

        // รองรับหลายรูปแบบที่พบบ่อยจาก PHP/Server
        if (body == 'true' ||
            body == '1' ||
            body == 'ok' ||
            body == 'success') {
          return true;
        }

        // เผื่อบางเซิร์ฟเวอร์ส่ง JSON
        dynamic obj;
        try {
          obj = json.decode(rawBody);
        } catch (_) {}
        final objStr = obj?.toString().toLowerCase();
        if (obj == true || objStr == 'true' || objStr == '1') return true;

        // 200 แต่ไม่ใช่ success => ไม่สำเร็จ
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

  Future<void> in_Trans_fine(index) async {
    if (!mounted) return;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var ren = preferences.getString('renTalSer');
      var user = preferences.getString('ser');
      var ciddoc = widget.Get_Value_cid;
      var qutser = widget.Get_Value_NameShop_index;

      var tser = _TransBillModels[index].ser;
      var tdocno = _TransBillModels[index].docno;

      String url =
          '${MyConstant().domain}/In_tran_select_fine.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';

      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);
      // Result handling can be added here if needed
    } catch (e) {
      print('Error in in_Trans_fine: $e');
    }
  }

  Future<void> red_Trans_select2() async {
    if (!mounted) return;

    setState(() {
      _TransModels.clear();
      sum_pvat = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
      sum_tran_dis = 0;
      sum_matjum = 0;
      dis_matjum = 0;
      dis_sum_Matjum = 0.00;
    });

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var ren = preferences.getString('renTalSer');
      var user = preferences.getString('ser');
      var ciddoc = widget.Get_Value_cid;

      String url =
          '${MyConstant().domain}/GC_tran_select.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';
      print(url);

      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);
      print(result);

      if (result != null && result.toString() != 'null') {
        if (!mounted) return;

        setState(() {
          _TransModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_tran_dis = 0;
        });

        for (var map in result) {
          IntentsTransModel _TransModel = IntentsTransModel.fromJson(map);

          var sum_pvatx = double.parse(_TransModel.pvat ?? '0');
          var sum_vatxx = double.parse(_TransModel.vat ?? '0');
          var sum_whtx = double.parse(_TransModel.wht ?? '0');
          var sum_amtxx = double.parse(_TransModel.total ?? '0');
          var sum_disx = double.parse(_TransModel.dis ?? '0');

          var sum_amtx = double.parse(_TransModel.total_dis ?? '0');
          var sum_vatx = double.parse(_TransModel.dis ?? '0') == 0
              ? double.parse(_TransModel.vat ?? '0')
              : double.parse(_TransModel.vat_dislit ?? '0');

          if (mounted) {
            setState(() {
              sum_pvat = sum_pvat + sum_pvatx;
              sum_vat = sum_vat + sum_vatx;
              sum_wht = sum_wht + sum_whtx;
              sum_amt = sum_amt + sum_amtx;
              sum_tran_dis = sum_tran_dis + sum_disx;
              _TransModels.add(_TransModel);
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            dis_matjum = 0;
            dis_sum_Matjum = 0.00;
          });
        }
      }
    } catch (e) {
      print('Error in red_Trans_select2: $e');
    }

    if (mounted) {
      setState(() {
        red_Trans_select2_fin();
        read_GC_matjum();

        Form_payment1.text = (sum_amt -
                sum_disamt -
                dis_sum_Pakan -
                sum_tran_dis -
                dis_sum_Matjum)
            .toStringAsFixed(2);
      });
    }
  }

  Future<void> red_Trans_select2_fin() async {
    if (!mounted) return;

    if (transFineModels.isNotEmpty) {
      setState(() {
        transFineModels.clear();
        sum_tran_fine = 0;
        sum_tran_fine_amt = 0;
      });
    }

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var ren = preferences.getString('renTalSer');
      var user = preferences.getString('ser');
      var ciddoc = widget.Get_Value_cid;

      String url =
          '${MyConstant().domain}/GC_tran_select_fin.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc';

      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result != null && result.toString() != 'null') {
        transFineModels.clear();
        sum_tran_fine = 0;
        sum_tran_fine_vat = 0;
        sum_tran_fine_amt = 0;

        for (var map in result) {
          TransFineModel transFineModel = TransFineModel.fromJson(map);

          var sum_totalx = double.parse(transFineModel.total ?? '0');
          var sump_pvatx = double.parse(transFineModel.pvat ?? '0');
          var sump_vatx = double.parse(transFineModel.vat ?? '0');

          if (mounted) {
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
      }
    } catch (e) {
      print('Error in red_Trans_select2_fin: $e');
    }

    if (mounted) {
      setState(() {
        Form_fine.text = sum_tran_fine.toString();
        Form_payment1.text = (sum_amt -
                sum_disamt -
                dis_sum_Pakan -
                sum_tran_dis -
                dis_sum_Matjum)
            .toStringAsFixed(2);
      });
    }
  }

  Future<Null> read_GC_matjum() async {
    setState(() {
      _matjum = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = 1;

    String url =
        '${MyConstant().domain}/GC_Matjum.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');

      if (result.toString() == 'true') {
        setState(() {
          _matjum = 1;
          read_GC_matjum_total();
        });
      }
    } catch (e) {}
    setState(() {
      renTal_lavel = int.parse(preferences.getString('lavel').toString());
    });
  }

  Future<Null> read_GC_matjum_total() async {
    setState(() {
      if (transMatjumModels.isNotEmpty) {
        setState(() {
          transMatjumModels.clear();
          sum_matjum = 0;
        });
      }
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = 1;

    String url =
        '${MyConstant().domain}/GC_Matjum_total.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');
      sum_matjum = 0;
      if (result.toString() != 'true') {
        for (var map in result) {
          TransMatjumModel transMatjumModel = TransMatjumModel.fromJson(map);
          var sum_P = double.parse(transMatjumModel.total!);
          setState(() {
            sum_matjum = sum_matjum + sum_P;
            transMatjumModels.add(transMatjumModel);
          });
        }
      }
    } catch (e) {}

    setState(() {
      read_GC_Matjum_total_MM();
    });
  }

  Future<Null> read_GC_Matjum_total_MM() async {
    setState(() {
      if (transMatjumKFModels.isNotEmpty) {
        setState(() {
          transMatjumKFModels.clear();
        });
      }
      sum_Matjum_KF = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = widget.Get_Value_cid;
    var qutser = 1;

    String url =
        '${MyConstant().domain}/GC_Matjum_total_KF.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser';

    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--------------  $result');
      sum_Matjum_KF = 0;
      if (result.toString() != 'true') {
        for (var map in result) {
          TransMatjumKFModel transMatjumKFModel =
              TransMatjumKFModel.fromJson(map);
          var sum_P = double.parse(transMatjumKFModel.total!);
          setState(() {
            sum_Matjum_KF = sum_Matjum_KF + sum_P;
            transMatjumKFModels.add(transMatjumKFModel);
          });
        }
      }
      setState(() {
        sum_matjum = sum_matjum - sum_Matjum_KF;
      });
    } catch (e) {}
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
          // red_Trans_select2();
          // red_Trans_bill();
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> de_Trans_select(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var tser = _TransModels[index].ser;
    var tdocno = _TransModels[index].docno;

    // print('tser >>.> $tser');

    String url =
        '${MyConstant().domain}/De_tran_select.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select2();
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

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
          red_Trans_select2();
        });
        // print('rrrrrrrrrrrrrr');
      }
    } catch (e) {}
  }

  Future<Null> red_Trans_select(index) async {
    if (_InvoiceHistoryModels.length != 0) {
      setState(() {
        _InvoiceHistoryModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        sum_disamt = 0;
        sum_disp = 0;
        sum_dislist = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    var docnoin = _InvoiceModels[index].docno;
    // String url =
    //     '${MyConstant().domain}/GC_bill_invoice_History.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    String url =
        '${MyConstant().domain}/GC_bill_invoiceHistory_v2.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    // print(url);
    try {
      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);
      print(result);

      if (result.toString() != 'null') {
        for (var map in result) {
          IntentsInvoiceHistoryModel _InvoiceHistoryModel =
              IntentsInvoiceHistoryModel.fromJson(map);

          setState(() {
            numinvoice = _InvoiceHistoryModel.docno;
            _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      }
      red_Trans_select_2(index);
    } catch (e) {}
  }

  Future<Null> red_Trans_select_2(index) async {
    setState(() {
      // _InvoiceHistoryModels.clear();
      sum_pvat = 0;
      sum_vat = 0;
      sum_wht = 0;
      sum_amt = 0;
      sum_disamt = 0;
      sum_disp = 0;
      sum_dislist = 0;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    var docnoin = _InvoiceModels[index].docno;

    String url =
        '${MyConstant().domain}/GC_bill_invoice_history.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.dis!) != 0
              ? double.parse(_InvoiceHistoryModel.pvat_t!) -
                  double.parse(_InvoiceHistoryModel.dis!)
              : double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          var sum_dislistx = double.parse(_InvoiceHistoryModel.dis!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            // sum_amt = sum_amt + sum_amtx;
            sum_amt = double.parse((sum_amt + sum_amtx).toStringAsFixed(2));
            sum_disamt = sum_disamtx;
            sum_dislist = sum_dislist + sum_dislistx;
            sum_disp = sum_dispx;
            numinvoice = _InvoiceHistoryModel.docno;
            // _InvoiceHistoryModels.add(_InvoiceHistoryModel);
          });
        }
      } else if (result.toString() == 'false') {
        for (var map in result) {
          InvoiceHistoryModel _InvoiceHistoryModel =
              InvoiceHistoryModel.fromJson(map);

          var sum_pvatx = double.parse(_InvoiceHistoryModel.dis!) != 0
              ? double.parse(_InvoiceHistoryModel.pvat_t!) -
                  double.parse(_InvoiceHistoryModel.dis!)
              : double.parse(_InvoiceHistoryModel.pvat_t!);
          var sum_vatx = double.parse(_InvoiceHistoryModel.vat_t!);
          var sum_whtx = double.parse(_InvoiceHistoryModel.wht!);
          var sum_amtx = double.parse(_InvoiceHistoryModel.total_t!);
          var sum_disamtx = double.parse(_InvoiceHistoryModel.disendbill!);
          var sum_dispx = double.parse(_InvoiceHistoryModel.disendbillper!);
          var sum_dislistx = double.parse(_InvoiceHistoryModel.dis!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            // sum_amt = sum_amt + sum_amtx;
            sum_amt = double.parse((sum_amt + sum_amtx).toStringAsFixed(2));
            sum_dislist = sum_dislist + sum_dislistx;
            sum_disamt = sum_disamtx;
            sum_disp = sum_dispx;
            numinvoice = _InvoiceHistoryModel.docno;
            // s.add(_InvoiceHistoryModel);
          });
        }
      } else {
        setState(() {
          _InvoiceHistoryModels.clear();
          sum_pvat = 0;
          sum_vat = 0;
          sum_wht = 0;
          sum_amt = 0;
          sum_disamt = 0;
          sum_disp = 0;
          sum_dislist = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                  style: TextStyle(
                      color: Colors.white, fontFamily: Font_.Fonts_T))),
        );
      }

      setState(() {
        Form_payment1.text = (sum_amt -
                sum_disamt -
                dis_sum_Pakan -
                sum_tran_dis -
                dis_sum_Matjum)
            .toStringAsFixed(2)
            .toString();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('มีผู้ใช้อื่นกำลังทำรายการอยู่....',
                style:
                    TextStyle(color: Colors.white, fontFamily: Font_.Fonts_T))),
      );
    }
  }

  Future<Null> in_Trans_dis_inv(index) async {
    if (_InvoiceDisPayModels.length != 0) {
      setState(() {
        _InvoiceDisPayModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;

    var tser = _InvoiceModels[index].ser;
    var tdocno = _InvoiceModels[index].docno;

    // print('tdocno>>>>  $tdocno');

    String url =
        '${MyConstant().domain}/GC_bill_invoice_dispay.php?isAdd=true&ren=$ren&ciddoc=$tdocno&qutser=$qutser';
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print(result);
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceDisPayModel _InvoiceDisPayModel =
              InvoiceDisPayModel.fromJson(map);
          setState(() {
            _InvoiceDisPayModels.add(_InvoiceDisPayModel);
          });
        }
      }
    } catch (e) {}
    // print('_InvoiceDisPayModels >>>> ${_InvoiceDisPayModels.length}');
  }

  Future<Null> in_Trans_fine_re(index) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = widget.Get_Value_cid;
    var qutser = widget.Get_Value_NameShop_index;
    var tser = _InvoiceModels[index].ser;
    var tdocno = _InvoiceModels[index].docno;
    String url =
        '${MyConstant().domain}/In_tran_select_fine_inv.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    print('In_tran_select_fine_inv>>> $url');
    try {
      // print('response>>> 111');
      var response = await httpClient.get(Uri.parse(url));
      // print('response>>> $response');
      var result = json.decode(response.body);
      // print('result>>> $result');
      var fine_inv = result.toString().indexOf(',');
      var fine_inv12 = result.toString().indexOf('-');

      var fine_Name = result.toString().substring(0, fine_inv);
      var fine_pri = result.toString().substring(fine_inv + 1);
      // var fine_pri2 = result.toString().substring(fine_inv12 + 1);
      // print('ชำระเกินกำหนด ${fine_Name.toString()} $fine_pri   ');
      var sum_totalx = double.parse(fine_pri);
      // var sum_totalx_amt = double.parse(fine_pri2);
      sum_tran_fine = 0;
      sum_tran_fine_amt = 0;
      setState(() {
        sum_pvat = sum_pvat + sum_totalx;
        sum_amt = sum_amt + sum_totalx;
        sum_tran_fine = sum_tran_fine + sum_totalx;
        // sum_tran_fine_amt = sum_tran_fine_amt + sum_totalx_amt;
      });
    } catch (e) {}
    setState(() {
      Form_fine.text = sum_tran_fine.toString();
      Form_payment1.text =
          (sum_amt - sum_disamt - dis_sum_Pakan - sum_tran_dis - dis_sum_Matjum)
              .toStringAsFixed(2)
              .toString();
    });
  }

  Future<Map<String, dynamic>> GC_Inv_fine({required String docno}) async {
    final preferences = await SharedPreferences.getInstance();
    final ren = preferences.getString('renTalSer') ?? '';

    final uri =
        Uri.parse('${MyConstant().domain}/GC_selectFine_inv.php').replace(
      queryParameters: {
        'isAdd': 'true',
        'ren': ren,
        'tdocno': docno,
      },
    );
    print(uri);
    try {
      final response = await httpClient.get(uri);
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic>) {
        return {
          'ok': true,
          'expname': decoded['expname'],
          'expser': decoded['expser'],
          'no': decoded['no'],
          'pvat': (decoded['pvat'] as num?)?.toDouble() ?? 0.0,
          'vser': (decoded['vser'] as num?)?.toDouble() ?? 0.0,
          'vtype': decoded['vtype'],
          'nvat': (decoded['nvat'] as num?)?.toInt() ?? 0,
          'vat': (decoded['vat'] as num?)?.toDouble() ?? 0.0,
          'total': (decoded['total'] as num?)?.toDouble() ?? 0.0,
          'wht': (decoded['wht'] as num?)?.toDouble() ?? 0.0,
          'docno': decoded['docno'] ?? docno,
        };
      }

      return {'ok': false, 'error': 'Unexpected response type'};
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // อ่านสถานะ sidebar
        final isOpen = context.watch<SidebarController>().isOpen;

        // ความกว้างของ viewport
        final viewportW = Responsive.isDesktop(context)
            ? (isOpen ? constraints.maxWidth - 295 : constraints.maxWidth - 260)
            : 1200.0;

        // 🔑 แก้ตรงนี้: ถ้า maxHeight เป็น infinity ให้ใช้ความสูงของหน้าจอแทน
        final double availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height;

        return SizedBox(
          height: availableHeight, // บังคับให้ widget เรามีความสูงแน่นอน
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              dragStartBehavior: DragStartBehavior.start,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: viewportW),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: SizedBox(
                    width: viewportW * 1.2,
                    height:
                        availableHeight + 20, // ตอนนี้เป็นค่าที่ finite แล้ว
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 35,
                          child: _buildLeftPanel(),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 65,
                          child: _buildRightPanel(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeftPanel() {
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildLeftTopTabs(),
            _buildLeftSubTabs(),
            _buildLeftListHeader(),
            _buildLeftListItems(),
            _buildLeftBottomActions(),
          ],
        ));
  }

  Widget _buildRightPanel() {
    return Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildRightHeader(),
            Expanded(child: _buildRightTable()),
            _buildRightFooter(),
          ],
        ));
  }

  // --- Left Panel Widgets Placeholders ---

  bool _isAlreadyInPaymentIntent(int index) {
    if (index < 0 || index >= _TransBillModels.length) return false;
    final bill = _TransBillModels[index];

    return paymentIntents.any((pi) => pi.invoices
        .any((inv) => inv.metadata.any((m) => m.docno == bill.docno)));
  }

  Widget _buildLeftTopTabs() {
    return SizedBox(
      width: 500,
      height: 56,
      child: Row(
        children: [
          // Tab 0: รายการตั้งหนี้
          Expanded(
            child: InkWell(
              onTap: () async {
                await _resetToInitialState(targetPage: 0, billAll: false);

                setState(() {
                  select_page = 0;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      select_page == 0 ? Colors.green.withOpacity(0.1) : null,
                  border: Border(
                    bottom: BorderSide(
                      color: select_page == 0 ? Colors.green : Colors.black12,
                      width: select_page == 0 ? 3 : 1,
                    ),
                  ),
                ),
                child: Text(
                  'รายการตั้งหนี้',
                  style: TextStyle(
                    fontWeight:
                        select_page == 0 ? FontWeight.bold : FontWeight.normal,
                    color: select_page == 0 ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // Tab 3: Payment Intents
          Expanded(
            child: InkWell(
              onTap: () async {
                await _resetToInitialState(targetPage: 3, billAll: false);

                setState(() {
                  select_page = 3;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      select_page == 3 ? Colors.green.withOpacity(0.1) : null,
                  border: Border(
                    bottom: BorderSide(
                      color: select_page == 3 ? Colors.green : Colors.black12,
                      width: select_page == 3 ? 3 : 1,
                    ),
                  ),
                ),
                child: Text(
                  'รายการรอชำระ',
                  style: TextStyle(
                    fontWeight:
                        select_page == 3 ? FontWeight.bold : FontWeight.normal,
                    color: select_page == 3 ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSubTabs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // SubTab 0: รายการตั้งหนี้
          InkWell(
            onTap: () async {
              await _resetToInitialState(targetPage: 0, billAll: false);

              setState(() {
                select_page = 0;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: select_page == 0 ? _primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    select_page == 0 ? null : Border.all(color: Colors.black12),
              ),
              child: Text(
                'รายการตั้งหนี้',
                style: TextStyle(
                  color: select_page == 0 ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // SubTab 1: รายการวางบิล
          InkWell(
            onTap: () async {
              await _resetToInitialState(targetPage: 1, billAll: false);

              setState(() {
                select_page = 1;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: select_page == 1 ? _primaryPurple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border:
                    select_page == 1 ? null : Border.all(color: Colors.black12),
              ),
              child: Text(
                'รายการวางบิล',
                style: TextStyle(
                  color: select_page == 1 ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftListHeader() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.brown.shade200, Colors.brown.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(
          bottom: BorderSide(color: Colors.black12, width: .8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const Center(
                child: Text(
                  'ประเภท',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text1_,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontWeight_.Fonts_T,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          (Responsive.isDesktop(context))
              ? Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Center(
                      child: Text(
                        'กำหนดชำระ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text1_,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Center(
                      child: Text(
                        'เลขตั้งหนี้',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text1_,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                if (select_page == 0) ...[
                  Tooltip(
                    message: 'เลือกทั้งหมด',
                    child: InkWell(
                      onTap: () async {
                        if (_TransBillModels.isEmpty) return;
                        if (_isSelectingAll) return; // กันกดซ้ำ
                        _isSelectingAll = true;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        );

                        try {
                          // จำกัดสูงสุด 50 รายการ
                          final int maxSelect = _TransBillModels.length > 50
                              ? 50
                              : _TransBillModels.length;

                          if (_TransBillModels.length > 50) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'เลือกได้สูงสุด 50 รายการ ระบบจะเลือกให้ 50 รายการแรก'),
                              ),
                            );
                          }

                          // เลือกทีละรายการแบบเรียงลำดับ
                          for (var i = 0; i < maxSelect; i++) {
                            final row = _TransBillModels[i];
                            final isSelected = _TransModels.any((A) =>
                                A.docno == row.docno && A.date == row.date);
                            final alreadyIntent = _isAlreadyInPaymentIntent(i);

                            if (alreadyIntent || isSelected) continue;

                            final ok = await in_Trans_select(i);
                            if (!ok) {
                              // จะ break เฉย ๆ ก็ได้ ถ้าไม่อยากแจ้ง
                              break;
                            }
                          }

                          // โหลดรายละเอียดครั้งเดียว
                          await red_Trans_select2();
                        } finally {
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                          _isSelectingAll = false;
                        }
                      },
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: const Center(
                          child: Icon(
                            Icons.chevron_right,
                            size: 35,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftListItems() {
    String? _getPaySerFromPaymentIntent(int index) {
      final bill = _TransBillModels[index];

      for (final pi in paymentIntents) {
        for (final inv in pi.invoices) {
          for (final m in inv.metadata) {
            if (m.docno == bill.docno) {
              return pi.bankmerchantid?.toString();
            }
          }
        }
      }
      return null; // ไม่พบ
    }

    bool _isAlreadyInvInPaymentIntent(int index) {
      final bill = _InvoiceModels[index];

      return paymentIntents.any(
          (pi) => pi.invoices.any((inv) => inv.billReference == bill.docno));
    }

    return Container(
      height: 420,
      decoration: const BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: select_page == 0
          ? ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _TransBillModels.length,
              itemBuilder: (BuildContext context, int index) {
                final row = _TransBillModels[index];

                final isSelected = _TransModels.any(
                    (A) => A.docno == row.docno && A.date == row.date);
                final alreadyIntent = _isAlreadyInPaymentIntent(index);
                final getPaySerIntent = _getPaySerFromPaymentIntent(index);
                // หา bank name จาก _PayMentModels ด้วย bankmerchantid
                String bank = '';
                for (final e in _PayMentModels) {
                  // print("p.ser : ${e.ser}");
                  if ('${e.ser}' == '${getPaySerIntent}') {
                    // print("e.ser : ${e.ser}");
                    // print("e.bank : ${e.bank}");
                    bank = '${e.bank}';
                    break;
                  }
                }

                final bankInfo = bankCodeMap[bank];
                final logoFile = bankInfo?['logo'] ?? 'default.png';
                // print(logoFile)
                // final bankCode = bankInfo?['code'] ?? '';
                // final bankEn = bankInfo?['en'] ?? bank;

                final beforDueText = row.dtype == 'KU'
                    ? (row.befor_duedate == null || row.befor_duedate == '')
                        ? ''
                        : '${DateFormat('dd-MM').format(DateTime.parse('${row.befor_duedate} 00:00:00'))}-${DateTime.parse('${row.befor_duedate} 00:00:00').year + 0}'
                    : (row.befor_date == null || row.befor_date == '')
                        ? ''
                        : '${DateFormat('dd-MM').format(DateTime.parse('${row.befor_date} 00:00:00'))}-${DateTime.parse('${row.befor_date} 00:00:00').year + 0}';
                final beforTotal =
                    '${nFormat.format(double.tryParse(row.befor_total ?? "0"))} ';
                final refnox = '${row.refnox}';
                final namex = '${row.namex}';

                return Material(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  child: Container(
                    decoration: BoxDecoration(
                      color: alreadyIntent
                          ? Colors.red.shade100
                          : (isSelected
                              ? tappedIndex_Color.tappedIndex_Colors
                              : null), // ✅ เขียวแบบเดิม
                      border: const Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      leading: (logoFile != null &&
                              logoFile.toString() != 'default.png')
                          ? CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey.shade100,
                              child: (logoFile != null &&
                                      logoFile != 'default.png')
                                  ? ClipOval(
                                      child: Image.asset(
                                        'images/LogoBank/$logoFile',
                                        width: 26,
                                        height: 26,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const SizedBox.shrink(),
                                      ),
                                    )
                                  : null,
                            )
                          : null,
                      // trailing: (alreadyIntent) ? Icon(Icons.more_vert) : null,
                      onTap: (alreadyIntent || isSelected)
                          ? null
                          : () async {
                              if (_tapBusy) return;
                              if (mounted) setState(() => _tapBusy = true);

                              try {
                                final ok = await in_Trans_select(index);
                                if (!ok) return;

                                await in_Trans_fine(index);
                                await red_Trans_select2();

                                if (mounted) setState(() {});
                              } finally {
                                await Future.delayed(
                                    const Duration(milliseconds: 300));
                                if (mounted) setState(() => _tapBusy = false);
                              }
                            },
                      subtitle: (refnox == 'null' ||
                              refnox == '' ||
                              refnox.isEmpty)
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
                              richMessage: TextSpan(
                                text: '${row.expname}',
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
                                maxFontSize: 25,
                                maxLines: 1,
                                '${row.expname}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    //fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                          (Responsive.isDesktop(context))
                              ? Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    richMessage: TextSpan(
                                      text: (row.date == null || row.date == '')
                                          ? ''
                                          : '${DateFormat('dd-MM').format(DateTime.parse('${row.date} 00:00:00'))}-${DateTime.parse('${row.date} 00:00:00').year + 0}',
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
                                      maxFontSize: 25,
                                      maxLines: 1,
                                      (row.date == null || row.date == '')
                                          ? ''
                                          : '${DateFormat('dd-MM').format(DateTime.parse('${row.date} 00:00:00'))}-${DateTime.parse('${row.date} 00:00:00').year + 0}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          //fontWeight: FontWeight.bold,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          Expanded(
                            flex: 2,
                            child: Tooltip(
                              richMessage: TextSpan(
                                text: row.invoice == null
                                    ? '${row.docno}'
                                    : '${row.invoice}',
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
                                maxFontSize: 25,
                                maxLines: 1,
                                row.invoice == null
                                    ? '${row.docno}'
                                    : '${row.invoice}',
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    //fontWeight: FontWeight.bold,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : select_page == 1
              ? ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _InvoiceModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    final rowInv = _InvoiceModels[index];
                    final isSelected = numinvoice == rowInv.docno;
                    final alreadyIntent = _isAlreadyInvInPaymentIntent(index);
                    // หา bank name จาก _PayMentModels ด้วย bankmerchantid
                    String bank = '';
                    for (final e in _PayMentModels) {
                      // print("p.ser : ${e.ser}");
                      if ('${e.ser}' == '${rowInv.payser}') {
                        // print("e.ser : ${e.ser}");
                        // print("e.bank : ${e.bank}");
                        bank = '${e.bank}';
                        break;
                      }
                    }

                    final bankInfo = bankCodeMap[bank];
                    final logoFile = bankInfo?['logo'] ?? 'default.png';
                    final bankCode = bankInfo?['code'] ?? '';
                    final bankEn = bankInfo?['en'] ?? bank;

                    return Material(
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      child: Container(
                        decoration: BoxDecoration(
                          color: alreadyIntent
                              ? Colors.red.shade100
                              : (isSelected
                                  ? tappedIndex_Color.tappedIndex_Colors
                                  : null), // ✅ เขียวแบบเดิม
                          border: const Border(
                            bottom: BorderSide(color: Colors.grey, width: 0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade100,
                            child: logoFile != null
                                ? ClipOval(
                                    child: Image.asset(
                                      'images/LogoBank/$logoFile',
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.account_balance,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.account_balance,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                          ),
                          onTap: (alreadyIntent || isSelected)
                              ? null
                              : () async {
                                  if (_tapBusy) return;
                                  if (mounted) setState(() => _tapBusy = true);

                                  try {
                                    if (mounted) {
                                      setState(() {
                                        sum_disamtx.text =
                                            rowInv.disendbill ?? '0';
                                        sum_disamtx.text =
                                            rowInv.disendbill ?? '0';
                                        sum_dis = double.tryParse(
                                                rowInv.disendbill ?? '0') ??
                                            0;
                                        sum_disamt = double.tryParse(
                                                rowInv.disendbill ?? '0') ??
                                            0;
                                        sum_dispx.clear();

                                        //======>
                                        numinvoice = rowInv.docno.toString();
                                        paymentSer1 = rowInv.payser.toString();
                                        paymentName1 = rowInv.ptname.toString();
                                        // Find matching payment model to set correct key for dropdown
                                        try {
                                          final match =
                                              _PayMentModels.firstWhere(
                                            (e) =>
                                                '${e.ser}' ==
                                                '${rowInv.payser}',
                                            orElse: () =>
                                                PayMentModel(), // Fallback
                                          );
                                          if (match.ser != null) {
                                            selectedPaymentKey =
                                                '${match.ser}:${match.ptname}';
                                          } else {
                                            // Case not found, safe fallback or null
                                            selectedPaymentKey = null;
                                          }
                                        } catch (_) {
                                          selectedPaymentKey = null;
                                        }
                                      });
                                    }

                                    // 1) รอให้โหลด/select เสร็จก่อน
                                    await red_Trans_select(index);

                                    // 2) ทำต่อหลัง select เสร็จ (เหมือนใน then)
                                    await in_Trans_dis_inv(index);

                                    // 3) เงื่อนไขเดิม
                                    if (widget.can.toString() == 'null') {
                                      if (contractxFineModels.isNotEmpty) {
                                        in_Trans_fine_re(index);
                                        // red_Trans_select2_fin(); // ถ้าจะใช้ค่อยเปิด
                                      }
                                    }
                                  } catch (e) {
                                    // debugPrint('onTap error: $e');
                                  } finally {
                                    // คูลดาวน์เล็กน้อยกันกดรัว
                                    await Future.delayed(
                                        const Duration(milliseconds: 300));
                                    if (mounted)
                                      setState(() => _tapBusy = false);
                                  }
                                },
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          title: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  rowInv.daterec ?? '-',
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  rowInv.docno ?? '-',
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: AutoSizeText(
                                  rowInv.docno ?? '-',
                                  minFontSize: 10,
                                  maxFontSize: 25,
                                  maxLines: 1,
                                  textAlign: TextAlign.end,
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : select_page == 3
                  ? ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: paymentIntents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final intent = paymentIntents[index];

                        // หา bank name จาก _PayMentModels ด้วย bankmerchantid
                        String bank = '';
                        for (final e in _PayMentModels) {
                          // print("p.ser : ${e.ser}");
                          if ('${e.ser}' == '${intent.bankmerchantid}') {
                            // print("e.ser : ${e.ser}");
                            // print("e.bank : ${e.bank}");
                            bank = '${e.bank}';
                            break;
                          }
                        }

                        final bankInfo = bankCodeMap[bank];
                        final logoFile = bankInfo?['logo'] ?? 'default.png';
                        final bankCode = bankInfo?['code'] ?? '';
                        final bankEn = bankInfo?['en'] ?? bank;
                        // intentsCustno = intent.customerNo;
                        // setState(() {
                        //   intentsCustno = intent.customerNo;
                        // });

                        return Material(
                          color: AppbackgroundColor.Sub_Abg_Colors,
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 0.3),
                              ),
                            ),
                            child: ListTile(
                              onTap: () async {
                                final match = _PayMentModels.firstWhere(
                                  (m) =>
                                      '${m.ser}' == '${intent.bankmerchantid}',
                                  orElse: () => PayMentModel(
                                      ser: '', ptname: '', ptser: ''),
                                );
                                String? foundKey;
                                if (match.ser != '') {
                                  foundKey = '${match.ser}:${match.ptname}';
                                }

                                setState(() {
                                  intentPayedtype = intent.payedtype.toString();
                                  intentsCustno = intent.customerNo.toString();
                                  numinvoice = intent.uuid.toString();
                                  paymentSer1 =
                                      intent.bankmerchantid.toString();
                                  selectedPaymentKey = foundKey;
                                  intentsAttacheSlipNo =
                                      intent.attache_slip_no ?? "";
                                  descripTion.text = intent.description ?? "";
                                });
                              },
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey.shade100,
                                child: logoFile != null
                                    ? ClipOval(
                                        child: Image.asset(
                                          'images/LogoBank/$logoFile',
                                          width: 26,
                                          height: 26,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                            Icons.account_balance,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.account_balance,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                              ),
                              subtitle: (intent.status != null &&
                                      intent.status != '' &&
                                      intent.status != 'null')
                                  ? Row(
                                      children: [
                                        if (intent.attache_slip_no != null &&
                                            intent.attache_slip_no != '' &&
                                            intent.attache_slip_no !=
                                                'null') ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'มีหลักฐานแล้ว',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 10),
                                        ],
                                        if (intent.status != null &&
                                            intent.status != '' &&
                                            intent.status != 'null') ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.info_outline,
                                                color: Colors.blue,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '${intent.status}',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ]
                                      ],
                                    )
                                  : null,
                              // trailing: Icon(Icons.favorite_rounded),
                              title: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: AutoSizeText(
                                      intent.uuid ?? '-',
                                      minFontSize: 10,
                                      maxFontSize: 25,
                                      maxLines: 1,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: AutoSizeText(
                                      '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${intent.softExpireAt}')) ?? "-"}',
                                      minFontSize: 10,
                                      maxFontSize: 25,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: AutoSizeText(
                                      intent.amount != null
                                          ? nFormat.format(double.tryParse(
                                                  intent.amount.toString()) ??
                                              0)
                                          : '0.00',
                                      minFontSize: 10,
                                      maxFontSize: 25,
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                          color: PeopleChaoScreen_Color
                                              .Colors_Text2_,
                                          fontFamily: Font_.Fonts_T),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text('ไม่พบข้อมูล')),
    );
  }

  // Helper method to build Tooltip with AutoSizeText
  Widget _buildTooltipText(
    String text, {
    TextAlign textAlign = TextAlign.left,
    double minFontSize = 10,
    double maxFontSize = 25,
    int maxLines = 1,
    Color? textColor,
    bool isBold = false,
  }) {
    return Tooltip(
      richMessage: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor ?? HomeScreen_Color.Colors_Text1_,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontFamily: FontWeight_.Fonts_T,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey[200],
      ),
      child: AutoSizeText(
        text,
        minFontSize: minFontSize,
        maxFontSize: maxFontSize,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor ?? PeopleChaoScreen_Color.Colors_Text2_,
          fontFamily: Font_.Fonts_T,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLeftBottomActions() {
    return (select_page != 0)
        ? SizedBox()
        : Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('เพิ่มใหม่'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _highlightGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.list,
                  color: Colors.grey,
                ),
                TextButton(
                    onPressed: () {
                      _resetToInitialState(targetPage: 0, billAll: true);
                    },
                    child: const Text('ค่าบริการทั้งหมด',
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ))),
                // TextButton(
                //     onPressed: () {},
                //     child: const Text('ใบเสร็จชั่วคราว',
                //         style: TextStyle(color: Colors.grey))),
              ],
            ),
          );
  }

  // --- Right Panel Widgets Placeholders ---

  Widget _buildRightHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: _headerBrown,
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Text(
        (select_page == 3)
            ? 'รายละเอียดบิล (${numinvoice ?? " - "})'
            : 'รายละเอียดบิล',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildRightTable() {
    return Column(
      children: [
        _buildRightTableHeader(),
        if (select_page == 0) ...[
          _buildRightTable_supPage0(),
        ] else if (select_page == 1) ...[
          _buildRightTable_supPage1(),
        ] else if (select_page == 3) ...[
          Expanded(child: _buildRightTable_supPage3()),
        ]
      ],
    );
  }

  Widget _buildRightTable_supPage0() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
        ),
        child: ListView.builder(
          // controller: _scrollController2,
          // itemExtent: 50,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _TransModels.length,
          itemBuilder: (BuildContext context, int index) {
            return Material(
              color: AppbackgroundColor.Sub_Abg_Colors,
              child: Container(
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
                            child: PopupMenuButton(
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  child: InkWell(
                                    onTap: () async {
                                      // ใช้ context ของหน้า ไม่ใช่ของเมนู
                                      final pageCtx = this.context;

                                      // ปิดเมนู (ถ้ามี)
                                      if (Navigator.of(context,
                                              rootNavigator: true)
                                          .canPop()) {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('OK');
                                      }

                                      if (_tapBusy || _dialogOpen) return;
                                      setState(() {
                                        _tapBusy = true;
                                        Formposlok_.text = '';
                                      });
                                      _dialogOpen = true;

                                      try {
                                        await showDialog<String>(
                                          context: pageCtx,
                                          useRootNavigator: true,
                                          barrierDismissible: false,
                                          builder: (BuildContext dialogCtx) {
                                            final formKey =
                                                GlobalKey<FormState>();
                                            final isLoadingVN = ValueNotifier<
                                                    bool>(
                                                false); // ✅ แทน setStateDialog

                                            Future<void> _submit() async {
                                              if (isLoadingVN.value) return;

                                              final okForm = formKey
                                                      .currentState
                                                      ?.validate() ??
                                                  false;
                                              if (!okForm) return;

                                              ChaoAppLoader.show(
                                                asset:
                                                    'images/LOGO.png', // หรือ .gif ก็ได้
                                                assetFromPackage:
                                                    false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                                useCard: false,
                                                dimBackground: true,
                                                dismissible: false,
                                                message: 'กำลังโหลด...',
                                                messageStyle: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                  fontFamily:
                                                      FontWeight_.Fonts_T,
                                                ),
                                                motion: Motion.pingPong,
                                                rangeMinAt: 0.48,
                                                rangeMaxAt: 0.52,
                                                slideMs: 1800,
                                                verticalFactor: 0.5,
                                                size: 150,
                                              );
                                              isLoadingVN.value = true;

                                              final item = _TransModels[index];
                                              final docno =
                                                  item.docno?.toString() ?? '';
                                              final ser = item.ser
                                                      ?.toString() ??
                                                  ''; // ถ้าฟังก์ชันลบต้องการ ser
                                              try {
                                                // ✅ งานหลัก
                                                await de_Trans_item(index);

                                                if (mounted) {
                                                  Formposlok_.clear();
                                                  Formterm_.clear();
                                                }

                                                // ปิด dialog แล้วค่อยโชว์ success
                                                if (Navigator.of(dialogCtx,
                                                        rootNavigator: true)
                                                    .canPop()) {
                                                  Navigator.of(dialogCtx,
                                                          rootNavigator: true)
                                                      .pop('OK');
                                                }
                                                if (mounted) {
                                                  Insert_log.Insert_logs(
                                                      'ผู้เช่า',
                                                      'วางบิล>>ลบรายการตั้งหนี้($docno)');
                                                  await Dialog_success(pageCtx,
                                                      'ทำรายการสำเร็จ');
                                                }
                                                setState(() {
                                                  didSuccess = true;
                                                });
                                              } catch (e) {
                                                await Dialog_error(dialogCtx,
                                                    'ทำรายการไม่สำเร็จ: $e');
                                              } finally {
                                                await red_Vocher();
                                                await red_Trans_select2();
                                                await red_Trans_billAll(
                                                    billAll: true);
                                                // await red_Trans_billAll();
                                                ChaoAppLoader.hide();

                                                if (isLoadingVN.value)
                                                  isLoadingVN.value = false;
                                              }
                                            }

                                            return WillPopScope(
                                              onWillPop: () async =>
                                                  !isLoadingVN.value,
                                              child: AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                backgroundColor:
                                                    AppbackgroundColor
                                                        .Sub_Abg_Colors,
                                                titlePadding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 16, 16, 0),
                                                contentPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 8, 16, 10),
                                                actionsPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        16, 0, 16, 16),
                                                title: Row(
                                                  children: [
                                                    Container(
                                                      height: 36,
                                                      width: 36,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(0.10),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Icon(
                                                          Icons
                                                              .warning_amber_rounded,
                                                          color: Colors.red),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    const Expanded(
                                                      child: Text(
                                                        'ลบรายการ',
                                                        style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T,
                                                        ),
                                                      ),
                                                    ),
                                                    // ปุ่มปิด (ปิดได้เมื่อไม่โหลด)
                                                    ValueListenableBuilder<
                                                        bool>(
                                                      valueListenable:
                                                          isLoadingVN,
                                                      builder:
                                                          (_, isLoading, __) =>
                                                              InkWell(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        onTap: isLoading
                                                            ? null
                                                            : () => Navigator.of(
                                                                    dialogCtx,
                                                                    rootNavigator:
                                                                        true)
                                                                .pop(),
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          child: Icon(
                                                              Icons.close,
                                                              size: 22,
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Form(
                                                    key: formKey,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        // chip แสดง docno
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                Colors.grey[50],
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: const Color(
                                                                    0xFFEAEAEA)),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                height: 28,
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .blue
                                                                      .withOpacity(
                                                                          0.12),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              999),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .blue
                                                                          .withOpacity(
                                                                              0.25)),
                                                                ),
                                                                child: Text(
                                                                  '${_TransModels[index].expname}',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    fontSize:
                                                                        12.5,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Expanded(
                                                                child:
                                                                    SelectableText(
                                                                  'รายการตั้งหนี้ : ${_TransModels[index].docno}',
                                                                  maxLines: 1,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .black87,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),

                                                        // คำเตือน
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.red
                                                                .withOpacity(
                                                                    0.06),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .red
                                                                    .withOpacity(
                                                                        0.18)),
                                                          ),
                                                          child: Text(
                                                            'ระบุเหตุผลการยกเลิกให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .red.shade700,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 12),

                                                        // หมายเหตุ (ต้องกรอก)
                                                        Text(
                                                          'ใส่หมายเหตุ',
                                                          style: TextStyle(
                                                            color: ManageScreen_Color
                                                                .Colors_Text2_,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 6),
                                                        TextFormField(
                                                          controller:
                                                              Formposlok_,
                                                          maxLines: 2,
                                                          maxLength: 200,
                                                          cursorColor:
                                                              Colors.blueGrey,
                                                          validator: (v) => (v ==
                                                                      null ||
                                                                  v
                                                                      .trim()
                                                                      .isEmpty)
                                                              ? 'ใส่ข้อมูลให้ครบถ้วน'
                                                              : null,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'ระบุเหตุผลการลบรายการ',
                                                            counterText: '',
                                                            isDense: true,
                                                            filled: true,
                                                            fillColor: Colors
                                                                .white
                                                                .withOpacity(
                                                                    0.3),
                                                            labelText:
                                                                'หมายเหตุ',
                                                            labelStyle:
                                                                TextStyle(
                                                              color: ManageScreen_Color
                                                                  .Colors_Text2_,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 1),
                                                            ),
                                                            errorBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  const BorderSide(
                                                                      color: Colors
                                                                          .red,
                                                                      width: 1),
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        10),
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
                                                    animation:
                                                        Listenable.merge([
                                                      Formposlok_,
                                                      isLoadingVN
                                                    ]),
                                                    builder: (ctx, _) {
                                                      final isLoading = isLoadingVN
                                                          .value; // อ่านค่าปัจจุบันของโหลด
                                                      final disabled =
                                                          Formposlok_.text
                                                                  .trim()
                                                                  .isEmpty ||
                                                              isLoading;

                                                      return SizedBox(
                                                        width: double.infinity,
                                                        child:
                                                            ElevatedButton.icon(
                                                          icon: isLoading
                                                              ? const SizedBox(
                                                                  height: 18,
                                                                  width: 18,
                                                                  child: CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      color: Colors
                                                                          .white),
                                                                )
                                                              : const Icon(Icons
                                                                  .check_circle_outline),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.black,
                                                            minimumSize: const Size
                                                                .fromHeight(44),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                          onPressed: disabled
                                                              ? null
                                                              : _submit,
                                                          label: const Text(
                                                            'ยืนยัน',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  FontWeight_
                                                                      .Fonts_T,
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
                                        _dialogOpen = false;
                                        if (mounted)
                                          setState(() => _tapBusy = false);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child:
                                                Translate.TranslateAndSetText(
                                              'ยกเลิกรายการตั้งหนี้',
                                              PeopleChaoScreen_Color
                                                  .Colors_Text1_,
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
                                if (_TransModels[index].ucost == '0.00')
                                  PopupMenuItem(
                                    child: InkWell(
                                      // ===== onTap ที่แก้ไขแล้ว =====
                                      onTap: () async {
                                        // context ตรงนี้อยู่ใน PopupMenuItem ซึ่งจะถูก pop ทิ้ง
                                        // ใช้ pageCtx จาก State แทน (คอนเท็กซ์ของหน้า ไม่ถูก dispose)
                                        final pageCtx = this.context;

                                        // ปิดเมนูให้เสร็จก่อน
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop('OK');
                                        final FormTotalterm1 =
                                            TextEditingController();
                                        final FormTotalterm2 =
                                            TextEditingController();

                                        // เช็คเงื่อนไขห้ามแบ่งชำระ
                                        final refnox =
                                            _TransModels[index].refnox ?? '';
                                        final total = double.tryParse(
                                                _TransModels[index].total ??
                                                    '0') ??
                                            0.0;
                                        final allowInsta = _TransModels[index]
                                            .allow_installments;
                                        int typeInstall = 0;

                                        if (refnox.isNotEmpty ||
                                            total < 100.0 ||
                                            allowInsta.toString() == 'false') {
                                          final msg = (total < 100.0)
                                              ? 'ไม่สามารถแบ่งชำระได้: ยอดสุทธิต้องมากกว่า 100.00 '
                                              : 'ไม่สามารถแบ่งชำระได้(หมายเหตุ: เคยถูกแบ่งชำระมาแล้วหรือประเภทมิเตอร์)';
                                          await Dialog_error(pageCtx, msg);
                                          return;
                                        }

                                        if (_tapBusy || _dialogOpen)
                                          return; // กันกดย้ำ/เปิด dialog ซ้อน
                                        setState(() {
                                          _tapBusy = true;
                                          Formterm_.text = '2';
                                        });
                                        _dialogOpen = true;

                                        try {
                                          // ตัวช่วย: แบ่งเงินเป็น 2 งวดแบบ 50/50 ปัด 2 ตำแหน่ง แล้วกระจายเศษให้ งวด 2
                                          List<double> _splitHalf2(
                                              double total) {
                                            if (total <= 0) return [0.0, 0.0];
                                            final half = total / 2.0;
                                            final a1 = double.parse(
                                                half.toStringAsFixed(2));
                                            // ให้ผลรวมเท่ากับ total เป๊ะ โดยปรับงวด 2
                                            final a2 = double.parse((total - a1)
                                                .toStringAsFixed(2));
                                            return [a1, a2];
                                          }

                                          // ===== Helpers =====
                                          final _moneyReg =
                                              RegExp(r'^\d{0,12}(\.\d{0,2})?$');
                                          double _toAmount(String? s) =>
                                              double.tryParse((s ?? '')
                                                  .replaceAll(',', '')) ??
                                              0.0;
                                          String _fmt2(double x) =>
                                              NumberFormat('#,##0.00')
                                                  .format(x);
                                          final TextInputFormatter
                                              moneyFormatter =
                                              TextInputFormatter.withFunction(
                                                  (oldV, newV) {
                                            final t = newV.text;
                                            if (t.isEmpty) return newV;
                                            return _moneyReg.hasMatch(t)
                                                ? newV
                                                : oldV;
                                          });

// จำนวนงวด และรายการ controller สำหรับแต่ละงวด
                                          final termCtrl =
                                              TextEditingController(text: '2');
                                          final List<TextEditingController>
                                              _amountCtrls = [];

// ให้มี controller เท่ากับจำนวนงวด
                                          void _ensureControllers(int n) {
                                            while (_amountCtrls.length < n) {
                                              _amountCtrls
                                                  .add(TextEditingController());
                                            }
                                            while (_amountCtrls.length > n) {
                                              _amountCtrls
                                                  .removeLast()
                                                  .dispose();
                                            }
                                          }

// คำนวณยอดรวม และปรับงวดสุดท้ายให้ผลรวม == total
                                          void _recalcLast(double total) {
                                            final n = _amountCtrls.length;
                                            if (n == 0) return;

                                            double sumPrev = 0.0;
                                            for (int i = 0; i < n - 1; i++) {
                                              sumPrev += _toAmount(
                                                  _amountCtrls[i].text);
                                            }
                                            // งวดสุดท้าย = total - ผลรวมก่อนหน้า (อย่างน้อย 0)
                                            double last = total - sumPrev;
                                            if (last < 0) last = 0;
                                            _amountCtrls[n - 1].text = last == 0
                                                ? ''
                                                : _fmt2(double.parse(
                                                    last.toStringAsFixed(2)));
                                          }

// seed ค่าแบบหารเท่า และ “งวดสุดท้าย” จะชดเชยเศษให้พอดีรวม = total
                                          void _seedEven(int n, double total) {
                                            if (n <= 0) return;
                                            final each = double.parse(
                                                (total / n).toStringAsFixed(2));
                                            for (int i = 0; i < n - 1; i++) {
                                              _amountCtrls[i].text =
                                                  each == 0 ? '' : _fmt2(each);
                                            }
                                            final last = double.parse(
                                                (total - each * (n - 1))
                                                    .toStringAsFixed(2));
                                            _amountCtrls[n - 1].text =
                                                last == 0 ? '' : _fmt2(last);
                                          }

                                          await showDialog<String>(
                                            context:
                                                pageCtx, // ✅ ใช้ pageCtx แทน context เดิม
                                            useRootNavigator:
                                                true, // ✅ กันไปผูกกับเมนู/overlay
                                            barrierDismissible:
                                                false, // 🔒 กันปิดด้วยการแตะนอกกรอบระหว่างโหลด
                                            builder: (BuildContext dialogCtx) {
                                              final formKey =
                                                  GlobalKey<FormState>();
                                              bool isLoading = false;

                                              return StatefulBuilder(
                                                builder: (ctx, setStateDialog) {
                                                  // ====== ส่งงานเมื่อกด "ยืนยัน" ======
                                                  Future<void> _submit() async {
                                                    if (isLoading) return;

                                                    // 1) Validate
                                                    final okForm = formKey
                                                            .currentState
                                                            ?.validate() ??
                                                        false;
                                                    if (!okForm) return;

                                                    // 2) Loader + สถานะโหลด (ใช้ของคุณเองแทนได้)
                                                    ChaoAppLoader.show(
                                                      asset:
                                                          'images/LOGO.png', // หรือ .gif ก็ได้
                                                      assetFromPackage:
                                                          false, // สำคัญ! บอกว่าไม่ใช่ของแพ็กเกจ
                                                      useCard: false,
                                                      dimBackground: true,
                                                      dismissible: false,
                                                      message: 'กำลังโหลด...',
                                                      messageStyle:
                                                          const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                      ),
                                                      motion: Motion.pingPong,
                                                      rangeMinAt: 0.48,
                                                      rangeMaxAt: 0.52,
                                                      slideMs: 1800,
                                                      verticalFactor: 0.5,
                                                      size: 150,
                                                    );
                                                    setStateDialog(
                                                        () => isLoading = true);

                                                    bool didSuccess = false;

                                                    try {
                                                      final preferences =
                                                          await SharedPreferences
                                                              .getInstance();
                                                      final ren =
                                                          preferences.getString(
                                                                  'renTalSer') ??
                                                              '';
                                                      final user =
                                                          preferences.getString(
                                                                  'ser') ??
                                                              '';

                                                      final sertranDocno =
                                                          '${_TransModels[index].docno}';
                                                      final remark = Formposlok_
                                                          .text
                                                          .trim();
                                                      final term =
                                                          Formterm_.text.trim();

                                                      final params =
                                                          <String, String>{
                                                        'isAdd': 'true',
                                                        'ren': ren,
                                                        'puser': user,
                                                        'docnotran':
                                                            sertranDocno,
                                                        'remark': remark,
                                                        'typeInstall':
                                                            typeInstall
                                                                .toString(),
                                                      };

                                                      if (typeInstall == 0) {
                                                        // โหมดตามงวด: ส่งแค่จำนวนงวดให้ PHP ไปแบ่งเอง
                                                        final n = int.tryParse(
                                                                Formterm_.text
                                                                    .trim()) ??
                                                            0;
                                                        if (n < 2 || n > 6) {
                                                          await Dialog_error(
                                                              pageCtx,
                                                              'จำนวนงวดต้องอยู่ระหว่าง 2–6');
                                                          return;
                                                        }
                                                        params['term'] =
                                                            n.toString();
                                                      } else {
                                                        // โหมดตามจำนวนเงิน: ส่ง amounts ให้ครบทุกงวด
                                                        final n = int.tryParse(
                                                                termCtrl.text
                                                                    .trim()) ??
                                                            0;
                                                        if (n < 2 || n > 6) {
                                                          await Dialog_error(
                                                              pageCtx,
                                                              'จำนวนงวดต้องอยู่ระหว่าง 2–6');
                                                          return;
                                                        }

                                                        // ป้องกัน index error: ให้แน่ใจว่า _amountCtrls มีครบ n ตัว
                                                        _ensureControllers(n);

                                                        // แปลงเป็นตัวเลข 4 ตำแหน่ง (ฝั่ง PHP รองรับ 4 ตำแหน่ง แล้ว DB จะปัดเป็น 2 เอง)
                                                        final amounts =
                                                            <double>[];
                                                        for (int i = 0;
                                                            i < n;
                                                            i++) {
                                                          final a = double
                                                              .parse(_toAmount(
                                                                      _amountCtrls[
                                                                              i]
                                                                          .text)
                                                                  .toStringAsFixed(
                                                                      4));
                                                          if (a <= 0) {
                                                            await Dialog_error(
                                                                pageCtx,
                                                                'ยอดงวดที่ ${i + 1} ต้องมากกว่า 0');
                                                            return;
                                                          }
                                                          amounts.add(a);
                                                        }

                                                        // ตรวจผลรวมให้เท่ากับ total (ปัด 2 ตำแหน่ง)
                                                        final sum2 =
                                                            double.parse(amounts
                                                                .fold<double>(
                                                                    0,
                                                                    (p, v) =>
                                                                        p + v)
                                                                .toStringAsFixed(
                                                                    2));
                                                        final total2 =
                                                            double.parse(total
                                                                .toStringAsFixed(
                                                                    2));
                                                        if (sum2 != total2) {
                                                          await Dialog_error(
                                                              pageCtx,
                                                              'ยอดรวมทุกงวด (${sum2.toStringAsFixed(2)}) ไม่เท่ากับยอดรวมเดิม (${total2.toStringAsFixed(2)})');
                                                          return;
                                                        }

                                                        params['term'] =
                                                            n.toString();
                                                        params['amounts'] =
                                                            jsonEncode(
                                                                amounts); // << ส่ง JSON array
                                                      }

// (ทางที่ดี) log แบบย่อ ไม่ print ค่าลับ
                                                      debugPrint(
                                                          'POST /c_trans_installments -> typeInstall=$typeInstall, term=${params['term']}');

                                                      final resp =
                                                          await httpClient
                                                              .post(
                                                                Uri.parse(
                                                                    '${MyConstant().domain}/c_trans_installments.php'),
                                                                body:
                                                                    params, // form-encoded; PHP อ่าน $_POST ได้
                                                              )
                                                              .timeout(
                                                                  const Duration(
                                                                      seconds:
                                                                          20));
                                                      // final resp = await http.get(uri).timeout(const Duration(seconds: 20));
                                                      if (resp.statusCode !=
                                                          200) {
                                                        final decoded = json
                                                            .decode(resp.body);
                                                        print(
                                                            '${decoded['message']}');
                                                        await Dialog_error(
                                                            dialogCtx,
                                                            'แบ่งชำระไม่สำเร็จ: HTTP ${resp.statusCode} : ${decoded['message']}');
                                                        return;
                                                      }

                                                      final decoded = json
                                                          .decode(resp.body);
                                                      if (decoded is! Map ||
                                                          decoded['status'] !=
                                                              'success') {
                                                        await Dialog_error(
                                                            dialogCtx,
                                                            'แบ่งชำระไม่สำเร็จ: ${decoded.toString()}');
                                                        return;
                                                      }

                                                      // เคลียร์ฟอร์ม
                                                      if (mounted) {
                                                        Formposlok_.clear();
                                                        Formterm_.clear();
                                                      }

                                                      // ✅ รีเฟรชก่อน loop เพื่อให้ _TransBillModels มีเอกสารใหม่
                                                      await red_Vocher();
                                                      await red_Trans_select2();
                                                      await red_Trans_billAll(
                                                          billAll: true);
                                                      // await red_Trans_billAll();
                                                      ChaoAppLoader.hide();

                                                      // ไล่ทำงานทีละใบที่เพิ่งสร้าง
                                                      final List<dynamic>
                                                          newdocsDyn =
                                                          (decoded['newdocno']
                                                                  as List?) ??
                                                              const [];
                                                      for (final e
                                                          in newdocsDyn) {
                                                        final doc = (e is Map &&
                                                                e['docno'] !=
                                                                    null)
                                                            ? e['docno']
                                                                .toString()
                                                            : '';
                                                        if (doc.isEmpty)
                                                          continue;

                                                        final idx =
                                                            _TransBillModels
                                                                .indexWhere((t) =>
                                                                    t.docno ==
                                                                    doc);
                                                        if (idx == -1)
                                                          continue; // กัน data lag

                                                        final selected =
                                                            await in_Trans_select(
                                                                idx);
                                                        if (selected != true)
                                                          continue;

                                                        if (contractxFineModels
                                                            .isNotEmpty) {
                                                          await in_Trans_fine(
                                                              idx);
                                                        }

                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    120)); // ผ่อน UI
                                                      }

                                                      final msg =
                                                          (decoded['message']
                                                                  as String?) ??
                                                              'ทำรายการสำเร็จ';

                                                      // ปิด dialog หลักก่อน แล้วค่อยโชว์ success
                                                      if (Navigator.of(
                                                              dialogCtx,
                                                              rootNavigator:
                                                                  true)
                                                          .canPop()) {
                                                        Navigator.of(dialogCtx,
                                                                rootNavigator:
                                                                    true)
                                                            .pop('OK');
                                                      }
                                                      if (mounted) {
                                                        Insert_log.Insert_logs(
                                                            'ผู้เช่า',
                                                            'วางบิล>>แบ่งชำระ(${sertranDocno})');
                                                        await Dialog_success(
                                                            pageCtx,
                                                            msg); // ✅ ใช้ pageCtx (context ระดับหน้า)
                                                      }
                                                      didSuccess = true;
                                                    } catch (e) {
                                                      await Dialog_error(
                                                          dialogCtx,
                                                          'แบ่งชำระไม่สำเร็จ: $e'); // ✅ ใช้ dialogCtx
                                                    } finally {
                                                      // ถ้าไม่สำเร็จ รีเฟรชปิดท้ายให้ state กลับมาถูก
                                                      // if (!didSuccess) {
                                                      await red_Vocher();
                                                      await red_Trans_select2();
                                                      await red_Trans_billAll(
                                                          billAll: true);
                                                      // await red_Trans_billAll();
                                                      ChaoAppLoader.hide();
                                                      // }

                                                      if (mounted)
                                                        setStateDialog(() =>
                                                            isLoading = false);
                                                    }
                                                  }

                                                  return WillPopScope(
                                                    onWillPop: () async =>
                                                        !isLoading, // 🔒 กันกด back ตอนโหลด
                                                    child: AlertDialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16)),
                                                      backgroundColor:
                                                          AppbackgroundColor
                                                              .Sub_Abg_Colors,
                                                      titlePadding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              16, 16, 16, 0),
                                                      contentPadding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              16, 8, 16, 10),
                                                      actionsPadding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              16, 0, 16, 16),
                                                      title: Row(
                                                        children: [
                                                          Container(
                                                            height: 36,
                                                            width: 36,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .orange
                                                                  .withOpacity(
                                                                      0.10),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: const Icon(
                                                                Icons
                                                                    .warning_amber_rounded,
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          const Expanded(
                                                            child: Text(
                                                              'แบ่งชำระ',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    FontWeight_
                                                                        .Fonts_T,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            onTap: isLoading
                                                                ? null
                                                                : () => Navigator.of(
                                                                        dialogCtx,
                                                                        rootNavigator:
                                                                            true)
                                                                    .pop(),
                                                            child:
                                                                const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(6.0),
                                                              child: Icon(
                                                                  Icons.close,
                                                                  size: 22,
                                                                  color: Colors
                                                                      .orange),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: Form(
                                                          key: formKey,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              // chip แสดง docno
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey[50],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: const Color(
                                                                          0xFFEAEAEA)),
                                                                ),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          28,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .blue
                                                                            .withOpacity(0.12),
                                                                        borderRadius:
                                                                            BorderRadius.circular(999),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.blue.withOpacity(0.25)),
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        '${_TransModels[index].expname}',
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.blue,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize:
                                                                              12.5,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            10),
                                                                    Expanded(
                                                                      child:
                                                                          SelectableText(
                                                                        '${_TransModels[index].docno}',
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.black87,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 12),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    'ประเภท : ',
                                                                    style:
                                                                        TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor: typeInstall == 0
                                                                          ? Colors
                                                                              .grey
                                                                              .shade600
                                                                          : Colors
                                                                              .grey,
                                                                      foregroundColor:
                                                                          PeopleChaoScreen_Color
                                                                              .Colors_Text3_,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              2,
                                                                          vertical:
                                                                              2),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6)),
                                                                      elevation:
                                                                          0,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      setStateDialog(
                                                                          () {
                                                                        Formterm_.text =
                                                                            '2';
                                                                        typeInstall =
                                                                            0;
                                                                      });
                                                                    },
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2.0),
                                                                      child: Text(
                                                                          'ตามงวด',
                                                                          style:
                                                                              TextStyle(fontFamily: Font_.Fonts_T)),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor: typeInstall == 1
                                                                          ? Colors
                                                                              .grey
                                                                              .shade600
                                                                          : Colors
                                                                              .grey,
                                                                      foregroundColor:
                                                                          PeopleChaoScreen_Color
                                                                              .Colors_Text3_,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              2,
                                                                          vertical:
                                                                              2),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(6)),
                                                                      elevation:
                                                                          0,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      // รวมทุกอย่างใน setStateDialog เดียว
                                                                      setStateDialog(
                                                                          () {
                                                                        typeInstall =
                                                                            1;

                                                                        // แบ่งครึ่งอย่างมีการปัด และรักษายอดรวม
                                                                        final parts =
                                                                            _splitHalf2(total);
                                                                        final a1 =
                                                                            parts[0];
                                                                        final a2 =
                                                                            parts[1];

                                                                        // ใส่ลงช่อง โดยฟอร์แมต 2 ตำแหน่ง
                                                                        FormTotalterm1
                                                                            .text = a1 >
                                                                                0
                                                                            ? _fmt2(a1)
                                                                            : '';
                                                                        FormTotalterm2
                                                                            .text = a2 >
                                                                                0
                                                                            ? _fmt2(a2)
                                                                            : '';

                                                                        // (ออปชัน) เคลียร์จำนวนงวดทิ้ง เพราะโหมดนี้คุมงวดเป็น 2 งวดตายตัว
                                                                        Formterm_.text =
                                                                            '2';
                                                                      });
                                                                      setStateDialog(
                                                                          () {
                                                                        final n =
                                                                            int.tryParse(Formterm_.text) ??
                                                                                0;
                                                                        if (n >=
                                                                                2 &&
                                                                            n <=
                                                                                6) {
                                                                          // ✅ ทุกอย่างต้องอยู่ใน setStateDialog เดียว
                                                                          setStateDialog(
                                                                              () {
                                                                            _ensureControllers(n);
                                                                            _seedEven(n,
                                                                                total); // เติมค่าเริ่มต้นแบบหารเท่า
                                                                            _recalcLast(total); // ชดเชยงวดสุดท้ายให้รวม = total เป๊ะ
                                                                          });
                                                                        }
                                                                      });

                                                                      // (ออปชัน) revalidate ฟอร์มทันทีให้ปุ่ม "ยืนยัน" อัปเดต
                                                                      // formKey.currentState?.validate();
                                                                    },
                                                                    child:
                                                                        const Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              2.0),
                                                                      child: Text(
                                                                          'ตามจำนวนเงิน',
                                                                          style:
                                                                              TextStyle(fontFamily: Font_.Fonts_T)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                  height: 12),

                                                              // จำนวนงวด
                                                              Text(
                                                                (typeInstall ==
                                                                        0)
                                                                    ? 'ระบุจำนวนงวด'
                                                                    : 'ระบุข้อมูลให้ครบถ้วน',
                                                                style:
                                                                    TextStyle(
                                                                  color: ManageScreen_Color
                                                                      .Colors_Text2_,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              if (_dialogRefresh ==
                                                                  true) ...[
                                                                CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                    color: Colors
                                                                        .green)
                                                              ] else if (typeInstall ==
                                                                  0) ...[
                                                                TextFormField(
                                                                  controller:
                                                                      Formterm_,
                                                                  maxLines: 1,
                                                                  maxLength: 1,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .number,
                                                                  cursorColor:
                                                                      Colors
                                                                          .blueGrey,
                                                                  validator:
                                                                      (v) {
                                                                    final t =
                                                                        v?.trim() ??
                                                                            '';
                                                                    final n = int
                                                                        .tryParse(
                                                                            t);
                                                                    if (n ==
                                                                            null ||
                                                                        n < 2 ||
                                                                        n > 7)
                                                                      return 'ใส่ข้อมูลให้ครบถ้วน';
                                                                    return null;
                                                                  },
                                                                  onChanged:
                                                                      (v) {
                                                                    setStateDialog(
                                                                        () {
                                                                      termCtrl
                                                                          .text = v;
                                                                    });
                                                                  },
                                                                  decoration:
                                                                      InputDecoration(
                                                                    hintText:
                                                                        'ระบุจำนวนงวดการแบ่งชำระ',
                                                                    counterText:
                                                                        '',
                                                                    isDense:
                                                                        true,
                                                                    filled:
                                                                        true,
                                                                    fillColor: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.3),
                                                                    labelText:
                                                                        'จำนวนงวด',
                                                                    labelStyle:
                                                                        TextStyle(
                                                                      color: ManageScreen_Color
                                                                          .Colors_Text2_,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      borderSide: const BorderSide(
                                                                          color: Colors
                                                                              .grey,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      borderSide: const BorderSide(
                                                                          color: Colors
                                                                              .black,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    errorBorder:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      borderSide: const BorderSide(
                                                                          color: Colors
                                                                              .red,
                                                                          width:
                                                                              1),
                                                                    ),
                                                                    contentPadding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            10),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          2.0),
                                                                  child: Text(
                                                                    (typeInstall ==
                                                                            0)
                                                                        ? '# หมายเหตุ:จำนวนงวดต้องอยู่ในช่วงระหว่าง 2 - 6 งวด'
                                                                        : '# หมายเหตุ:ประเภทแบ่งตามจำนวนเงิน จำนวนงวดสูงสุดคือ 2 - 6 งวด',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .grey,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ] else ...[
                                                                StatefulBuilder(
                                                                    builder: (ctx,
                                                                        setStateDialog) {
                                                                  return SizedBox(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .stretch,
                                                                      children: [
                                                                        // จำนวนงวด
                                                                        TextFormField(
                                                                          controller:
                                                                              termCtrl,
                                                                          maxLines:
                                                                              1,
                                                                          keyboardType:
                                                                              TextInputType.number,
                                                                          inputFormatters: [
                                                                            FilteringTextInputFormatter.digitsOnly
                                                                          ],
                                                                          cursorColor:
                                                                              Colors.blueGrey,
                                                                          validator:
                                                                              (v) {
                                                                            final n =
                                                                                int.tryParse((v ?? '').trim());
                                                                            // ✅ ให้สอดคล้องกันทั้งหมด: ใช้ 2–6
                                                                            if (n == null || n < 2 || n > 6)
                                                                              return 'ใส่จำนวนงวด 2-6';
                                                                            return null;
                                                                          },
                                                                          onChanged:
                                                                              (v) {
                                                                            final n =
                                                                                int.tryParse(v) ?? 0;
                                                                            if (n >= 2 &&
                                                                                n <= 6) {
                                                                              // ✅ ทุกอย่างต้องอยู่ใน setStateDialog เดียว
                                                                              setStateDialog(() {
                                                                                Formterm_.text = v;
                                                                                _ensureControllers(n);
                                                                                _seedEven(n, total); // เติมค่าเริ่มต้นแบบหารเท่า
                                                                                _recalcLast(total); // ชดเชยงวดสุดท้ายให้รวม = total เป๊ะ
                                                                              });
                                                                            }
                                                                          },
                                                                          decoration:
                                                                              InputDecoration(
                                                                            // ✅ hint ให้ตรงกับ validator
                                                                            hintText:
                                                                                'ระบุจำนวนงวดการแบ่งชำระ (2-6)',
                                                                            counterText:
                                                                                '',
                                                                            isDense:
                                                                                true,
                                                                            filled:
                                                                                true,
                                                                            fillColor:
                                                                                Colors.white.withOpacity(0.3),
                                                                            labelText:
                                                                                'จำนวนงวด',
                                                                            labelStyle:
                                                                                TextStyle(
                                                                              color: ManageScreen_Color.Colors_Text2_,
                                                                              fontFamily: Font_.Fonts_T,
                                                                            ),
                                                                            enabledBorder:
                                                                                const OutlineInputBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                              borderSide: BorderSide(color: Colors.grey, width: 1),
                                                                            ),
                                                                            focusedBorder:
                                                                                const OutlineInputBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                              borderSide: BorderSide(color: Colors.black, width: 1),
                                                                            ),
                                                                            errorBorder:
                                                                                const OutlineInputBorder(
                                                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                                                              borderSide: BorderSide(color: Colors.red, width: 1),
                                                                            ),
                                                                            contentPadding:
                                                                                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                12),
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.topLeft,
                                                                          child:
                                                                              Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(2.0),
                                                                            child:
                                                                                Text(
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
                                                                        const SizedBox(
                                                                            height:
                                                                                12),

                                                                        // ฟิลด์เงินแต่ละงวด
                                                                        Builder(builder:
                                                                            (_) {
                                                                          final n =
                                                                              int.tryParse(termCtrl.text.trim()) ?? 0;
                                                                          _ensureControllers(n.clamp(
                                                                              0,
                                                                              7));
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
                                                                                    inputFormatters: [
                                                                                      moneyFormatter
                                                                                    ],
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
                                                              const SizedBox(
                                                                  height: 12),
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
                                                              // const SizedBox(height: 12),

                                                              // คำเตือน
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        10),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .orange
                                                                      .withOpacity(
                                                                          0.06),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .orange
                                                                          .withOpacity(
                                                                              0.18)),
                                                                ),
                                                                child: Text(
                                                                  'ระบุเหตุผลการแบ่งชำระให้ชัดเจน เพื่อบันทึกลงประวัติรายการ',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .orange
                                                                        .shade700,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 12),

                                                              // หมายเหตุ
                                                              Text(
                                                                'ใส่หมายเหตุ',
                                                                style:
                                                                    TextStyle(
                                                                  color: ManageScreen_Color
                                                                      .Colors_Text2_,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 6),
                                                              TextFormField(
                                                                controller:
                                                                    Formposlok_,
                                                                maxLines: 2,
                                                                maxLength: 200,
                                                                cursorColor:
                                                                    Colors
                                                                        .blueGrey,
                                                                validator: (v) => (v ==
                                                                            null ||
                                                                        v
                                                                            .trim()
                                                                            .isEmpty)
                                                                    ? 'ใส่ข้อมูลให้ครบถ้วน'
                                                                    : null,
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      'ระบุเหตุผลการแบ่งชำระ',
                                                                  counterText:
                                                                      '',
                                                                  isDense: true,
                                                                  filled: true,
                                                                  fillColor: Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.3),
                                                                  labelText:
                                                                      'หมายเหตุ',
                                                                  labelStyle:
                                                                      TextStyle(
                                                                    color: ManageScreen_Color
                                                                        .Colors_Text2_,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                  ),
                                                                  enabledBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .grey,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  focusedBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .black,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  errorBorder:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    borderSide: const BorderSide(
                                                                        color: Colors
                                                                            .red,
                                                                        width:
                                                                            1),
                                                                  ),
                                                                  contentPadding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          10),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),

                                                      // ปุ่มยืนยัน: ฟังทั้ง Formposlok_ และ Formterm_
                                                      actions: [
                                                        AnimatedBuilder(
                                                          animation:
                                                              Listenable.merge([
                                                            Formposlok_,
                                                            Formterm_,
                                                            FormTotalterm1,
                                                            FormTotalterm2
                                                          ]),
                                                          builder: (ctx, _) {
                                                            final hasRemark =
                                                                Formposlok_.text
                                                                    .trim()
                                                                    .isNotEmpty;
                                                            bool canSubmit =
                                                                false;

                                                            if (typeInstall ==
                                                                0) {
                                                              final term =
                                                                  int.tryParse(
                                                                      Formterm_
                                                                          .text
                                                                          .trim());
                                                              canSubmit =
                                                                  hasRemark &&
                                                                      term !=
                                                                          null &&
                                                                      term >=
                                                                          2 &&
                                                                      term <=
                                                                          6 &&
                                                                      !isLoading;
                                                            } else {
                                                              final a1 = _toAmount(
                                                                  FormTotalterm1
                                                                      .text);
                                                              final a2 = _toAmount(
                                                                  FormTotalterm2
                                                                      .text);
                                                              final sumOk = double
                                                                      .parse((a1 +
                                                                              a2)
                                                                          .toStringAsFixed(
                                                                              2)) ==
                                                                  double.parse(total
                                                                      .toStringAsFixed(
                                                                          2));
                                                              canSubmit =
                                                                  hasRemark &&
                                                                      a1 > 0 &&
                                                                      a2 > 0 &&
                                                                      sumOk &&
                                                                      !isLoading;
                                                            }

                                                            return SizedBox(
                                                              width: double
                                                                  .infinity,
                                                              child:
                                                                  ElevatedButton
                                                                      .icon(
                                                                onPressed:
                                                                    canSubmit
                                                                        ? _submit
                                                                        : null,
                                                                icon: isLoading
                                                                    ? const SizedBox(
                                                                        height:
                                                                            18,
                                                                        width:
                                                                            18,
                                                                        child: CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2,
                                                                            color: Colors
                                                                                .white))
                                                                    : const Icon(
                                                                        Icons
                                                                            .check_circle_outline),
                                                                label: const Text(
                                                                    'ยืนยัน',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontFamily:
                                                                            FontWeight_.Fonts_T)),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black,
                                                                  minimumSize:
                                                                      const Size
                                                                          .fromHeight(44),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
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
                                          _dialogOpen = false;
                                          if (mounted)
                                            setState(() => _tapBusy = false);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child:
                                                  Translate.TranslateAndSetText(
                                                'แบ่งชำระ',
                                                PeopleChaoScreen_Color
                                                    .Colors_Text1_,
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
                                if (_TransModels[index].dis_list == '0.00')
                                  PopupMenuItem(
                                    child: InkWell(
                                        onTap: () async {
                                          String? selectedSer =
                                              "1"; // ค่าเริ่มต้น: ser = 1
                                          double vatPercent = 7;
                                          double whtPercent = 3;
                                          // ตัวอย่างข้อมูล JSON
                                          final List<Map<String, String>>
                                              vatOptions = [
                                            {"ser": "1", "name": "ก่อน VAT"}
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
                                          int vatRate = 0;
                                          int whtRate = 0;

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
                                          Widget _headerCell(String text) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                text,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontFamily: Font_.Fonts_T),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }

                                          Widget _valueCell(String value) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: Font_.Fonts_T),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }

                                          Widget _buildPercentageRow(
                                              String type,
                                              String label,
                                              TextEditingController
                                                  controllers) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                SizedBox(
                                                    child: Row(
                                                  children: [
                                                    Text(
                                                      label,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        width: 130,
                                                        child: TextField(
                                                          // controller:
                                                          //     _priceController,
                                                          textAlign:
                                                              TextAlign.end,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              controllers,
                                                          readOnly: true,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.zero,
                                                            // prefixText: '฿',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          inputFormatters: <TextInputFormatter>[
                                                            // for below version 2 use this
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    r'[0-9 .]')),
                                                            // for version 2 and greater youcan also use this
                                                            // FilteringTextInputFormatter.digitsOnly
                                                          ],
                                                        ),
                                                      ),
                                                      // Text('${percent.toStringAsFixed(0)}'),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3.0),
                                                        child: Text('฿',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          }

                                          showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                StatefulBuilder(builder:
                                                    (context, setState) {
                                              return AlertDialog(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                                backgroundColor:
                                                    AppbackgroundColor
                                                        .Sub_Abg_Colors,
                                                titlePadding:
                                                    const EdgeInsets.all(0.0),
                                                contentPadding:
                                                    const EdgeInsets.all(10.0),
                                                actionsPadding:
                                                    const EdgeInsets.all(6.0),
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          Formposlokdispri_
                                                              .clear();
                                                        });
                                                        Navigator.pop(context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Icon(
                                                            Icons.highlight_off,
                                                            size: 30,
                                                            color: Colors
                                                                .red[700]),
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
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'ส่วนลด',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
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
                                                            const SizedBox(
                                                                height: 8),
                                                            Container(
                                                              width: 260,
                                                              height: 40,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            6),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .shade300),
                                                              ),
                                                              child:
                                                                  DropdownButtonHideUnderline(
                                                                child:
                                                                    DropdownButton<
                                                                        String>(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              8)),
                                                                  isExpanded:
                                                                      true,
                                                                  value:
                                                                      selectedSer,
                                                                  items: vatOptions
                                                                      .map(
                                                                          (option) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value: option[
                                                                          'ser'],
                                                                      child:
                                                                          Text(
                                                                        option[
                                                                            'name']!,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Colors.green[700],
                                                                            fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (newValue) {
                                                                    setState(
                                                                        () {
                                                                      selectedSer =
                                                                          newValue!;
                                                                      _pvatController
                                                                              .text =
                                                                          '0.00';
                                                                      _vatController
                                                                              .text =
                                                                          '0.00';
                                                                      _whtController
                                                                              .text =
                                                                          '0.00';
                                                                      _totalController
                                                                              .text =
                                                                          '0.00';
                                                                      Formposlokdispri_
                                                                              .text =
                                                                          '0.00';
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
                                                          textAlign:
                                                              TextAlign.end,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          controller:
                                                              Formposlokdispri_,
                                                          onChanged:
                                                              (value) async {
                                                            setState(() {
                                                              vatRate = double.parse(
                                                                      _TransModels[index]
                                                                              .nvat ??
                                                                          '0')
                                                                  .round();
                                                              whtRate = double.parse(
                                                                      _TransModels[index]
                                                                              .nwht ??
                                                                          '0')
                                                                  .round();
                                                            });
                                                            var expSerVat =
                                                                _TransModels[
                                                                        index]
                                                                    .vtype;
                                                            var expSerWht =
                                                                _TransModels[
                                                                        index]
                                                                    .wht;

                                                            double
                                                                parsedModelPvat =
                                                                double.tryParse(
                                                                        _TransModels[index].pvat ??
                                                                            '0') ??
                                                                    0;
                                                            double
                                                                parsedModelTotal =
                                                                double.tryParse(
                                                                        _TransModels[index].total ??
                                                                            '0') ??
                                                                    0;
                                                            double parsedValue =
                                                                double.tryParse(
                                                                        value ??
                                                                            '0') ??
                                                                    0;

                                                            double pvat =
                                                                parsedModelPvat -
                                                                    parsedValue; // ยอดก่อนvat
                                                            double total =
                                                                parsedModelTotal -
                                                                    parsedValue; // ยอดสุทธิ

                                                            setState(() {
                                                              if (parsedValue >
                                                                  parsedModelPvat) {
                                                                _pvatController
                                                                        .text =
                                                                    '0.00';
                                                                Formposlokdispri_
                                                                        .text =
                                                                    '0.00';
                                                                _vatController
                                                                        .text =
                                                                    '0.00';
                                                                _whtController
                                                                        .text =
                                                                    '0.00';
                                                                _totalController
                                                                        .text =
                                                                    '0.00';
                                                              } else {
                                                                _pvatController
                                                                        .text =
                                                                    pvat.toStringAsFixed(
                                                                        2);
                                                              }
                                                            });
                                                            if (total != null &&
                                                                total > 0 &&
                                                                selectedSer
                                                                        .toString() ==
                                                                    '2') {
                                                              print(
                                                                  '✅ คำนวณย้อนกลับ: รู้ยอดสุทธิ → หาก่อน VAT');

                                                              double base = total /
                                                                  (1 +
                                                                      vatRate /
                                                                          100 -
                                                                      whtRate /
                                                                          100);
                                                              double vatAmount =
                                                                  base *
                                                                      vatRate /
                                                                      100;
                                                              double whtAmount =
                                                                  base *
                                                                      whtRate /
                                                                      100;

                                                              _pvatController
                                                                      .text =
                                                                  base.toStringAsFixed(
                                                                      2);
                                                              _vatController
                                                                      .text =
                                                                  vatAmount
                                                                      .toStringAsFixed(
                                                                          2);
                                                              _whtController
                                                                      .text =
                                                                  whtAmount
                                                                      .toStringAsFixed(
                                                                          2);
                                                              _totalController
                                                                      .text =
                                                                  total
                                                                      .toStringAsFixed(
                                                                          2);
                                                            } else if (pvat !=
                                                                    null &&
                                                                pvat > 0 &&
                                                                selectedSer
                                                                        .toString() ==
                                                                    '1') {
                                                              print(
                                                                  '✅ ✅ คำนวณไปข้างหน้า: รู้ก่อน VAT → หายอดสุทธิ');

                                                              double vatAmount =
                                                                  pvat *
                                                                      vatRate /
                                                                      100;
                                                              double whtAmount =
                                                                  pvat *
                                                                      whtRate /
                                                                      100;
                                                              double total =
                                                                  pvat +
                                                                      vatAmount -
                                                                      whtAmount;

                                                              _vatController
                                                                      .text =
                                                                  vatAmount
                                                                      .toStringAsFixed(
                                                                          2);
                                                              _whtController
                                                                      .text =
                                                                  whtAmount
                                                                      .toStringAsFixed(
                                                                          2);
                                                              _totalController
                                                                      .text =
                                                                  total
                                                                      .toStringAsFixed(
                                                                          2);
                                                            } else {
                                                              print(
                                                                  '❌ กรุณากรอกยอดก่อน VAT หรือยอดสุทธิ');
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
                                                          decoration:
                                                              InputDecoration(
                                                            prefixText: 'ราคา',
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                          inputFormatters: <TextInputFormatter>[
                                                            // for below version 2 use this
                                                            FilteringTextInputFormatter
                                                                .allow(RegExp(
                                                                    r'[0-9 .]')),
                                                            // for version 2 and greater youcan also use this
                                                            // FilteringTextInputFormatter.digitsOnly
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 12),
                                                      const Divider(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Table(
                                                          border: TableBorder
                                                              .symmetric(
                                                            inside: BorderSide(
                                                                width: 0.5,
                                                                color: Colors
                                                                    .grey
                                                                    .shade400),
                                                          ),
                                                          columnWidths: const {
                                                            0: FlexColumnWidth(),
                                                            1: FlexColumnWidth(),
                                                            2: FlexColumnWidth(),
                                                            3: FlexColumnWidth(),
                                                          },
                                                          children: [
                                                            TableRow(
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade600),
                                                              children: [
                                                                _headerCell(
                                                                    'ก่อนVAT'),
                                                                _headerCell(
                                                                    'VAT'),
                                                                _headerCell(
                                                                    'WHT'),
                                                                _headerCell(
                                                                    'ยอดสุทธิ'),
                                                              ],
                                                            ),
                                                            TableRow(
                                                              decoration:
                                                                  BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade100),
                                                              children: [
                                                                _valueCell(
                                                                    '${nFormat.format(double.parse(_TransModels[index].pvat!))}'),
                                                                _valueCell(
                                                                    '${nFormat.format(double.parse(_TransModels[index].vat!))}'),
                                                                _valueCell(
                                                                    '${nFormat.format(double.parse(_TransModels[index].wht!))}'),
                                                                _valueCell(
                                                                    '${nFormat.format(double.parse(_TransModels[index].total!))}'),
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
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              fontFamily: Font_
                                                                  .Fonts_T),
                                                        ),
                                                      ),
                                                      SizedBox(height: 12),
                                                      _buildPercentageRow(
                                                          '',
                                                          'ก่อนVAT',
                                                          _pvatController),
                                                      SizedBox(height: 12),
                                                      _buildPercentageRow(
                                                          'VAT',
                                                          'ภาษีมูลค่าเพิ่ม (VAT $vatRate%)',
                                                          _vatController),
                                                      SizedBox(height: 8),
                                                      _buildPercentageRow(
                                                          'WHT',
                                                          'หักภาษี ณ ที่จ่าย (WHT $whtRate%)',
                                                          _whtController),
                                                      SizedBox(height: 8),
                                                      _buildPercentageRow(
                                                          'Total',
                                                          'ยอดสุทธิ',
                                                          _totalController),
                                                      SizedBox(height: 16),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          minimumSize: Size(
                                                              double.infinity,
                                                              48),
                                                        ),
                                                        onPressed: (Formposlokdispri_
                                                                    .text
                                                                    .isEmpty ||
                                                                double.parse(
                                                                        Formposlokdispri_
                                                                            .text) <=
                                                                    0)
                                                            ? null
                                                            : () async {
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
                                                                var sertran =
                                                                    _TransModels[
                                                                            index]
                                                                        .ser;

                                                                final velText =
                                                                    Formposlokdispri_
                                                                        .text
                                                                        .trim();
                                                                final pvatText =
                                                                    _pvatController
                                                                        .text
                                                                        .trim();
                                                                final vatText =
                                                                    _vatController
                                                                        .text
                                                                        .trim();
                                                                final whtText =
                                                                    _whtController
                                                                        .text
                                                                        .trim();
                                                                final totalText =
                                                                    _totalController
                                                                        .text
                                                                        .trim();

                                                                final disuser =
                                                                    double.tryParse(
                                                                        velText);
                                                                final pvat = double
                                                                    .tryParse(
                                                                        pvatText);
                                                                final vat = double
                                                                    .tryParse(
                                                                        vatText);
                                                                final wht = double
                                                                    .tryParse(
                                                                        whtText);
                                                                final total =
                                                                    double.tryParse(
                                                                        totalText);
                                                                // setState(() {
                                                                //   total_dislist = double.tryParse(velText);
                                                                // });

                                                                if (disuser ==
                                                                        null ||
                                                                    vat ==
                                                                        null ||
                                                                    wht ==
                                                                        null ||
                                                                    total ==
                                                                        null) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          'ข้อมูลไม่ถูกต้อง',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontFamily: Font_.Fonts_T)),
                                                                    ),
                                                                  );
                                                                  return;
                                                                }

                                                                if (vat <=
                                                                    total) {
                                                                  final url =
                                                                      Uri.parse(
                                                                          '${MyConstant().domain}/c_trans_selectdis_v2.php');
                                                                  print(
                                                                      '📡 POST to: $url');

                                                                  try {
                                                                    final response =
                                                                        await httpClient
                                                                            .post(
                                                                      url,
                                                                      // headers: {
                                                                      //   'Content-Type': 'application/x-www-form-urlencoded'
                                                                      // },
                                                                      body: {
                                                                        'isAdd':
                                                                            'true',
                                                                        'ren': ren ??
                                                                            '',
                                                                        'disuser':
                                                                            disuser.toStringAsFixed(2),
                                                                        'sertran':
                                                                            sertran ??
                                                                                '',
                                                                        'pvatnew':
                                                                            pvat!.toStringAsFixed(2),
                                                                        'vatnew':
                                                                            vat.toStringAsFixed(2),
                                                                        'whtnew':
                                                                            wht.toStringAsFixed(2),
                                                                        'totalnew':
                                                                            total.toStringAsFixed(2),
                                                                      },
                                                                    );

                                                                    print({
                                                                      'isAdd':
                                                                          'true',
                                                                      'ren':
                                                                          ren ??
                                                                              '',
                                                                      'disuser':
                                                                          disuser
                                                                              .toStringAsFixed(2),
                                                                      'sertran':
                                                                          sertran ??
                                                                              '',
                                                                      'pvatnew':
                                                                          pvat!.toStringAsFixed(
                                                                              2),
                                                                      'vatnew':
                                                                          vat.toStringAsFixed(
                                                                              2),
                                                                      'whtnew':
                                                                          wht.toStringAsFixed(
                                                                              2),
                                                                      'totalnew':
                                                                          total.toStringAsFixed(
                                                                              2),
                                                                      // 'Formposlokdispri_': Formposlokdispri_.text.trim(),
                                                                    });

                                                                    if (response
                                                                            .statusCode ==
                                                                        200) {
                                                                      final result =
                                                                          json.decode(
                                                                              response.body);
                                                                      // print('✅ RESPONSE: $result');

                                                                      if (result['success']
                                                                              .toString() ==
                                                                          'true') {
                                                                        setState(
                                                                            () {
                                                                          red_Trans_select2();
                                                                          red_Trans_billAll(
                                                                              billAll: true);
                                                                          // red_Trans_billAll();
                                                                          Formposlokdispri_
                                                                              .clear();
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          Formposlokdispri_
                                                                              .clear();
                                                                        });
                                                                      }

                                                                      Navigator.pop(
                                                                          context);
                                                                    } else {
                                                                      print(
                                                                          '❌ Server Error: ${response.statusCode}');
                                                                      Navigator.pop(
                                                                          context);
                                                                    }
                                                                  } catch (e) {
                                                                    print(
                                                                        '❌ Exception: $e');
                                                                    Navigator.pop(
                                                                        context);
                                                                  }
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                          'Total Error  $disuser // $total ',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontFamily: Font_.Fonts_T)),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                        child: Text('บันทึก',
                                                            style: TextStyle(
                                                                fontSize: 16)),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              );
                                            }),
                                          );
                                        },
                                        child: Container(
                                            padding: const EdgeInsets.all(10),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Translate
                                                      .TranslateAndSetText(
                                                          'ส่วนลดรายการ',
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text1_,
                                                          TextAlign.center,
                                                          null,
                                                          Font_.Fonts_T,
                                                          13,
                                                          1),
                                                )
                                              ],
                                            ))),
                                  ),
                              ],
                              child: Center(
                                child: AutoSizeText(
                                  minFontSize: 10,
                                  maxFontSize: 15,
                                  maxLines: 1,
                                  '${index + 1}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            )),
                        Expanded(
                          flex: 1,
                          child: AutoSizeText(
                            minFontSize: 10,
                            maxFontSize: 15,
                            maxLines: 1,
                            '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${_TransModels[index].date} 00:00:00'))}', //${_TransModels[index].date}
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Tooltip(
                            richMessage: TextSpan(
                              text:
                                  '${_TransModels[index].name} : ${_TransModels[index].docno}',
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
                              maxFontSize: 15,
                              maxLines: 1,
                              '${_TransModels[index].name}',
                              textAlign: TextAlign.start,
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
                            '${_TransModels[index].tqty}',
                            textAlign: TextAlign.end,
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
                            '${_TransModels[index].unit_con}',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Tooltip(
                            richMessage: TextSpan(
                              text: '${_TransModels[index].pvat}',
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
                              maxFontSize: 15,
                              maxLines: 1,
                              nFormat.format(double.tryParse(
                                      _TransModels[index].pvat ?? '0') ??
                                  0),
                              // _TransModels[index].qty_con ==
                              //         '0.00'
                              //     ? '${nFormat.format(double.parse(_TransModels[index].amt_con!))}'
                              //     //'${_TransModels[index].amt_con}'
                              //     : '${nFormat.format(double.parse(_TransModels[index].qty_con!))}',
                              // //'${_TransModels[index].qty_con}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Tooltip(
                            richMessage: TextSpan(
                              text: '${_TransModels[index].vat}',
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
                              maxFontSize: 15,
                              maxLines: 1,
                              '${nFormat.format(double.parse(_TransModels[index].vat!))}',
                              //'${_TransModels[index].qty_con}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  //fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Tooltip(
                            richMessage: TextSpan(
                              text: '${_TransModels[index].wht}',
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
                              maxFontSize: 15,
                              maxLines: 1,
                              '${nFormat.format(double.parse(_TransModels[index].wht!))}',
                              //'${_TransModels[index].qty_con}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
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
                            '${nFormat.format(double.parse(_TransModels[index].total!))}',
                            // '${_TransModels[index].pvat}',
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text2_,
                                //fontWeight: FontWeight.bold,
                                fontFamily: Font_.Fonts_T),
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          child: Center(
                            child: IconButton(
                                onPressed: () {
                                  de_Trans_select(index);
                                },
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                )),
                          ),
                        ),
                      ],
                    ),
                    // double.parse(_TransModels[index].dis_list!) == 0.0
                    ((double.tryParse(_TransModels[index].dis_list ?? '0') ??
                                0) ==
                            0)
                        ? SizedBox()
                        : Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Expanded(
                                flex: 1,
                                child: Icon(
                                  Icons.subdirectory_arrow_right,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: AutoSizeText(
                                  'discount ${nFormat.format(double.tryParse(_TransModels[index].dis_list ?? '0'))}',
                                  minFontSize: 10,
                                  maxFontSize: 12,
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ],
                          ),

                    for (int inde = 0; inde < transFineModels.length; inde++)
                      _TransModels[index].docno != transFineModels[inde].docno
                          ? SizedBox()
                          : Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 12,
                                    maxLines: 1,
                                    '${transFineModels[inde].expname}',
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 12,
                                    maxLines: 1,
                                    double.parse(transFineModels[inde].vat!) ==
                                            0.0
                                        ? ''
                                        : '${nFormat.format(double.parse(transFineModels[inde].pvat!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 12,
                                    maxLines: 1,
                                    double.parse(transFineModels[inde].vat!) ==
                                            0.0
                                        ? ''
                                        : '${nFormat.format(double.parse(transFineModels[inde].vat!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AutoSizeText(
                                    minFontSize: 8,
                                    maxFontSize: 12,
                                    maxLines: 1,
                                    '${nFormat.format(double.parse(transFineModels[inde].total!))}', //${nFormat.format(double.parse(_TransModels[index].total!))}
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        //fontWeight: FontWeight.bold,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                      onPressed: () async {
                                        SharedPreferences preferences =
                                            await SharedPreferences
                                                .getInstance();
                                        var renTal_lavel = int.parse(preferences
                                            .getString('lavel')
                                            .toString());
                                        if (renTal_lavel >= 4) {
                                          de_Trans_select_fine(inde);
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Translate.TranslateAndSetText(
                                                      'User ของท่านไม่สามารถทำการลบค่าปรับเกินกำหนดชำระได้ ',
                                                      Colors.red,
                                                      TextAlign.center,
                                                      null,
                                                      Font_.Fonts_T,
                                                      14,
                                                      1),
                                              // Text('User ของท่านไม่สามารถทำการลบค่าปรับเกินกำหนดชำระได้ ')
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      )),
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
    );
  }

  Widget _buildRightTable_supPage1() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: const BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
        ),
        child: Builder(
          builder: (context) {
            // ✅ แสดงตาม _InvoiceHistoryModels จริง (ไม่ block ด้วย paymentIntents)
            if (_InvoiceHistoryModels.isEmpty) {
              return const Center(
                child: Text(' ', style: TextStyle(fontFamily: Font_.Fonts_T)),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _InvoiceHistoryModels.length,
              itemBuilder: (BuildContext context, int index) {
                final m = _InvoiceHistoryModels[index];

                // ===== helpers =====
                TextStyle _baseStyle({
                  Color? color,
                  TextDecoration? deco,
                  Color? decoColor,
                }) {
                  return TextStyle(
                    color: color ?? PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T,
                    decoration: deco,
                    decorationColor: decoColor,
                  );
                }

                double _d(dynamic v) {
                  final s = (v ?? '0').toString().trim();
                  return double.tryParse(s.isEmpty ? '0' : s) ?? 0;
                }

                String _fmtDate(String? iso) {
                  try {
                    return DateFormat('dd-MM-yyyy').format(
                        DateTime.parse('${(iso ?? '').trim()} 00:00:00'));
                  } catch (_) {
                    return '';
                  }
                }

                String _fmtNum(dynamic v) => nFormat.format(_d(v));

                Widget _cellText(
                  String text, {
                  int flex = 1,
                  TextAlign align = TextAlign.left,
                  int min = 8,
                  int max = 14,
                  int lines = 1,
                  TextStyle? style,
                  TextOverflow overflow = TextOverflow.ellipsis,
                }) {
                  return Expanded(
                    flex: flex,
                    child: AutoSizeText(
                      minFontSize: min.toDouble(),
                      maxFontSize: max.toDouble(),
                      maxLines: lines,
                      text,
                      textAlign: align,
                      overflow: overflow,
                      style: style ?? _baseStyle(),
                    ),
                  );
                }

                Widget _fixedIndexCell(String text) {
                  return SizedBox(
                    width: 50,
                    child: AutoSizeText(
                      minFontSize: 8,
                      maxFontSize: 14,
                      maxLines: 1,
                      text,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: _baseStyle(),
                    ),
                  );
                }

                Widget _tooltipDescr(String shown, String raw) {
                  return Expanded(
                    flex: 2,
                    child: Tooltip(
                      richMessage: TextSpan(
                        text: raw,
                        style: const TextStyle(
                          color: HomeScreen_Color.Colors_Text1_,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[200],
                      ),
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 14,
                        maxLines: 1,
                        shown,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: _baseStyle(),
                      ),
                    ),
                  );
                }

                Widget _tooltipStrike(String shown, String raw) {
                  return Expanded(
                    flex: 1,
                    child: Tooltip(
                      richMessage: TextSpan(
                        text: raw,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          color: HomeScreen_Color.Colors_Text1_,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey[200],
                      ),
                      child: AutoSizeText(
                        minFontSize: 8,
                        maxFontSize: 14,
                        maxLines: 1,
                        shown,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: _baseStyle(
                          deco: TextDecoration.lineThrough,
                          decoColor: Colors.red,
                        ),
                      ),
                    ),
                  );
                }
                // ===================

                final dis = _d(m.dis_list);
                final hasDiscount = dis > 0;

                final isKU = (m.dtype?.toString() == 'KU');
                final priText = isKU ? _fmtNum(m.pri) : '-';
                final priAlign = isKU ? TextAlign.right : TextAlign.center;

                final strikeStyle = _baseStyle(
                  deco: TextDecoration.lineThrough,
                  decoColor: Colors.red,
                );

                final descr = (m.descr ?? '').toString();
                final refno = (m.refno ?? '').toString();
                final qtyText = (m.qty ?? '0').toString().trim().isEmpty
                    ? '0'
                    : (m.qty ?? '0').toString().trim();

                final totalVal = _d(m.pvat == null ? '0' : (m.total ?? '0'));

                return Material(
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  child: Container(
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
                        // ===== row original (strike-through) =====
                        if (hasDiscount)
                          Row(
                            children: [
                              _fixedIndexCell('${index + 1}'),
                              _cellText(_fmtDate(m.date),
                                  flex: 1, align: TextAlign.left),
                              _tooltipDescr(descr, '$descr : $refno'),
                              _cellText(qtyText,
                                  flex: 1, align: TextAlign.right),
                              _cellText(priText, flex: 1, align: priAlign),
                              _tooltipStrike(_fmtNum(m.pvat_original),
                                  '${m.pvat_original}'),
                              _tooltipStrike(
                                  _fmtNum(m.vat_original), '${m.vat_original}'),
                              _tooltipStrike(
                                  '${m.wht_original}', '${m.wht_original}'),
                              _cellText(
                                _fmtNum(m.amount_original),
                                flex: 1,
                                align: TextAlign.right,
                                style: strikeStyle,
                              ),
                            ],
                          ),

                        // ===== row current =====
                        Row(
                          children: [
                            _fixedIndexCell(hasDiscount ? '' : '${index + 1}'),
                            _cellText(
                              hasDiscount ? '' : _fmtDate(m.date),
                              flex: 1,
                              align: TextAlign.left,
                            ),
                            Expanded(
                              flex: 2,
                              child: hasDiscount
                                  ? Row(
                                      children: [
                                        const Icon(
                                          Icons.subdirectory_arrow_right,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                        Expanded(
                                          child: AutoSizeText(
                                            minFontSize: 10,
                                            maxFontSize: 12,
                                            'discount ${_fmtNum(m.dis_list)}',
                                            textAlign: TextAlign.left,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                _baseStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    )
                                  : AutoSizeText(
                                      minFontSize: 8,
                                      maxFontSize: 14,
                                      maxLines: 1,
                                      descr,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      style: _baseStyle(),
                                    ),
                            ),
                            _cellText(
                              hasDiscount ? '' : qtyText,
                              flex: 1,
                              align: TextAlign.right,
                            ),
                            _cellText(
                              hasDiscount ? '' : priText,
                              flex: 1,
                              align: priAlign,
                            ),
                            _cellText(_fmtNum(m.pvat),
                                flex: 1, align: TextAlign.right),
                            _cellText(_fmtNum(m.vat),
                                flex: 1, align: TextAlign.right),
                            _cellText('${m.wht}',
                                flex: 1, align: TextAlign.right),
                            _cellText(
                              nFormat.format(totalVal),
                              flex: 1,
                              align: TextAlign.right,
                            ),
                          ],
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
    );
  }

  Widget _buildRightTable_supPage3() {
    // ✅ อยู่นอก itemBuilder เพื่อเก็บสถานะพับ/ขยาย
    final Set<int> _expandedRows = <int>{};

    return StatefulBuilder(
      builder: (context, setInnerState) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: const BoxDecoration(
              color: AppbackgroundColor.Sub_Abg_Colors,
            ),
            child: Builder(
              builder: (context) {
                final String targetUuid = '$numinvoice';
                final intents =
                    paymentIntents.where((p) => p.uuid == targetUuid).toList();

                if (intents.isEmpty) {
                  return const Center(child: Text(' '));
                }

                final intent = intents.first;
                final iTems = intent.invoices ?? [];

                // ---------- helpers ----------
                double _d(dynamic v) {
                  final s = (v ?? '0').toString().trim();
                  return double.tryParse(s.isEmpty ? '0' : s) ?? 0.0;
                }

                String _fmtNum(dynamic v) => nFormat.format(_d(v));

                String _fmtDate(String? iso) {
                  try {
                    final raw = (iso ?? '').trim();
                    if (raw.isEmpty) return '';
                    // รองรับ yyyy-MM-dd
                    return DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse('$raw 00:00:00'));
                  } catch (_) {
                    return '';
                  }
                }

                Widget cell({
                  required String data,
                  required int flex,
                  required TextAlign align,
                  FontWeight? weight,
                }) {
                  return Expanded(
                    flex: flex,
                    child: AutoSizeText(
                      data,
                      minFontSize: 10,
                      maxFontSize: 15,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: align,
                      style: TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T,
                        fontWeight: weight,
                      ),
                    ),
                  );
                }

                Widget cellSub({
                  required String data,
                  required int flex,
                  required TextAlign align,
                  FontWeight? weight,
                }) {
                  return Expanded(
                    flex: flex,
                    child: AutoSizeText(
                      data,
                      minFontSize: 10,
                      maxFontSize: 12,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: align,
                      style: TextStyle(
                        color: Colors.red,
                        fontFamily: Font_.Fonts_T,
                        fontWeight: weight,
                      ),
                    ),
                  );
                }

                // ✅ แถวย่อย (ค่าปรับ/ส่วนลด) ไม่กำหนด height เพื่อกัน overflow
                Widget subRow({
                  required Widget lead, // icon/space
                  required List<Widget> children,
                  EdgeInsets padding = const EdgeInsets.only(left: 30),
                  Color? dividerColor,
                }) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: dividerColor == null
                        ? null
                        : BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: dividerColor,
                                width: 0.5,
                              ),
                            ),
                          ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 30),
                        lead,
                        ...children,
                      ],
                    ),
                  );
                }

                // ✅ ค่าปรับต่อ invoice นี้เท่านั้น (ไม่ยิงทั้ง intent.invoices ซ้ำทุกแถว)
                List<Widget> buildFeeRowsForInvoice(dynamic invoice) {
                  final list = invoice.listfee ?? [];
                  if (list.isEmpty) return <Widget>[];

                  return list.map<Widget>((f) {
                    final total = (f.total as num?)?.toDouble() ?? _d(f.total);
                    if (total <= 0) return const SizedBox.shrink();

                    return subRow(
                      lead: const Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.subdirectory_arrow_right,
                          color: Colors.grey,
                          size: 16,
                        ),
                      ),
                      children: [
                        cellSub(
                          data: '${f.expname ?? 'ค่าปรับ'}',
                          flex: 2,
                          align: TextAlign.start,
                        ),
                        cellSub(data: '', flex: 3, align: TextAlign.start),
                        cellSub(data: '', flex: 1, align: TextAlign.end),
                        // cellSub(
                        //     data: _fmtNum(f.pvat),
                        //     flex: 1,
                        //     align: TextAlign.end),
                        cellSub(
                            data: _fmtNum(f.vat),
                            flex: 1,
                            align: TextAlign.end),
                        cellSub(
                            data: _fmtNum(f.wht),
                            flex: 2,
                            align: TextAlign.end),
                        cellSub(
                            data: _fmtNum(total),
                            flex: 2,
                            align: TextAlign.end),
                        cellSub(
                            data: _fmtNum(0), flex: 2, align: TextAlign.end),
                        cellSub(
                            data: _fmtNum(total),
                            flex: 2,
                            align: TextAlign.end),
                        SizedBox(
                          width: 5,
                        )
                      ],
                    );
                  }).toList();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: iTems.length,
                  itemBuilder: (context, index) {
                    final items = iTems[index];
                    final metas = items.metadata ?? [];

                    final bool expanded = _expandedRows.contains(index);

                    void toggle() {
                      if (metas.isEmpty) return;
                      setInnerState(() {
                        expanded
                            ? _expandedRows.remove(index)
                            : _expandedRows.add(index);
                      });
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          // ================= MAIN ROW =================
                          if (intent.payedtype.toString() == 'invoice')
                            InkWell(
                              onTap: toggle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 6),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black12, width: 1),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: metas.isNotEmpty
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: InkResponse(
                                                onTap: toggle,
                                                radius: 18,
                                                child: Icon(
                                                  expanded
                                                      ? Icons
                                                          .keyboard_arrow_down
                                                      : Icons
                                                          .keyboard_arrow_right,
                                                  size: 18,
                                                ),
                                              ),
                                            )
                                          : AutoSizeText(
                                              '${index + 1}',
                                              minFontSize: 10,
                                              maxFontSize: 15,
                                              maxLines: 1,
                                              style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                    ),
                                    cell(
                                      data: metas.isNotEmpty
                                          ? _fmtDate(metas.first.date)
                                          : '',
                                      flex: 1,
                                      align: TextAlign.start,
                                    ),
                                    cell(
                                      data: items.billReference ?? '',
                                      flex: 2,
                                      align: TextAlign.center,
                                      weight: FontWeight.bold,
                                    ),
                                    cell(
                                      data: '${items.vatAmount}',
                                      flex: 1,
                                      align: TextAlign.end,
                                    ),
                                    cell(
                                        data: '${items.withholdingAmount}',
                                        flex: 1,
                                        align: TextAlign.end),
                                    cell(
                                      data: _fmtNum(items.amount),
                                      flex: 1,
                                      align: TextAlign.end,
                                    ),
                                    cell(
                                        data: _fmtNum(items.discountAmount),
                                        flex: 1,
                                        align: TextAlign.end),
                                    cell(
                                      data: _fmtNum(items.total),
                                      flex: 1,
                                      align: TextAlign.end,
                                      weight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // ================= FEE ROWS (invoice นี้เท่านั้น) =================
                          if (intent.payedtype.toString() == 'invoice')
                            ...buildFeeRowsForInvoice(items),

                          // ================= CHILD ROWS =================
                          if (expanded ||
                              intent.payedtype.toString() == 'service')
                            ...metas.map<Widget>((m) {
                              final hasDiscount = (m.dislis ?? 0) > 0;
                              // final hasFee = (m.listfee?.isNotEmpty ?? false);
                              final list = items.listfee ?? [];
                              final hasFee = list.isNotEmpty ?? false;

                              return Container(
                                padding: const EdgeInsets.only(
                                    left: 30, top: 6, bottom: 6),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.black12, width: 0.5),
                                  ),
                                ),
                                child: (hasDiscount || hasFee)
                                    ? SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                  child: AutoSizeText(
                                                    '${index + 1}',
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                cell(
                                                  data: _fmtDate(m.date),
                                                  flex: 1,
                                                  align: TextAlign.start,
                                                ),
                                                cell(
                                                  data: m.expname ?? '',
                                                  flex: 2,
                                                  align: TextAlign.center,
                                                ),
                                                cell(
                                                    data: '1',
                                                    flex: 1,
                                                    align: TextAlign.end),
                                                cell(
                                                  data: _fmtNum(m.priBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.pvatBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.vatBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.whtBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.totalBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                              ],
                                            ),
                                            if (hasDiscount)
                                              subRow(
                                                lead: const Expanded(
                                                  flex: 1,
                                                  child: Icon(
                                                    Icons
                                                        .subdirectory_arrow_right,
                                                    color: Colors.grey,
                                                    size: 16,
                                                  ),
                                                ),
                                                children: [
                                                  Expanded(
                                                    flex: 7,
                                                    child: AutoSizeText(
                                                      'discount ${_fmtNum(m.dislis)}',
                                                      minFontSize: 10,
                                                      maxFontSize: 12,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (intent.payedtype.toString() ==
                                                'service')
                                              ...buildFeeRowsForInvoice(items),
                                            // if (hasFee)
                                            //   ...m.listfee!.map<Widget>((f) {
                                            //     final total = (f.total as num?)
                                            //             ?.toDouble() ??
                                            //         _d(f.total);
                                            //     if (total <= 0)
                                            //       return const SizedBox
                                            //           .shrink();

                                            //     return subRow(
                                            //       lead: const Expanded(
                                            //         flex: 1,
                                            //         child: Icon(
                                            //           Icons
                                            //               .subdirectory_arrow_right,
                                            //           color: Colors.grey,
                                            //           size: 16,
                                            //         ),
                                            //       ),
                                            //       children: [
                                            //         cellSub(
                                            //           data:
                                            //               '${f.expname ?? 'ค่าปรับ'}',
                                            //           flex: 2,
                                            //           align: TextAlign.start,
                                            //         ),
                                            //         cellSub(
                                            //             data: '',
                                            //             flex: 1,
                                            //             align: TextAlign.start),
                                            //         cellSub(
                                            //             data: '',
                                            //             flex: 1,
                                            //             align: TextAlign.end),
                                            //         cellSub(
                                            //           data: _fmtNum(f.pvat),
                                            //           flex: 1,
                                            //           align: TextAlign.end,
                                            //         ),
                                            //         cellSub(
                                            //           data: _fmtNum(f.vat),
                                            //           flex: 1,
                                            //           align: TextAlign.end,
                                            //         ),
                                            //         cellSub(
                                            //           data: _fmtNum(f.wht),
                                            //           flex: 1,
                                            //           align: TextAlign.end,
                                            //         ),
                                            //         cellSub(
                                            //           data: _fmtNum(total),
                                            //           flex: 1,
                                            //           align: TextAlign.end,
                                            //         ),
                                            //       ],
                                            //     );
                                            //   }).toList(),
                                          ],
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                  child: AutoSizeText(
                                                    '${index + 1}',
                                                    minFontSize: 10,
                                                    maxFontSize: 15,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                cell(
                                                  data: _fmtDate(m.date),
                                                  flex: 1,
                                                  align: TextAlign.start,
                                                ),
                                                cell(
                                                  data: m.expname ?? '',
                                                  flex: 2,
                                                  align: TextAlign.center,
                                                ),
                                                cell(
                                                    data: '1',
                                                    flex: 1,
                                                    align: TextAlign.end),
                                                cell(
                                                  data: _fmtNum(m.priBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.pvatBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.vatBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.whtBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                                cell(
                                                  data: _fmtNum(m.totalBill),
                                                  flex: 1,
                                                  align: TextAlign.end,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                              );
                            }).toList(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Widget _buildRightTable_supPage3() {
  //   return Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Container(
  //           decoration: const BoxDecoration(
  //             color: AppbackgroundColor.Sub_Abg_Colors,
  //           ),
  //           clipBehavior: Clip.antiAlias, // ให้มุมมนทำงานกับ ripple

  //           child: Column(children: [
  //             // billHeaderTable(context, invoice: '$numinvoice'),
  //             Builder(builder: (context) {
  //               final String targetUuid = '$numinvoice';

  //               final filteredIntents =
  //                   paymentIntents.where((p) => p.uuid == targetUuid).toList();

  //               // ไม่เจอ intent → คืน ListView ว่าง ๆ / ข้อความ
  //               if (filteredIntents.isEmpty) {
  //                 return const Center(
  //                   child: Text(
  //                     ' ',
  //                     style: TextStyle(fontFamily: Font_.Fonts_T),
  //                   ),
  //                 );
  //               }

  //               // เอา intent แรก
  //               final firstIntent = filteredIntents.first;

  //               // invoices เป็น list (หรือว่างถ้าไม่มี)
  //               final intentsInvoices = firstIntent.invoices ?? [];
  //               return ListView.builder(
  //                   physics: const AlwaysScrollableScrollPhysics(),
  //                   shrinkWrap: true,
  //                   itemCount: intentsInvoices.length,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     final intentsInv = intentsInvoices[index];

  //                     // สมมติชนิดเป็น List<Metadata>?
  //                     final List<Metadata> metadata =
  //                         intentsInv.metadata ?? <Metadata>[];

  //                     final Metadata? metaFirst =
  //                         metadata.isNotEmpty ? metadata.first : null;

  //                     final dateInv = metaFirst?.date ?? '';
  //                     final docnoInv = metaFirst?.docno ?? '';
  //                     final totalPvat = metaFirst?.pvatBill ?? 0;
  //                     final totalVat = metaFirst?.vatBill ?? 0;
  //                     final totalWht = metaFirst?.whtBill ?? 0;
  //                     final totalBill = metaFirst?.totalBill ?? 0;
  //                     double _d(dynamic v) {
  //                       final s = (v ?? '0').toString().trim();
  //                       return double.tryParse(s.isEmpty ? '0' : s) ?? 0;
  //                     }

  //                     String _fmtDate(String? iso) {
  //                       try {
  //                         return DateFormat('dd-MM-yyyy').format(
  //                             DateTime.parse('${(iso ?? '').trim()} 00:00:00'));
  //                       } catch (_) {
  //                         return '';
  //                       }
  //                     }

  //                     String _fmtNum(dynamic v) => nFormat.format(_d(v));

  //                     Widget CellDataIntents(
  //                         {required String data,
  //                         required int flexs,
  //                         required TextAlign Align}) {
  //                       return Expanded(
  //                         flex: flexs,
  //                         child: AutoSizeText(
  //                           minFontSize: 10,
  //                           maxFontSize: 15,
  //                           maxLines: 1,
  //                           data,
  //                           textAlign: Align,
  //                           style: const TextStyle(
  //                               color: PeopleChaoScreen_Color.Colors_Text2_,
  //                               //fontWeight: FontWeight.bold,
  //                               fontFamily: Font_.Fonts_T),
  //                         ),
  //                       );
  //                     }

  //                     return Material(
  //                         color: AppbackgroundColor.Sub_Abg_Colors,
  //                         child: Container(
  //                             padding: EdgeInsets.all(4.0),
  //                             // padding: const EdgeInsets.symmetric(
  //                             //     vertical: 8, horizontal: 16),
  //                             decoration: BoxDecoration(
  //                               border: const Border(
  //                                 bottom: BorderSide(
  //                                   color: Colors.black12,
  //                                   width: 1,
  //                                 ),
  //                               ),
  //                             ),
  //                             child: Column(children: [
  //                               Row(children: [
  //                                 Container(
  //                                   width: 50,
  //                                   child: AutoSizeText(
  //                                     minFontSize: 8,
  //                                     maxFontSize: 14,
  //                                     maxLines: 1,
  //                                     '${index + 1}',
  //                                     textAlign: TextAlign.center,
  //                                     overflow: TextOverflow.ellipsis,
  //                                     style: const TextStyle(
  //                                         color: PeopleChaoScreen_Color
  //                                             .Colors_Text2_,
  //                                         fontFamily: Font_.Fonts_T),
  //                                   ),
  //                                 ),
  //                                 CellDataIntents(
  //                                     data: _fmtDate('${dateInv}'),
  //                                     flexs: 1,
  //                                     Align: TextAlign.start),
  //                                 CellDataIntents(
  //                                     data: '${docnoInv}',
  //                                     flexs: 2,
  //                                     Align: TextAlign.start),
  //                                 CellDataIntents(
  //                                     data: _fmtNum('1'),
  //                                     flexs: 1,
  //                                     Align: TextAlign.center),
  //                                 CellDataIntents(
  //                                     data: '-',
  //                                     flexs: 1,
  //                                     Align: TextAlign.center),
  //                                 CellDataIntents(
  //                                     data: _fmtNum('${totalPvat}'),
  //                                     flexs: 1,
  //                                     Align: TextAlign.end),
  //                                 CellDataIntents(
  //                                     data: _fmtNum('${totalVat}'),
  //                                     flexs: 1,
  //                                     Align: TextAlign.end),
  //                                 CellDataIntents(
  //                                     data: _fmtNum('${totalWht}'),
  //                                     flexs: 1,
  //                                     Align: TextAlign.end),
  //                                 CellDataIntents(
  //                                     data: _fmtNum('${totalBill}'),
  //                                     flexs: 1,
  //                                     Align: TextAlign.end),
  //                               ])
  //                             ])));
  //                   });
  //             }),
  //           ])));
  // }

  Widget _buildRightTableHeader() {
    return Container(
      color: const Color(0xFFD7CCC8), // Light brown header background
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: (intentPayedtype == 'invoice')
          ? Row(
              children: const [
                Expanded(
                    flex: 1, child: Text('ลำดับ', textAlign: TextAlign.center)),
                Expanded(
                    flex: 2,
                    child: Text('วันที่', textAlign: TextAlign.center)),
                Expanded(
                    flex: 3,
                    child: Text('รายการ', textAlign: TextAlign.center)),
                Expanded(flex: 1, child: Text('vat', textAlign: TextAlign.end)),
                Expanded(flex: 1, child: Text('wht', textAlign: TextAlign.end)),
                Expanded(flex: 2, child: Text('ยอด', textAlign: TextAlign.end)),
                Expanded(
                    flex: 2, child: Text('ส่วนลด', textAlign: TextAlign.end)),
                Expanded(
                    flex: 2, child: Text('ยอดสุทธิ', textAlign: TextAlign.end)),
                SizedBox(width: 3), // For delete icon
              ],
            )
          : Row(
              children: const [
                Expanded(
                    flex: 1, child: Text('ลำดับ', textAlign: TextAlign.center)),
                Expanded(
                    flex: 2,
                    child: Text('กำหนดชำระ', textAlign: TextAlign.center)),
                Expanded(
                    flex: 3,
                    child: Text('รายการ', textAlign: TextAlign.center)),
                Expanded(
                    flex: 1, child: Text('จำนวน', textAlign: TextAlign.end)),
                Expanded(
                    flex: 2, child: Text('หน่วย', textAlign: TextAlign.end)),
                Expanded(
                    flex: 2, child: Text('ก่อน vat', textAlign: TextAlign.end)),
                Expanded(flex: 1, child: Text('vat', textAlign: TextAlign.end)),
                Expanded(flex: 1, child: Text('wht', textAlign: TextAlign.end)),
                Expanded(
                    flex: 2, child: Text('ยอดสุทธิ', textAlign: TextAlign.end)),
                SizedBox(width: 3), // For delete icon
              ],
            ),
    );
  }

  Widget _buildRightTableRow(int no, String date, String item, int qty,
      String unit, double preVat, double vat, double wht, double net) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text('$no', textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(date, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text(item, textAlign: TextAlign.center)),
          Expanded(flex: 1, child: Text('$qty', textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(unit, textAlign: TextAlign.center)),
          Expanded(
              flex: 2,
              child:
                  Text(preVat.toStringAsFixed(0), textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(vat.toStringAsFixed(0), textAlign: TextAlign.center)),
          Expanded(
              flex: 1,
              child: Text(wht.toStringAsFixed(0), textAlign: TextAlign.center)),
          Expanded(
              flex: 2,
              child: Text(net.toStringAsFixed(0), textAlign: TextAlign.end)),
          const SizedBox(
              width: 40,
              child: Icon(Icons.remove_circle, color: Colors.red, size: 20)),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String step, String title,
      {bool isActive = false, bool isCompleted = false}) {
    final color = (isActive || isCompleted)
        ? const Color(0xFF512DA8)
        : Colors.grey.shade400;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: Font_.Fonts_T,
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: Font_.Fonts_T,
            color: color,
          ),
        ),
        if (isCompleted) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
        ]
      ],
    );
  }

  Widget _buildRightFooter() {
    double _asDouble(String? s) => double.tryParse((s ?? '').trim()) ?? 0.0;

    int _toU16(String? v) =>
        (int.tryParse((v ?? '0').trim()) ?? 0) + 65535; // ✅ logic เดิมคุณ

    String _fmtN(num v) => nFormat.format(v);

    double _discountInput = _asDouble(sum_disamtx.text);

    double _netPayAmount = sum_amt -
        _discountInput -
        dis_sum_Pakan -
        sum_tran_dis -
        dis_sum_Matjum;

    String _fmtDT(DateTime? d) =>
        d == null ? '-' : DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());

    // -------- footer texts --------
    final sumFineTotalFooter = _fmtN(sum_tran_fine);
    final sumPvatFooter = _fmtN(sum_pvat);
    final sumVatFooter = _fmtN(sum_vat);
    final sumWhtFooter = _fmtN(sum_wht);
    final sumTotalFooter = _fmtN(sum_amt - (fine_total + fine_total2));
    final sumDislistFooter = _fmtN(sum_tran_dis);
    final sumAllTotalFooter = _fmtN(_netPayAmount);

    // -------- UI --------

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
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------------- Left note box ----------------
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รายการที่เลือก (${_TransModels.length} รายการ)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: descripTion,
                        readOnly: select_page == 3 ? true : false,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        decoration:
                            InputDecoration.collapsed(hintText: 'หมายเหตุ'),
                        maxLines: 3,
                      ),
                    ),
                    // const SizedBox(height: 8),
                    // paymentSer1 = rowInv.ptser.toString();
                    // paymentName1 = rowInv.ptname.toString();
                    // Text(
                    //   'ธนาคาร : ${paymentName1 ?? "-"}',
                    //   style: TextStyle(
                    //     color: Colors.grey,
                    //     fontFamily: Font_.Fonts_T,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // const Text(
                    //   'เลขที่ : ',
                    //   style: TextStyle(
                    //     color: Colors.grey,
                    //     fontFamily: Font_.Fonts_T,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // ---------------- Right summary / intent card ----------------
              Expanded(
                flex: 6,
                child: (select_page == 3)
                    ? Builder(
                        builder: (context) {
                          final String targetUuid = '$numinvoice';

                          final filteredIntents = paymentIntents
                              .where((p) => p.uuid == targetUuid)
                              .toList();

                          if (filteredIntents.isEmpty) {
                            return Container(
                              height: 165,
                              width: (Responsive.isDesktop(context))
                                  ? MediaQuery.of(context).size.width * 0.52
                                  : 600,
                              decoration: const BoxDecoration(
                                color: AppbackgroundColor.Sub_Abg_Colors,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: const SizedBox.shrink(),
                            );
                          }

                          final firstIntent = filteredIntents.first;

                          final bankId = firstIntent.bankmerchantid ?? 0;
                          final bankItem = _PayMentModels.firstWhere(
                            (p) => p.ser.toString() == '$bankId',
                            orElse: () => PayMentModel(
                              ser: '-',
                              bname: '-',
                              bno: '-',
                            ),
                          );

                          final paybname = bankItem.bname;
                          final paybno = bankItem.bno;

                          final intentStatusThai =
                              firstIntent.statusExtended?.statusThai ?? '-';

                          final intentSoftExpireAt =
                              _fmtDT(firstIntent.softExpireAt);
                          final intentCreatedAt = _fmtDT(firstIntent.createdAt);
                          final intentUpdatedAt = _fmtDT(firstIntent.updatedAt);

                          final amountIntents = firstIntent.amount ?? 0;
                          final AiscountAmountIntents =
                              firstIntent.discountAmount ?? 0;

                          return Column(children: [
                            // _buildSummaryRow('ประเภท', paymentName1 ?? ""),
                            _buildSummaryRow('ธนาคาร', '$paybname'),
                            _buildSummaryRow('เลขที่บัญชี', '$paybno'),
                            _buildSummaryRow('วันที่สร้าง', intentCreatedAt),
                            _buildSummaryRow(
                                'วันที่หมดอายุ', intentSoftExpireAt),

                            // _buildSummaryRow('วันที่อัพเดต', intentUpdatedAt),
                            _buildSummaryRow(
                                'ส่วนลด', _fmtN(AiscountAmountIntents)),
                            _buildSummaryRow('ยอดชำระ', _fmtN(amountIntents)),
                          ]);
                        },
                      )
                    : Column(
                        children: [
                          _buildSummaryRow('ค่าปรับ', sumFineTotalFooter),
                          _buildSummaryRow('รวม', sumPvatFooter),
                          _buildSummaryRow(
                              'ภาษีมูลค่าเพิ่ม(vat)', sumVatFooter),
                          _buildSummaryRow('หัก ณ ที่จ่าย', sumWhtFooter),
                          _buildSummaryRow('ยอดรวม', sumTotalFooter),
                          // _buildSummaryRow('ส่วนลดรายการ', sumDislistFooter),

                          // ---------------- เงินประกัน ----------------
                          if (widget.can == 'C') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (transKonModels.isNotEmpty)
                                        ? 'เงินประกัน (ไม่มียอดคงเหลือ)'
                                        : 'เงินประกัน (${_fmtN(sum_Pakan)})',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 80,
                                  height: 24,
                                  child: _Pakan == 1
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              Form_payment1.clear();

                                              if (dis_Pakan == 1) {
                                                dis_Pakan = 0;
                                                dis_sum_Pakan = 0.00;
                                              } else {
                                                dis_Pakan = 1;
                                                if (sum_Pakan < sum_amt) {
                                                  dis_sum_Pakan = sum_Pakan;
                                                } else {
                                                  dis_sum_Pakan =
                                                      sum_amt - sum_disamt;
                                                }
                                              }

                                              Form_payment1.text = (sum_amt -
                                                      sum_disamt -
                                                      dis_sum_Pakan -
                                                      sum_tran_dis -
                                                      dis_sum_Matjum)
                                                  .toStringAsFixed(2);
                                            });
                                          },
                                          icon: Icon(
                                            dis_Pakan == 1
                                                ? Icons.done
                                                : Icons.close,
                                            color: dis_Pakan == 1
                                                ? Colors.green
                                                : Colors.black,
                                          ),
                                        )
                                      : const Icon(Icons.close,
                                          color: Colors.red),
                                ),
                              ],
                            ),
                          ],

                          // ---------------- เงินมัดจำ ----------------
                          if (_matjum != 0) ...[
                            SizedBox(
                              height: 35,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'เงินมัดจำ (${_fmtN(sum_matjum)})',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 4),
                                        Builder(builder: (_) {
                                          final hasMatjum =
                                              transMatjumModels.isNotEmpty;
                                          final matjumIsZero = (_asDouble(
                                                  _fmtN(sum_matjum)
                                                      .replaceAll(',', '')) ==
                                              0);

                                          if (!hasMatjum || matjumIsZero) {
                                            return const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: Icon(Icons.close,
                                                  color: Colors.red),
                                            );
                                          }

                                          return SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Center(
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                iconSize: 18,
                                                icon: Icon(
                                                  dis_matjum == 1
                                                      ? Icons.done
                                                      : Icons.close,
                                                  color: dis_matjum == 1
                                                      ? Colors.green
                                                      : Colors.black,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    Form_payment1.clear();

                                                    if (dis_matjum == 1) {
                                                      dis_matjum = 0;
                                                      dis_sum_Matjum = 0.00;
                                                    } else {
                                                      dis_matjum = 1;
                                                      if (sum_matjum <
                                                          sum_amt) {
                                                        dis_sum_Matjum =
                                                            sum_matjum -
                                                                sum_tran_dis;
                                                      } else {
                                                        dis_sum_Matjum =
                                                            sum_amt -
                                                                sum_disamt -
                                                                sum_tran_dis;
                                                      }
                                                    }

                                                    Form_payment1.text =
                                                        (sum_amt -
                                                                sum_disamt -
                                                                dis_sum_Pakan -
                                                                sum_tran_dis -
                                                                dis_sum_Matjum)
                                                            .toStringAsFixed(2);
                                                  });
                                                },
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dis_sum_Matjum == 0.00
                                          ? _fmtN(dis_sum_Matjum)
                                          : '(ตัดมัดจำ) ${_fmtN(dis_sum_Matjum)}',
                                      textAlign: TextAlign.end,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 4),

                          // ---------------- ส่วนลด ----------------
                          Row(
                            children: [
                              const Expanded(
                                child: Text('ส่วนลด(ท้ายบิล)',
                                    style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                height: 24,
                                child: TextField(
                                  controller: sum_disamtx,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.end,
                                  readOnly: (select_page == 0) ? false : true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 0),
                                  ),
                                  onChanged: (value) async {
                                    final totalFooter = _netPayAmount;
                                    final valuenum = _asDouble(value);

                                    setState(() {
                                      if (value.isEmpty) {
                                        sum_disamtx.text = '0.00';
                                      } else if (_asDouble(value) >
                                          totalFooter) {
                                        sum_disamtx.text = '0.00';
                                      } else {
                                        sum_disamtx.text = valuenum.toString();
                                        sum_dis = valuenum;
                                        sum_disamt = valuenum;
                                        sum_dispx.clear();
                                        Form_payment1.text =
                                            _netPayAmount.toStringAsFixed(2);
                                      }
                                    });
                                  },
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9 .]')),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: Font_.Fonts_T,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          _buildSummaryRow('ยอดชำระ', sumAllTotalFooter,
                              isTotal: true),
                        ],
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ---------------- Pay Now ----------------
          if (select_page == 0) ...[
            // ---------------- Step 1: Select Payment ----------------
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepHeader('1', 'เลือกรูปแบบชำระ',
                      isActive: true, isCompleted: selectedPaymentKey != null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          value: selectedPaymentKey,
                          isExpanded: true,
                          dropdownMaxHeight: 300,
                          hint: Text(
                            'กรุณาเลือกวิธีการชำระเงิน',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: Colors.black54),
                          buttonHeight: 40,
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          items: _PayMentModels.map(
                              (it) => DropdownMenuItem<String>(
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
                              paymentName1 = (ser == '0') ? null : name;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ---------------- Step 2: Confirm Intent ----------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepHeader('2', 'ยืนยันสร้างรายการ',
                      isActive: selectedPaymentKey != null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: (selectedPaymentKey == null ||
                                _TransModels.any((A) => paymentIntents.any(
                                    (pi) => pi.invoices.any((inv) =>
                                        inv.metadata.any((m) =>
                                            m.docno == A.docno &&
                                            m.date == A.date)))))
                            ? null
                            : () async {
                                try {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  );
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final ren = prefs.getString('renTalSer');

                                  // ✅ 16-bit unsigned (0..65535) ตามที่คุยไว้ก่อนหน้า
                                  String? custno16Bit;
                                  final ren16Bit = _toU16('$ren');

                                  final All_lateFee =
                                      double.tryParse(Form_fine.text) ?? 0.0;
                                  final All_discountAmount =
                                      double.tryParse(sum_disamtx.text) ?? 0.0;
                                  final All_depositAmount = sum_matjum;
                                  final All_insuranceAmount = sum_Pakan;
                                  final All_withholdingAmount = sum_wht;
                                  var ciddoc = widget.Get_Value_cid;

                                  final invs =
                                      _TransModels.map<Map<String, dynamic>>(
                                          (b) {
                                    final docno = '${b.docno ?? ''}';
                                    final totalBill =
                                        double.tryParse('${b.total ?? 0}') ??
                                            0.0;
                                    final totalVatDislist = double.tryParse(
                                            '${b.vat_dislit ?? 0}') ??
                                        0.0;
                                    final totalDislist =
                                        double.tryParse('${b.dis_list ?? 0}') ??
                                            0.0;

                                    final cid = '${b.refno ?? ''}';
                                    final custnoLocal = '${b.custno ?? ''}';
                                    final st = '${b.st ?? ''}';
                                    final expname = '${b.expname ?? ''}';

                                    final dateVal = (b.date is DateTime)
                                        ? (b.date as DateTime).toIso8601String()
                                        : b.date;
                                    setState(() {
                                      custno16Bit =
                                          _toU16('$custnoLocal').toString();
                                    });

                                    final List<Map<String, dynamic>> listFine =
                                        transFineModels
                                                .where((e) =>
                                                    e.docno.toString() ==
                                                    docno.toString())
                                                .map<Map<String, dynamic>>((f) {
                                              final double fineTotal =
                                                  double.tryParse(
                                                          '${f.total ?? 0}') ??
                                                      0.0;

                                              return {
                                                "docno": f.docno,
                                                "expname": f.expname,
                                                "expser": int.tryParse(
                                                        '${f.expser ?? 0}') ??
                                                    0,
                                                "no": int.tryParse(
                                                        '${f.no ?? 0}') ??
                                                    0,
                                                "pvat": double.tryParse(
                                                        '${f.pvat ?? 0}') ??
                                                    0.0,
                                                "vser": int.tryParse(
                                                        '${f.vser ?? 0}') ??
                                                    0,
                                                "vtype": f.vtype ?? '',
                                                "nvat": int.tryParse(
                                                        '${f.nvat ?? 0}') ??
                                                    0,
                                                "vat": double.tryParse(
                                                        '${f.vat ?? 0}') ??
                                                    0.0,
                                                "wht": double.tryParse(
                                                        '${f.wht ?? 0}') ??
                                                    0.0,
                                                "total":
                                                    fineTotal, // ✅ ใช้ของ f
                                              };
                                            }).toList() ??
                                            []; // ✅ สำคัญมาก

                                    final List<Map<String, dynamic>>
                                        metadataList = [
                                      {
                                        'expname': expname,
                                        'docno': docno,
                                        'date': (b.date is DateTime)
                                            ? (b.date as DateTime)
                                                .toIso8601String()
                                            : b.date,
                                        'cid': '${b.refno ?? ''}',
                                        // 'custno': custnoLocal,
                                        // 'st': '${b.st ?? ''}',
                                        // 'status': '',
                                        'payser':
                                            int.tryParse('$paymentSer1') ?? 0,
                                        // 'docno_all':
                                        //     _TransModels.map((m) => m.docno)
                                        //         .toSet()
                                        //         .join(','),
                                        'pri_bill':
                                            double.tryParse('${b.pri ?? 0}') ??
                                                0.0,
                                        'pvat_bill':
                                            double.tryParse('${b.pvat ?? 0}') ??
                                                0.0,
                                        'vat_bill':
                                            double.tryParse('${b.vat ?? 0}') ??
                                                0.0,
                                        'wht_bill':
                                            double.tryParse('${b.wht ?? 0}') ??
                                                0.0,
                                        'late_fee': 0,
                                        'list_fee': [],
                                        // 'list_fee': listFine,
                                        'vat_dis_lis': totalVatDislist,
                                        'dis_lis': totalDislist,
                                        'total_bill': totalBill,
                                        'selected': docno,
                                        // _TransModels.map((m) => m.docno)
                                        //     .toSet()
                                        //     .join(','),
                                      }
                                    ];

                                    return {
                                      "invoice_id": 0,
                                      "bill_reference": docno,
                                      "amount": metadataList.fold(
                                          0.0,
                                          (sum, e) =>
                                              sum +
                                              (e['pvat_bill'] as double? ?? 0)),
                                      "late_fee": listFine.fold(
                                          0.0,
                                          (sum, e) =>
                                              sum +
                                              (e['total'] as num? ?? 0)
                                                  .toDouble()),
                                      "vat_amount": metadataList.fold(
                                          0.0,
                                          (sum, e) =>
                                              sum +
                                              (e['vat_bill'] as double? ?? 0)),
                                      "discount_amount": 0.0,
                                      "deposit_amount": 0.0,
                                      "insurance_amount": 0.0,
                                      "withholding_amount": metadataList.fold(
                                          0.0,
                                          (sum, e) =>
                                              sum +
                                              (e['wht_bill'] as double? ?? 0)),
                                      "total": metadataList.fold(
                                          0.0,
                                          (sum, e) =>
                                              sum +
                                              (e['total_bill'] as double? ??
                                                  0)),
                                      'list_fee': listFine,
                                      "metadata": metadataList,
                                    };
                                  }).toList();
                                  // print({
                                  //   'cusNo': custno16Bit.toString(),
                                  //   'propertyNo': ren16Bit.toString(),
                                  //   'payedType': "service",
                                  //   'payser': int.tryParse('$paymentSer1') ?? 0,
                                  //   'typepayser':
                                  //       int.tryParse('$payment_ptSer1') ?? 0,
                                  //   'requestedAmount':
                                  //       _netPayAmount, // ✅ ไม่ใช้ string format
                                  //   'lateFee': All_lateFee,
                                  //   "condition_fee": [
                                  //     {
                                  //       "cid": "$ciddoc",
                                  //       "is_fee": IsFinContrac,
                                  //       "mindate": '${minDate}',
                                  //       // "maxdate": '${maxDate}',
                                  //     }
                                  //   ],
                                  //   'discountAmount': All_discountAmount,
                                  //   'depositAmount': All_depositAmount,
                                  //   'insuranceAmount': All_insuranceAmount,
                                  //   'withholdingAmount': All_withholdingAmount,

                                  //   'inVoices': invs,
                                  //   'transselect':
                                  //       _TransModels.map((e) => e.toJson())
                                  //           .toList(),
                                  // });

                                  // requestedAmount ใช้ยอดสุทธิรวมทั้งชุด (ตัวเลขดิบ)
                                  await PostPaymentIntents(
                                    cusNo: custno16Bit.toString(),
                                    propertyNo: ren16Bit.toString(),
                                    payedType: "service",
                                    payser: int.tryParse('$paymentSer1') ?? 0,
                                    typepayser:
                                        int.tryParse('$payment_ptSer1') ?? 0,
                                    requestedAmount:
                                        _netPayAmount, // ✅ ไม่ใช้ string format
                                    lateFee: All_lateFee,
                                    discountAmount: All_discountAmount,
                                    depositAmount: All_depositAmount,
                                    insuranceAmount: All_insuranceAmount,
                                    withholdingAmount: All_withholdingAmount,

                                    inVoices: invs,
                                    transselect:
                                        _TransModels.map((e) => e.toJson())
                                            .toList(),
                                  );
                                } catch (e) {
                                } finally {
                                  if (mounted) {
                                    Navigator.of(context).pop();
                                  }
                                  _resetToInitialState(
                                      targetPage: 0, billAll: false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (selectedPaymentKey != null)
                              ? const Color(0xFF512DA8)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: (selectedPaymentKey != null) ? 2 : 0,
                        ),
                        child: Text(
                          _TransModels.any((A) => paymentIntents.any((pi) => pi
                                  .invoices
                                  .any((inv) => inv.metadata.any((m) =>
                                      m.docno == A.docno && m.date == A.date))))
                              ? 'ถูกสร้างรายการรอชำระไปแล้ว'
                              : 'รับชำระทันที $sum_tran_dis',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (select_page == 1) ...[
            // ---------------- Step 1: Select Payment ----------------
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepHeader('1', 'เลือกรูปแบบชำระ',
                      isActive: true, isCompleted: selectedPaymentKey != null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          value: selectedPaymentKey,
                          isExpanded: true,
                          dropdownMaxHeight: 300,
                          hint: Text(
                            'กรุณาเลือกวิธีการชำระเงิน',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          icon: null,
                          buttonHeight: 40,
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          items: _PayMentModels.map(
                              (it) => DropdownMenuItem<String>(
                                    value: '${it.ser}:${it.ptname}',
                                    child: _tile(it),
                                  )).toList(),
                          selectedItemBuilder: (_) =>
                              _PayMentModels.map(_tile).toList(),
                          onChanged: null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ---------------- Step 2: Confirm Intent ----------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepHeader('2', 'ยืนยันสร้างรายการ',
                      isActive: selectedPaymentKey != null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                            );
                            final prefs = await SharedPreferences.getInstance();
                            final ren = prefs.getString('renTalSer');

                            final ren16Bit = _toU16('$ren').toString();

                            // custno ใช้ตัวเดียว (ทุก invoice ลูกค้าเดียวกัน)
                            final String custnoLocal = _InvoiceHistoryModels
                                    .isNotEmpty
                                ? '${_InvoiceHistoryModels.first.custno ?? ''}'
                                : '';

                            final custno16Bit = _toU16(custnoLocal).toString();

                            final docnosSelected =
                                _InvoiceHistoryModels.map((m) => m.docno)
                                    .toSet()
                                    .join(',');
                            final All_lateFee =
                                double.tryParse(Form_fine.text) ?? 0.0;
                            final All_discountAmount =
                                double.tryParse(sum_disamtx.text) ?? 0.0;
                            final All_depositAmount = sum_matjum;
                            final All_insuranceAmount = sum_Pakan;
                            final All_withholdingAmount = sum_wht;

                            final sumAllTotal = _netPayAmount;
                            final invFine = await GC_Inv_fine(
                                docno: docnosSelected.toString());
                            final double fineTotal =
                                (invFine['total'] as num?)?.toDouble() ?? 0.0;

                            final List<Map<String, dynamic>> listFineINV =
                                (invFine['ok'] == true && fineTotal > 0)
                                    ? [
                                        {
                                          "docno": docnosSelected,
                                          "expser": int.tryParse(
                                                  '${invFine['expser'] ?? 0}') ??
                                              0,
                                          "expname": invFine['expname'] ??
                                              "ชำระเกินกำหนด",
                                          "no": int.tryParse(
                                                  '${invFine['no'] ?? 0}') ??
                                              0,
                                          "pvat": (invFine['pvat'] as num?)
                                                  ?.toDouble() ??
                                              0.0,
                                          "vser": int.tryParse(
                                                  '${invFine['vser'] ?? 0}') ??
                                              0,
                                          "vtype": invFine['vtype'] ?? '',
                                          "nvat": (invFine['nvat'] as num?)
                                                  ?.toInt() ??
                                              0,
                                          "vat": (invFine['vat'] as num?)
                                                  ?.toDouble() ??
                                              0.0,
                                          "wht": (invFine['wht'] as num?)
                                                  ?.toDouble() ??
                                              0.0,
                                          "total": fineTotal,
                                        }
                                      ]
                                    : [];
                            // ---------- metadata ----------
                            final List<Map<String, dynamic>> metadataList =
                                _InvoiceHistoryModels.map<Map<String, dynamic>>(
                                    (b) {
                              final docno = '${b.docno ?? ''}';
                              final refno = '${b.refno ?? ''}';
                              final expname = '${b.expname ?? ''}';
                              final totalBill =
                                  double.tryParse('${b.total ?? 0}') ?? 0.0;
                              final List<Map<String, dynamic>> listFine =
                                  []; // ✅ สำคัญมาก
                              return {
                                'expname': expname,
                                'docno': refno,
                                'date': (b.date is DateTime)
                                    ? (b.date as DateTime).toIso8601String()
                                    : b.date,
                                'cid': '${b.cid ?? ''}',
                                // 'custno': custnoLocal,
                                // 'st': '${b.st ?? ''}',
                                // 'status': '',
                                'payser': int.tryParse('$paymentSer1') ?? 0,
                                // 'docno_all': docnosSelected,
                                'pri_bill':
                                    double.tryParse('${b.pri ?? 0}') ?? 0.0,
                                'pvat_bill':
                                    double.tryParse('${b.pvat ?? 0}') ?? 0.0,
                                'vat_bill':
                                    double.tryParse('${b.vat ?? 0}') ?? 0.0,
                                'wht_bill':
                                    double.tryParse('${b.wht ?? 0}') ?? 0.0,
                                'late_fee': 0,
                                'list_fee': listFine,
                                'total_bill': totalBill,
                                'selected': docnosSelected,
                              };
                            }).toList();

                            // ---------- invoices ----------
                            final invs = [
                              {
                                "invoice_id": 0,
                                "bill_reference": docnosSelected,
                                "amount": metadataList.fold(
                                    0.0,
                                    (sum, e) =>
                                        sum + (e['pvat_bill'] as double? ?? 0)),
                                "late_fee": listFineINV.fold(
                                    0.0,
                                    (sum, e) =>
                                        sum +
                                        (e['total'] as num? ?? 0).toDouble()),
                                "vat_amount": metadataList.fold(
                                    0.0,
                                    (sum, e) =>
                                        sum + (e['vat_bill'] as double? ?? 0)),
                                "discount_amount": All_discountAmount,
                                "deposit_amount": 0.0,
                                "insurance_amount": 0.0,
                                "withholding_amount": metadataList.fold(
                                    0.0,
                                    (sum, e) =>
                                        sum + (e['wht_bill'] as double? ?? 0)),
                                "total": metadataList.fold(
                                            0.0,
                                            (sum, e) =>
                                                sum +
                                                (e['total_bill'] as double? ??
                                                    0)) -
                                        All_discountAmount ??
                                    0,
                                "list_fee": listFineINV, // ✅ ใส่ตรงนี้
                                "metadata": metadataList,
                              }
                            ];

                            await PostPaymentIntents(
                              cusNo: custno16Bit,
                              propertyNo: ren16Bit,
                              payedType: "invoice",
                              payser: int.tryParse('$paymentSer1') ?? 0,
                              typepayser: int.tryParse('$payment_ptSer1') ?? 0,
                              requestedAmount:
                                  _netPayAmount, // ✅ ไม่ใช้ string format
                              lateFee: All_lateFee,
                              discountAmount: All_discountAmount,
                              depositAmount: All_depositAmount,
                              insuranceAmount: All_insuranceAmount,
                              withholdingAmount: All_withholdingAmount,
                              inVoices: invs,
                              transselect:
                                  _InvoiceHistoryModels.map((e) => e.toJson())
                                      .toList(),
                            );
                          } catch (e) {
                          } finally {
                            if (mounted) {
                              Navigator.of(context).pop();
                            }
                            await _resetToInitialState(
                                targetPage: 1, billAll: false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (selectedPaymentKey != null)
                              ? const Color(0xFF512DA8)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          elevation: (selectedPaymentKey != null) ? 2 : 0,
                        ),
                        child: Text(
                          _InvoiceHistoryModels.any((A) => paymentIntents.any(
                                  (pi) => pi.invoices.any((inv) => inv.metadata
                                      .any((m) =>
                                          m.docno == A.docno &&
                                          m.date == A.date))))
                              ? 'ถูกสร้างรายการรอชำระไปแล้ว'
                              : 'รับชำระทันที ',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (select_page == 3) ...[
            // ---------------- Step 1: Select Payment ----------------
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildStepHeader('1', 'เลือกรูปแบบชำระ',
                      isActive: true, isCompleted: selectedPaymentKey != null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          value: selectedPaymentKey,
                          isExpanded: true,
                          dropdownMaxHeight: 300,
                          hint: Text(
                            'กรุณาเลือกวิธีการชำระเงิน',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          icon: null,
                          buttonHeight: 40,
                          dropdownDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          items: _PayMentModels.map(
                              (it) => DropdownMenuItem<String>(
                                    value: '${it.ser}:${it.ptname}',
                                    child: _tile(it),
                                  )).toList(),
                          selectedItemBuilder: (_) =>
                              _PayMentModels.map(_tile).toList(),
                          onChanged: null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ---------------- Step 2: Confirm Intent ----------------
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildStepHeader('2', 'ยืนยันสร้างรายการ',
                      isActive: selectedPaymentKey != null),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (numinvoice != null &&
                          numinvoice != 'null' &&
                          numinvoice != '') ...[
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (numinvoice == null ||
                                      numinvoice == 'null' ||
                                      numinvoice == '')
                                  ? null
                                  : () async {
                                      if (_tapBusy) return;
                                      if (!mounted) return;

                                      setState(() => _tapBusy = true);

                                      try {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        final ren =
                                            prefs.getString('renTalSer');

                                        final ren16Bit =
                                            _toU16('$ren').toString();
                                        final custno16Bit = intentsCustno
                                            .toString(); // คุณมีอยู่แล้ว
                                        final intentsUuid =
                                            numinvoice.toString();

                                        final response =
                                            await DeletePaymentIntents_UuidCanceled(
                                          cusNo: custno16Bit,
                                          propertyNo: ren16Bit,
                                          intentsUuid: intentsUuid,
                                          bankMerchantId:
                                              int.tryParse('$paymentSer1') ?? 0,
                                        );

                                        // ✅ ถ้าจะ refresh list / clear state ทำตรงนี้
                                        if (response != null &&
                                            response.statusCode >= 200 &&
                                            response.statusCode < 300) {
                                          // ตัวอย่าง: รีโหลด intents / ล้าง numinvoice / แจ้งเตือน
                                          await redPaymentIntents();
                                          setState(() => numinvoice = '');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content:
                                                    Text('ยกเลิกรายการสำเร็จ')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'ยกเลิกรายการไม่สำเร็จ')),
                                          );
                                        }
                                      } catch (e) {
                                        // ✅ ถ้ามี error จริงค่อยแจ้ง
                                        // debugPrint('Cancel error: $e');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('เกิดข้อผิดพลาด: $e')),
                                        );
                                      } finally {
                                        await Future.delayed(
                                            const Duration(milliseconds: 300));
                                        if (mounted)
                                          setState(() => _tapBusy = false);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text(
                                'ยกเลิกรายการ',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                      ],
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            // Disable ถ้าไม่มี numinvoice
                            onPressed: (numinvoice == null ||
                                    numinvoice == 'null' ||
                                    numinvoice == '')
                                ? null
                                : () async {
                                    if (_tapBusy) return;
                                    if (!mounted) return;

                                    setState(() => _tapBusy = true);

                                    try {
                                      // เปิด QR sheet - จะแสดง QR หรือหลักฐานการชำระขึ้นอยู่กับข้อมูล
                                      await _openQrSheet();
                                    } catch (e) {
                                      debugPrint('Open QR error: $e');
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content:
                                                Text('เกิดข้อผิดพลาด: $e')),
                                      );
                                    } finally {
                                      await Future.delayed(
                                          const Duration(milliseconds: 300));
                                      if (mounted)
                                        setState(() => _tapBusy = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              // เปลี่ยนข้อความปุ่มตามว่ามีหลักฐานหรือไม่
                              (intentsAttacheSlipNo != null &&
                                      intentsAttacheSlipNo != '')
                                  ? 'พบหลักฐานการชำระ'
                                  : 'แสดง QR CODE',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 14 : 12,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? 14 : 12,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

// ----------------------
// UI layer caller
// ----------------------
  int? bankMerchantId;
  String? ref1 = '', ref2 = '', ref3 = '';
  Future<void> PostPaymentIntents(
      {required String cusNo,
      required String propertyNo,
      required String payedType,
      required int payser,
      required int typepayser,
      required double requestedAmount,
      required double lateFee,
      required double discountAmount,
      required double depositAmount,
      required double insuranceAmount,
      required double withholdingAmount,
      required List<Map<String, dynamic>> inVoices,
      required List<Map<String, dynamic>> transselect}) async {
    debugPrint('🔄 เรียกใช้งาน PostPaymentIntents()');

    final response = await postPaymentIntents(
        cusNo: cusNo,
        propertyNo: propertyNo,
        payedType: payedType,
        chanNel: "testerx",
        requestedAmount: requestedAmount,
        lateFee: lateFee,
        discountAmount: discountAmount,
        depositAmount: depositAmount,
        insuranceAmount: insuranceAmount,
        withholdingAmount: withholdingAmount,
        // createdById: "10101010101010",
        isAdminCreated: true,
        bankMerchantId: payser,
        bankMerchantType: typepayser,
        descripTion: descripTion.text ?? "",
        inVoices: inVoices,
        transSelect: transselect);

    if (response == null) {
      debugPrint('❌ ไม่มี response จาก server');
      return;
    }

    try {
      final jsonRes = json.decode(response.body);
      debugPrint('🧾 Raw JSON: $jsonRes');

      // TODO: map ค่าที่ต้องใช้จริงจาก jsonRes
      setState(() {
        bankMerchantId = 0;
        ref1 = '';
        ref2 = '';
        ref3 = '';
      });
    } catch (e, stack) {
      debugPrint('❌ Exception parsing payment intents: $e');
      debugPrint('🧭 StackTrace:\n$stack');
    }
  }

  final GlobalKey qrBlockKey = GlobalKey();

  // ===== Web-only saver (kept inside function to avoid import crash on mobile) =====
  Future<void> downloadWidgetAsPng(
    GlobalKey key, {
    String fileName = 'QRPAY.png',
  }) async {
    // รอให้เฟรมวาดเสร็จก่อน เผื่อ boundary ยังไม่พร้อม
    await WidgetsBinding.instance.endOfFrame;

    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || key.currentContext == null) return;

    // 🎯 ใช้ DPR ของ context ปัจจุบัน (สำคัญมากบน Web-HTML)
    final dpr = MediaQuery.devicePixelRatioOf(key.currentContext!);

    // สร้างภาพด้วย DPR ที่ถูกต้อง
    final image = await boundary.toImage(pixelRatio: dpr);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final pngBytes = byteData.buffer.asUint8List();

    final blob = html.Blob([pngBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> shareWidgetAsPng(
    GlobalKey key, {
    String fileName = 'QRPAY.png',
  }) async {
    // 1. รอให้ Render พร้อม
    await WidgetsBinding.instance.endOfFrame;
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null || key.currentContext == null) return;

    // 2. แปลง Widget เป็น Image (Uint8List)
    final dpr = MediaQuery.devicePixelRatioOf(key.currentContext!);
    final image = await boundary.toImage(pixelRatio: dpr);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;
    final pngBytes = byteData.buffer.asUint8List();

    // 3. สร้าง File Object สำหรับ Web Share API
    final blob = html.Blob([pngBytes], 'image/png');
    final file = html.File([blob], fileName, {'type': 'image/png'});

    // 4. เช็คความสามารถของ Browser (navigator.canShare)
    // หมายเหตุ: canShare อาจจะไม่มีในบาง Browser เก่าๆ ต้อง try-catch
    try {
      final dynamic navigator = html.window.navigator;
      if (navigator.canShare({
        'files': [file]
      })) {
        await html.window.navigator.share({
          'files': [file],
          'title': 'Thai QR Payment',
          'text': 'Scan to pay'
        });
      } else {
        // Fallback: ถ้าแชร์ไม่ได้ ให้ดาวน์โหลดแทน
        await downloadWidgetAsPng(key, fileName: fileName);
      }
    } catch (e) {
      // กรณีเกิด Error หรือ User Cancel หรือ Browser ไม่รองรับ
      debugPrint('Share failed: $e');
      // Fallback: ดาวน์โหลดแทน
      await downloadWidgetAsPng(key, fileName: fileName);
    }
  }

  Widget _ghostBtn(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12, width: .7),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.black87),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _solidBtn(
      {required Color color,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(.28),
                blurRadius: 16,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontFamily: Font_.Fonts_T,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Future<bool> _renewQrAndReload() async {
    int _toU16(String? v) =>
        (int.tryParse((v ?? '0').trim()) ?? 0) + 65535; // ✅ logic เดิมคุณ

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');

      final ren16Bit = _toU16('$ren').toString();
      final custno16Bit = intentsCustno.toString(); // คุณมีอยู่แล้ว
      final intentsUuid = numinvoice.toString();

      // final respDetails = await getDetailsPaymentIntents(
      //   cusNo: custno16Bit,
      //   propertyNo: ren16Bit,
      //   intentsUuid: intentsUuid,
      // );
      // if (respDetails.statusCode == 200) {
      //   setState(() {});
      // }
      final resp = await postGeneratePaymentIntents(
        cusNo: custno16Bit,
        propertyNo: ren16Bit,
        intentsUuid: intentsUuid,
        bankMerchantId: int.tryParse('$paymentSer1') ?? 0,
      );

      if (resp == null || resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('renew fail: ${resp?.statusCode} ${resp?.body}');
        return false;
      }

      final root = json.decode(resp.body);
      debugPrint('🟢 QR Generate Response: $root');
      setState(() {
        qr_expiresAt = root['soft_expire_at'] ?? root['expires_at']; // ISO8601
        return_qr_refapi1 = root['ref1'];
        return_qr_refapi2 = root['ref2'];
        return_qr_refapi3 = root['ref3'];
        qr_payload = root['payload'] ?? ''; // Add payload
      });
      return true;
    } catch (e, st) {
      debugPrint('renew exception: $e\n$st');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _DetailsPaymentIntentsReload() async {
    int _toU16(String? v) =>
        (int.tryParse((v ?? '0').trim()) ?? 0) + 65535; // ✅ logic เดิมคุณ

    try {
      final prefs = await SharedPreferences.getInstance();
      final ren = prefs.getString('renTalSer');

      final ren16Bit = _toU16('$ren').toString();
      final custno16Bit = intentsCustno.toString(); // คุณมีอยู่แล้ว
      final intentsUuid = numinvoice.toString();

      final resp = await getDetailsPaymentIntents(
        cusNo: custno16Bit,
        propertyNo: ren16Bit,
        intentsUuid: intentsUuid,
      );

      if (resp == null || resp.statusCode < 200 || resp.statusCode >= 300) {
        debugPrint('❌ getDetailsPaymentIntents failed: ${resp?.statusCode}');
        return null;
      }

      final root = json.decode(resp.body);
      debugPrint('🟢 DetailsPaymentIntent Response: $root');
      return root['data'] as Map<String, dynamic>?;
    } catch (e, st) {
      debugPrint('❌ DetailsPaymentIntents exception: $e\n$st');
      return null;
    }
  }

  Future<void> _openQrSheet() async {
    print("_openQrSheet");
    String _fmtDT(DateTime? d) =>
        d == null ? '-' : DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
    final String targetUuid = '$numinvoice';

    final filteredIntents =
        paymentIntents.where((p) => p.uuid == targetUuid).toList();

    final firstIntent = filteredIntents.first;

    final bankId = firstIntent.bankmerchantid ?? 0;
    final bankItem = _PayMentModels.firstWhere(
      (p) => p.ser.toString() == '$bankId',
      orElse: () => PayMentModel(
        ser: '-',
        bname: '-',
        bno: '-',
      ),
    );

    final paybname = bankItem.bname;
    final paybno = bankItem.bno;
    final payptser = bankItem.ptser;
    final payser = bankItem.ser;
    final payimg = bankItem.img;

    final intentStatusThai = firstIntent.statusExtended?.statusThai ?? '-';

    final intentSoftExpireAt = _fmtDT(firstIntent.softExpireAt);
    final intentCreatedAt = _fmtDT(firstIntent.createdAt);
    final intentUpdatedAt = _fmtDT(firstIntent.updatedAt);

    final amountIntents = firstIntent.amount ?? 0;

    // ✅ ตั้งค่า qr_expiresAt จาก intent ที่มีอยู่ (ถ้ามี) เพื่อป้องกันการสร้าง QR ซ้ำ
    if (firstIntent.softExpireAt != null) {
      qr_expiresAt = firstIntent.softExpireAt!.toIso8601String();
    }

    // ---------- 0) ถ้ายังไม่มี QR ให้สร้างครั้งแรก ----------
    final dData = await _DetailsPaymentIntentsReload();

    // Store uploaded slip data if exists
    if (dData != null && dData['attaches'] != null) {
      _uploadedSlipData = dData['attaches'] as Map<String, dynamic>;
      debugPrint('📎 พบหลักฐานการชำระ: ${_uploadedSlipData!['slip_no']}');
      debugPrint('📎 ข้อมูล attaches: $_uploadedSlipData');
    } else {
      _uploadedSlipData = null;
      debugPrint('📎 ไม่พบหลักฐานการชำระ');
    }

    // ✅ ถ้ามี active_qr_session อยู่แล้ว ให้โหลดข้อมูลมาใช้
    if (dData != null && dData['active_qr_session'] != null) {
      debugPrint('🔄 มี active_qr_session → โหลดข้อมูล QR ที่มีอยู่');
      final qrSession = dData['active_qr_session'] as Map<String, dynamic>;

      final ref1 = qrSession['ref1'] as String?;
      final ref2 = qrSession['ref2'] as String?;
      final ref3 = qrSession['ref3'] as String?;
      debugPrint('✅ โหลด QR Session: ref1=$ref1, ref2=$ref2, ref3=$ref3');

      return_qr_refapi1 = ref1;
      return_qr_refapi2 = ref2;
      return_qr_refapi3 = ref3;

      final expiresIso = qrSession['soft_expire_at'] as String?;
      qr_expiresAt = expiresIso;
      qr_softExpiresAt = expiresIso;
    } else {
      // ไม่มี active session → สร้างใหม่
      debugPrint('🆕 ยังไม่มี QR → สร้างครั้งแรก');
      final ok = await _renewQrAndReload();
      if (!mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สร้าง QR ไม่สำเร็จ กรุณาลองอีกครั้ง'),
          ),
        );
        return;
      }
    }

    // ---------- 1) ตรวจว่า QR หมดอายุหรือไม่ (และขอ Renew ถ้าจำเป็น) ----------
    final expiresAt =
        qr_expiresAt != null ? DateTime.tryParse(qr_expiresAt!) : null;
    final isExpired = expiresAt != null && DateTime.now().isAfter(expiresAt);

    // ⚠️ ถ้ามีสลิปอัปโหลดแล้ว ไม่ต้อง renew QR เพราะไม่จำเป็นต้องใช้ QR อีกแล้ว
    final hasUploadedSlip = _uploadedSlipData != null;

    if (isExpired && !hasUploadedSlip) {
      debugPrint('❌ QR หมดอายุแล้ว → ขอ renew');
      final ok =
          await _renewQrAndReload(); // คุณต้องมีฟังก์ชันนี้ (ดูตัวอย่างในข้อความก่อนหน้า)
      if (!mounted) return;
      if (!ok) {
        // แจ้งผู้ใช้แล้วหยุด
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง',
            ),
          ),
        );
        return;
      }
    } else if (isExpired && hasUploadedSlip) {
      debugPrint('⚠️ QR หมดอายุ แต่มีสลิปอัปโหลดแล้ว → ข้ามการ renew');
    }

    // ---------- 2) ตั้งค่าเวลาหมดอายุ/ตัวช่วยแสดงผล ----------
    // ใช้ค่าล่าสุด (อาจถูกอัปเดตจาก renew)
    final String nowExpiresIso = qr_expiresAt?.toString() ?? '';
    final DateTime expiryLocal =
        (DateTime.tryParse(nowExpiresIso) ?? DateTime.now()).toLocal();
    final DateTime expiryUtc = expiryLocal.toUtc();

    // อายุเต็ม (วินาที) — หากระบบคุณรู้แน่ชัดว่า 5 นาที ให้คง 300
    // หรือจะคำนวณจาก now→expiry ตอนเปิดก็ได้
    const int _totalSecs = 300;

    int secondsUntilExpire() {
      final nowUtc = DateTime.now().toUtc();
      final sec = expiryUtc.difference(nowUtc).inSeconds;
      return sec < 0 ? 0 : sec;
    }

    String _hhmmssFromSecs(int secs) {
      final h = (secs ~/ 3600).toString().padLeft(2, '0');
      final m = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
      final s = (secs % 60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }

    String _fmtExpireLocal(String? isoUtc) {
      final d =
          (isoUtc == null || isoUtc.isEmpty) ? null : DateTime.tryParse(isoUtc);
      if (d == null) return '-';
      return DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());
    }

    final ref1 = return_qr_refapi1 ?? '-';
    final ref2 = return_qr_refapi2 ?? '-';
    final ref3 = return_qr_refapi3 ?? '-';
    final bno = paybno ?? '-';
    final bname = paybname ?? '-';
    final imgUrl = (MyConstant().domain) + (payimg ?? '');
    final amtStr =
        nFormat.format(double.tryParse('${amountIntents ?? 0}') ?? 0);
    final amtRaw =
        (double.tryParse('${amountIntents ?? 0}') ?? 0).toStringAsFixed(2);
    final ptser = '${payptser}'; // ช่องทาง
    final expLbl = _fmtExpireLocal(qr_expiresAt); // แสดงเวลา local

    // payload สำหรับ QR ตาม ptser
    debugPrint('💳 Payment Type (ptser): $ptser');
    debugPrint('💳 ref1: $ref1, ref2: $ref2');
    debugPrint('💳 Bank No: $bno');
    debugPrint('💳 Amount Raw: $amtRaw');
    debugPrint('💳double Amount Raw: ${double.tryParse(amtRaw) ?? 0}');
    debugPrint('💳 qr_payload: $qr_payload');
    debugPrint('💳 imgUrl: $imgUrl');

    final qrData = (ptser == '7')
        ? qr_payload.toString()
        : (ptser == '6')
            ? '|$bno||r$ref1||r$ref2||r${amtRaw.replaceAll('.', '')}'
            : (ptser == '5')
                ? generateQRCode(
                    promptPayID: bno, amount: double.tryParse(amtRaw) ?? 0)
                : (ptser == '2')
                    ? '${payimg}'
                    : '';

    debugPrint('💳 Generated QR Data (length: ${qrData.length}): $qrData');

    // ---------- 3.5) ตรวจสอบว่า payment type รองรับ QR หรือไม่ ----------
    if (qrData.isEmpty) {
      debugPrint(
          '❌ ไม่สามารถสร้าง QR ได้ - Payment type $ptser ไม่รองรับ QR หรือข้อมูลไม่ครบ');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ptser == '1'
                ? 'การชำระเงินสดไม่รองรับ QR Code'
                : 'ไม่สามารถสร้าง QR Code ได้ ข้อมูลไม่ครบถ้วน',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // ---------- 4) เปิดแผ่น QR ----------
    final _loadingFuture = Future.delayed(const Duration(seconds: 2));
    debugPrint('🔵 About to show sticky flexible bottom sheet');
    debugPrint('QR Data: $qrData');
    debugPrint('Amount: $amtStr');
    debugPrint('Bank Name: $bname');

    try {
      await showStickyFlexibleBottomSheet<void>(
        context: context,
        isDismissible: false, // ห้ามกดนอกเพื่อปิด
        isCollapsible: false, // ห้ามยุบลง
        isSafeArea: true,
        minHeight: 0.48,
        initHeight: 1.0,
        maxHeight: 1.0,
        anchors: const [0.48, 0.55, 1.0],
        headerHeight: 70,
        bottomSheetColor: Colors.white,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),

        // ------------ Header ------------
        headerBuilder: (ctx, _) => Material(
          child: Container(
            height: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 4, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(999)))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(ctx).pop(),
                          tooltip: 'ปิด',
                        ),
                        const SizedBox(width: 6),
                        // Countdown + Progress (อ้างอิงวินาทีเดียว)
                        Expanded(
                          child: StreamBuilder<int>(
                            stream: Stream.periodic(
                              const Duration(seconds: 1),
                              (_) => secondsUntilExpire(),
                            ),
                            initialData: secondsUntilExpire(),
                            builder: (_, snap) {
                              final secs = (snap.data ?? 0);
                              final clamped = secs < 0 ? 0 : secs;
                              final prog =
                                  (clamped / _totalSecs).clamp(0.0, 1.0);

                              final label = (clamped == 0
                                  ? 'หมดอายุแล้ว'
                                  : 'หมดอายุ ${_hhmmssFromSecs(clamped)}');

                              // ถ้าหมดอายุแล้ว – ปิดแผ่น + เสนอให้ต่ออายุ
                              // แต่ถ้ามีสลิปแล้ว (uploadedSlipData != null) ไม่ต้องปิด
                              if (clamped == 0 && _uploadedSlipData == null) {
                                Future.microtask(() async {
                                  if (!mounted) return;
                                  Navigator.of(ctx).maybePop();
                                  // คุณจะเรียก _renewQrAndReload() ที่นี่ก็ได้
                                });
                              }

                              return Row(
                                children: [
                                  Icon(
                                    clamped == 0
                                        ? Icons.timer_off
                                        : Icons.timer,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    label,
                                    style: const TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: prog,
                                        minHeight: 6,
                                        backgroundColor: Colors.white24,
                                        valueColor: AlwaysStoppedAnimation(
                                          clamped == 0
                                              ? Colors.redAccent
                                              : Colors.amber,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ------------ Body ------------
        bodyBuilder: (_, __) {
          return SliverChildListDelegate([
            const Divider(height: 1),
            FutureBuilder(
              future: _loadingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return LayoutBuilder(builder: (context, c) {
                  final maxW = c.maxWidth;
                  final isMobile = maxW < 480;
                  final isTablet = maxW >= 480 && maxW < 900;
                  final isDesktop = maxW >= 900;
                  final double contentW =
                      isDesktop ? 1080 : (isTablet ? 720 : double.infinity);
                  final double cardW =
                      isDesktop ? 720 : (isTablet ? 560 : double.infinity);
                  final qrSize = isDesktop ? 150.0 : (isTablet ? 200.0 : 180.0);
                  final pad = EdgeInsets.fromLTRB(
                      isDesktop ? 24 : 16,
                      isMobile ? 12 : 16,
                      isDesktop ? 24 : 16,
                      isMobile ? 24 : 24);

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: contentW,
                      ),
                      child: Padding(
                        padding: pad,
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Text(
                                          //   'สแกน QR นี้เพื่อชำระเงิน',
                                          //   textAlign: TextAlign.center,
                                          //   style: TextStyle(
                                          //       fontFamily: Font_.Fonts_T,
                                          //       fontWeight: FontWeight.w700,
                                          //       fontSize: isDesktop ? 16 : 14,
                                          //       color: Colors.black.withOpacity(.65)),
                                          // ),
                                          // const SizedBox(height: 6),

                                          // กล่อง QR + countdown ซ้ำ (อ้างอิง secondsUntilExpire เดียวกัน)
                                          StreamBuilder<int>(
                                            stream: Stream.periodic(
                                              const Duration(seconds: 1),
                                              (_) => secondsUntilExpire(),
                                            ),
                                            initialData: secondsUntilExpire(),
                                            builder: (_, snap) {
                                              final secs = snap.data ?? 0;
                                              final prog = (secs / _totalSecs)
                                                  .clamp(0.0, 1.0);

                                              return Center(
                                                child: Stack(children: [
                                                  ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                        maxWidth: cardW),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black12,
                                                            width: .5),
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      .06),
                                                              blurRadius: 16,
                                                              offset:
                                                                  const Offset(
                                                                      0, 8))
                                                        ],
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          RepaintBoundary(
                                                            key: qrBlockKey,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .black12,
                                                                    width: .5),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .06),
                                                                      blurRadius:
                                                                          16,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              8))
                                                                ],
                                                              ),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              child: Column(
                                                                children: [
                                                                  // ถ้าหมดเวลา (prog==0) AND ยังไม่มีสลิป => แสดงหน้าหมดเวลา
                                                                  if (prog ==
                                                                          0 &&
                                                                      _uploadedSlipData ==
                                                                          null) ...[
                                                                    SizedBox(
                                                                      width: double
                                                                          .infinity,
                                                                      height: qrSize +
                                                                          qrSize,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.qr_code,
                                                                              color: Colors.redAccent,
                                                                              size: 40),
                                                                          const SizedBox(
                                                                              height: 8),
                                                                          const Text(
                                                                            'หมดเวลา QR',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: Font_.Fonts_T,
                                                                              color: Colors.black54,
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 12),
                                                                          ElevatedButton
                                                                              .icon(
                                                                            icon:
                                                                                const Icon(Icons.refresh),
                                                                            label:
                                                                                Text(
                                                                              'ขอ QR ใหม่',
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              final ok = await _renewQrAndReload();
                                                                              if (!mounted)
                                                                                return;
                                                                              if (ok) {
                                                                                Navigator.of(context).pop();
                                                                                //                                                             required String bNo,
                                                                                // required String bName,
                                                                                // required String ptSer,
                                                                                // required String iMg,
                                                                                // required double Amount,
                                                                                _openQrSheet();
                                                                              } else {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  SnackBar(
                                                                                    content: Text('ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง'),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            },
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ] else if (ptser ==
                                                                      '2') ...[
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              6),
                                                                      child: Image
                                                                          .network(
                                                                        payimg!.isNotEmpty &&
                                                                                payimg != '' &&
                                                                                payimg != 'null'
                                                                            ? imgUrl
                                                                            : 'https://www.shutterstock.com/image-vector/no-qr-code-icon-vector-260nw-1815277187.jpg',
                                                                        width: double
                                                                            .infinity,
                                                                        height: qrSize +
                                                                            qrSize,
                                                                        fit: BoxFit
                                                                            .contain,
                                                                        loadingBuilder: (context,
                                                                            child,
                                                                            progress) {
                                                                          if (progress ==
                                                                              null) {
                                                                            return child;
                                                                          }
                                                                          return SizedBox(
                                                                            height:
                                                                                qrSize + qrSize,
                                                                            child:
                                                                                Center(
                                                                              child: CircularProgressIndicator(
                                                                                value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                        errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) {
                                                                          return Container(
                                                                            width:
                                                                                double.infinity,
                                                                            height:
                                                                                qrSize + qrSize,
                                                                            color:
                                                                                Colors.grey.shade200,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: const [
                                                                                Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  'ไม่สามารถโหลด QR ได้',
                                                                                  style: TextStyle(
                                                                                    fontFamily: Font_.Fonts_T,
                                                                                    color: Colors.black54,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ] else if (ptser ==
                                                                          '7' ||
                                                                      ptser ==
                                                                          '6' ||
                                                                      ptser ==
                                                                          '5') ...[
                                                                    Image.asset(
                                                                      'images/thai_qr_payment.png',
                                                                      width: double
                                                                          .infinity,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                    SizedBox(
                                                                        height: isMobile
                                                                            ? 10
                                                                            : 12),
                                                                    PrettyQr(
                                                                      size:
                                                                          qrSize,
                                                                      data: qrData
                                                                              .isNotEmpty
                                                                          ? qrData
                                                                          : 'EMPTY',
                                                                      image: const AssetImage(
                                                                          'images/icon_thaiqr.png'),
                                                                      errorCorrectLevel:
                                                                          QrErrorCorrectLevel
                                                                              .M,
                                                                      roundEdges:
                                                                          true,
                                                                    ),
                                                                  ] else ...[
                                                                    Container(
                                                                      width: double
                                                                          .infinity,
                                                                      height: qrSize +
                                                                          qrSize,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: const [
                                                                          Icon(
                                                                              Icons.error_outline,
                                                                              color: Colors.redAccent,
                                                                              size: 40),
                                                                          SizedBox(
                                                                              height: 8),
                                                                          Text(
                                                                            'ไม่สามารถโหลด QR ได้',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: Font_.Fonts_T,
                                                                              color: Colors.black54,
                                                                              fontSize: 13,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                  SizedBox(
                                                                      height: isMobile
                                                                          ? 8
                                                                          : 10),
                                                                  Text(
                                                                    amtStr,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          isDesktop
                                                                              ? 18
                                                                              : 16,
                                                                      color: Colors
                                                                          .red
                                                                          .shade900,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          3),
                                                                  Text(
                                                                    bname,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          isDesktop
                                                                              ? 16
                                                                              : 14,
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .65),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    bno.toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          isDesktop
                                                                              ? 16
                                                                              : 14,
                                                                      color: Colors
                                                                          .black
                                                                          .withOpacity(
                                                                              .65),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                      height: 2,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade600),
                                                                  const SizedBox(
                                                                      height:
                                                                          2),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      CircleAvatar(
                                                                        radius:
                                                                            10,
                                                                        child: Image
                                                                            .asset(
                                                                          'images/Icon-chao.png',
                                                                          width:
                                                                              double.infinity,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              2),
                                                                      Text(
                                                                        'ชำระภายใน $expLbl  |  $ref3',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          fontWeight:
                                                                              FontWeight.w700,
                                                                          fontSize: isDesktop
                                                                              ? 13
                                                                              : 11,
                                                                          color: Colors
                                                                              .black
                                                                              .withOpacity(.65),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),

                                                          // ปุ่ม Save / Share
                                                          LayoutBuilder(
                                                              builder: (_, c2) {
                                                            final inRow =
                                                                c2.maxWidth >=
                                                                    420;
                                                            final saveBtn =
                                                                _solidBtn(
                                                              color:
                                                                  Colors.indigo,
                                                              icon: Icons
                                                                  .save_alt,
                                                              label: 'บันทึก',
                                                              onTap: () async {
                                                                await downloadWidgetAsPng(
                                                                  qrBlockKey,
                                                                  fileName:
                                                                      'QRPAY_$bname.png',
                                                                );
                                                              },
                                                            );
                                                            final shareBtn =
                                                                _ghostBtn(
                                                              icon: Icons.share,
                                                              label: 'แชร์',
                                                              onTap: () async {
                                                                await shareWidgetAsPng(
                                                                  qrBlockKey,
                                                                  fileName:
                                                                      'QRPAY_$bname.png',
                                                                );
                                                              },
                                                            );
                                                            return inRow
                                                                ? Row(
                                                                    children: [
                                                                        Expanded(
                                                                            child:
                                                                                saveBtn),
                                                                        const SizedBox(
                                                                            width:
                                                                                12),
                                                                        Expanded(
                                                                            child:
                                                                                shareBtn),
                                                                      ])
                                                                : Column(
                                                                    children: [
                                                                        saveBtn,
                                                                        const SizedBox(
                                                                            height:
                                                                                10),
                                                                        shareBtn,
                                                                      ]);
                                                          }),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (_uploadedSlipData != null)
                                                    Positioned(
                                                      top: 28,
                                                      right: 18,
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .black26,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(0, 2),
                                                            )
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .check_circle,
                                                              color: Colors
                                                                  .green
                                                                  .shade600,
                                                              size: 14,
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              'แนบสลิปแล้ว',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ]),
                                              );
                                            },
                                          ),
                                        ],
                                      )),
                                  const SizedBox(width: 20),
                                  Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          _howToBox(),
                                          const SizedBox(height: 10),
                                          _howToBoxSlip(
                                              amount:
                                                  '${double.tryParse(amtRaw) ?? 0}',
                                              uploadedSlipData:
                                                  _uploadedSlipData)
                                        ],
                                      )),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'สแกน QR นี้เพื่อชำระเงิน',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontWeight: FontWeight.w700,
                                        fontSize: isDesktop ? 16 : 14,
                                        color: Colors.black.withOpacity(.65)),
                                  ),
                                  const SizedBox(height: 6),

                                  // กล่อง QR + countdown ซ้ำ (อ้างอิง secondsUntilExpire เดียวกัน)
                                  StreamBuilder<int>(
                                    stream: Stream.periodic(
                                      const Duration(seconds: 1),
                                      (_) => secondsUntilExpire(),
                                    ),
                                    initialData: secondsUntilExpire(),
                                    builder: (_, snap) {
                                      final secs = snap.data ?? 0;
                                      final prog =
                                          (secs / _totalSecs).clamp(0.0, 1.0);

                                      return Center(
                                        child: ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: cardW),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                  color: Colors.black12,
                                                  width: .5),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(.06),
                                                    blurRadius: 16,
                                                    offset: const Offset(0, 8))
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(2),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                RepaintBoundary(
                                                  key: qrBlockKey,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                          color: Colors.black12,
                                                          width: .5),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    .06),
                                                            blurRadius: 16,
                                                            offset:
                                                                const Offset(
                                                                    0, 8))
                                                      ],
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    child: Column(
                                                      children: [
                                                        if (prog == 0 &&
                                                            _uploadedSlipData ==
                                                                null) ...[
                                                          SizedBox(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                qrSize + qrSize,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                const Icon(
                                                                    Icons
                                                                        .qr_code,
                                                                    color: Colors
                                                                        .redAccent,
                                                                    size: 40),
                                                                const SizedBox(
                                                                    height: 8),
                                                                const Text(
                                                                  'หมดเวลา QR',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 12),
                                                                ElevatedButton
                                                                    .icon(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .refresh),
                                                                  label: Text(
                                                                    'ขอ QR ใหม่',
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    final ok =
                                                                        await _renewQrAndReload();
                                                                    if (!mounted)
                                                                      return;
                                                                    if (ok) {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      //                                                             required String bNo,
                                                                      // required String bName,
                                                                      // required String ptSer,
                                                                      // required String iMg,
                                                                      // required double Amount,
                                                                      _openQrSheet();
                                                                    } else {
                                                                      ScaffoldMessenger.of(
                                                                              context)
                                                                          .showSnackBar(
                                                                        SnackBar(
                                                                          content:
                                                                              Text('ต่ออายุ QR ไม่สำเร็จ กรุณาลองอีกครั้ง'),
                                                                        ),
                                                                      );
                                                                    }
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ] else if (ptser ==
                                                            '2') ...[
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        6),
                                                            child:
                                                                Image.network(
                                                              payimg!.isNotEmpty &&
                                                                      payimg !=
                                                                          '' &&
                                                                      payimg !=
                                                                          'null'
                                                                  ? imgUrl
                                                                  : 'https://www.shutterstock.com/image-vector/no-qr-code-icon-vector-260nw-1815277187.jpg',
                                                              width: double
                                                                  .infinity,
                                                              height: qrSize +
                                                                  qrSize,
                                                              fit: BoxFit
                                                                  .contain,
                                                              loadingBuilder:
                                                                  (context,
                                                                      child,
                                                                      progress) {
                                                                if (progress ==
                                                                    null) {
                                                                  return child;
                                                                }
                                                                return SizedBox(
                                                                  height:
                                                                      qrSize +
                                                                          qrSize,
                                                                  child: Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      value: progress.expectedTotalBytes !=
                                                                              null
                                                                          ? progress.cumulativeBytesLoaded /
                                                                              (progress.expectedTotalBytes ?? 1)
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Container(
                                                                  width: double
                                                                      .infinity,
                                                                  height:
                                                                      qrSize +
                                                                          qrSize,
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: const [
                                                                      Icon(
                                                                          Icons
                                                                              .error_outline,
                                                                          color: Colors
                                                                              .redAccent,
                                                                          size:
                                                                              40),
                                                                      SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                        'ไม่สามารถโหลด QR ได้',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          color:
                                                                              Colors.black54,
                                                                          fontSize:
                                                                              13,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ] else if (ptser ==
                                                                '7' ||
                                                            ptser == '6' ||
                                                            ptser == '5') ...[
                                                          Stack(
                                                            children: [
                                                              Image.asset(
                                                                'images/thai_qr_payment.png',
                                                                width: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                              if (_uploadedSlipData !=
                                                                  null)
                                                                Positioned(
                                                                  bottom: 8,
                                                                  right: 8,
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            4),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .green,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.black26,
                                                                          blurRadius:
                                                                              4,
                                                                          offset: Offset(
                                                                              0,
                                                                              2),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: const [
                                                                        Icon(
                                                                          Icons
                                                                              .check_circle,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              14,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                4),
                                                                        Text(
                                                                          'แนบสลิปแล้ว',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              height: isMobile
                                                                  ? 10
                                                                  : 12),
                                                          PrettyQr(
                                                            size: qrSize,
                                                            data: qrData
                                                                    .isNotEmpty
                                                                ? qrData
                                                                : 'EMPTY',
                                                            image: const AssetImage(
                                                                'images/icon_thaiqr.png'),
                                                            errorCorrectLevel:
                                                                QrErrorCorrectLevel
                                                                    .M,
                                                            roundEdges: true,
                                                          ),
                                                        ] else ...[
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            height:
                                                                qrSize + qrSize,
                                                            color: Colors
                                                                .grey.shade200,
                                                            alignment: Alignment
                                                                .center,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: const [
                                                                Icon(
                                                                    Icons
                                                                        .error_outline,
                                                                    color: Colors
                                                                        .redAccent,
                                                                    size: 40),
                                                                SizedBox(
                                                                    height: 8),
                                                                Text(
                                                                  'ไม่สามารถโหลด QR ได้',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                        SizedBox(
                                                            height: isMobile
                                                                ? 8
                                                                : 10),
                                                        Text(
                                                          amtStr,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: isDesktop
                                                                ? 18
                                                                : 16,
                                                            color: Colors
                                                                .red.shade900,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 3),
                                                        Text(
                                                          bname,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: isDesktop
                                                                ? 16
                                                                : 14,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    .65),
                                                          ),
                                                        ),
                                                        Text(
                                                          bno.toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: isDesktop
                                                                ? 16
                                                                : 14,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    .65),
                                                          ),
                                                        ),
                                                        Divider(
                                                            height: 2,
                                                            color: Colors
                                                                .grey.shade600),
                                                        const SizedBox(
                                                            height: 2),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 10,
                                                              child:
                                                                  Image.asset(
                                                                'images/Icon-chao.png',
                                                                width: double
                                                                    .infinity,
                                                                fit: BoxFit
                                                                    .contain,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 2),
                                                            Text(
                                                              'ชำระภายใน $expLbl  |  $ref1',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontFamily: Font_
                                                                    .Fonts_T,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize:
                                                                    isDesktop
                                                                        ? 13
                                                                        : 11,
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        .65),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),

                                                // ปุ่ม Save / Share
                                                LayoutBuilder(builder: (_, c2) {
                                                  final inRow =
                                                      c2.maxWidth >= 420;
                                                  final saveBtn = _solidBtn(
                                                    color: Colors.indigo,
                                                    icon: Icons.save_alt,
                                                    label: 'บันทึก',
                                                    onTap: () async {
                                                      await downloadWidgetAsPng(
                                                        qrBlockKey,
                                                        fileName:
                                                            'QRPAY_$bname.png',
                                                      );
                                                    },
                                                  );
                                                  final shareBtn = _ghostBtn(
                                                    icon: Icons.share,
                                                    label: 'แชร์',
                                                    onTap: () async {
                                                      await downloadWidgetAsPng(
                                                        qrBlockKey,
                                                        fileName:
                                                            'QRPAY_$bname.png',
                                                      );
                                                    },
                                                  );
                                                  return inRow
                                                      ? Row(children: [
                                                          Expanded(
                                                              child: saveBtn),
                                                          const SizedBox(
                                                              width: 12),
                                                          Expanded(
                                                              child: shareBtn),
                                                        ])
                                                      : Column(children: [
                                                          saveBtn,
                                                          const SizedBox(
                                                              height: 10),
                                                          shareBtn,
                                                        ]);
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // กล่อง “วิธีชำระ”
                                  Center(
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: cardW),
                                      child: _howToBox(), // ใช้ของเดิมคุณ
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: cardW),
                                      child: _howToBoxSlip(
                                          amount:
                                              '${double.tryParse(amtRaw) ?? 0}',
                                          uploadedSlipData: _uploadedSlipData),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  );
                });
              },
            ),
          ]);
        },
      );
    } catch (e) {
      debugPrint('❌ Error showing bottom sheet: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _howToBox() {
    Widget step(int i, String t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: Colors.indigo.withOpacity(.25), width: .7),
                ),
                child: Text('$i',
                    style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w900,
                        color: Colors.indigo.shade700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(t,
                      style: const TextStyle(
                          fontFamily: Font_.Fonts_T, fontSize: 13.5))),
            ],
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: .5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'สแกน QR นี้เพื่อชำระเงิน',
          //   textAlign: TextAlign.center,
          //   style: const TextStyle(
          //       fontFamily: Font_.Fonts_T,
          //       fontWeight: FontWeight.w800,
          //       fontSize: 15),
          // ),
          // const SizedBox(height: 6),
          Text('วิธีชำระเงิน',
              style: const TextStyle(
                  fontFamily: Font_.Fonts_T,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
          const SizedBox(height: 10),
          step(1, 'ตรวจสอบ “ข้อมูล”  ว่าถูกต้องหรือไม่'),
          step(2, 'กด “บันทึก” รูป QR พร้อมเพย์ด้านบนลงในโทรศัพท์มือถือของคุณ'),
          step(3, 'เปิดแอปพลิเคชันธนาคารที่คุณมี เพื่อชำระเงิน'),
          step(4,
              'ไปที่เมนู “สแกน/สแกนจ่าย” แล้วกด “รูปภาพ” เพื่อเลือกรูป QR ที่บันทึกไว้'),
        ],
      ),
    );
  }

  Widget _howToBoxSlip({
    required String amount,
    Map<String, dynamic>? uploadedSlipData,
  }) {
    final bool hasUploadedSlip = uploadedSlipData != null;

    debugPrint('🔍 _howToBoxSlip called: hasUploadedSlip=$hasUploadedSlip');
    debugPrint('🔍 uploadedSlipData: $uploadedSlipData');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: .5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('หลักฐานการชำระ',
            style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w800,
                fontSize: 15)),
        const SizedBox(height: 10),

        // Show uploaded slip info if exists
        if (hasUploadedSlip) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'อัปโหลดเรียบร้อยแล้ว',
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _slipInfoRow(
                    'ไฟล์:', uploadedSlipData['original_filename'] ?? '-'),
                _slipInfoRow('จำนวนเงิน:',
                    '${uploadedSlipData['amount']} ${uploadedSlipData['currency'] ?? ''}'),
                _slipInfoRow(
                    'วันที่:', uploadedSlipData['transfer_date'] ?? '-'),
                _slipInfoRow(
                    'Ref:', uploadedSlipData['transfer_ref_no'] ?? '-'),
                _slipInfoRow(
                    'สถานะ:', _getStatusText(uploadedSlipData['status'] ?? '')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Reset uploaded data to allow new upload
                        setState(() {
                          _uploadedSlipData = null;
                        });
                        // Trigger file picker
                        final success = await _pickSlipImage();
                        if (success && _slipImageBytes != null) {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                          final successUp =
                              await _uploadSlipImage(amtRawSlip: amount);
                          if (mounted) {
                            Navigator.of(context).pop(); // Close dialog
                            if (successUp) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('อัปโหลดสลิปสำเร็จ!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('แนบอีกครั้ง',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final response = await getSlipPreviewPaymentIntents(
                            slipUuid: intentsAttacheSlipNo ?? "");
                        if (!mounted) return;

                        await showDialog<void>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            final isSuccess = response != null &&
                                response.statusCode >= 200 &&
                                response.statusCode < 300;

                            return AlertDialog(
                              title: const Text('หลักฐานการโอนเงิน',
                                  style: TextStyle(
                                      fontFamily: Font_.Fonts_T, fontSize: 16)),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    if (isSuccess &&
                                        response.bodyBytes.isNotEmpty)
                                      Image.memory(
                                        response.bodyBytes,
                                        fit: BoxFit.contain,
                                      )
                                    else
                                      Column(
                                        children: [
                                          const Icon(Icons.broken_image,
                                              size: 50, color: Colors.grey),
                                          const SizedBox(height: 10),
                                          Text(
                                            'ไม่สามารถโหลดรูปภาพได้\n(Status: ${response?.statusCode ?? 'N/A'})',
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              actions: [
                                if (isSuccess && response.bodyBytes.isNotEmpty)
                                  TextButton.icon(
                                    icon: const Icon(Icons.download,
                                        size: 16, color: Colors.blue),
                                    label: const Text('ดาวน์โหลด',
                                        style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            color: Colors.blue)),
                                    onPressed: () {
                                      final blob =
                                          html.Blob([response.bodyBytes]);
                                      final url =
                                          html.Url.createObjectUrlFromBlob(
                                              blob);
                                      final filename = uploadedSlipData[
                                              'original_filename'] ??
                                          'slip.jpg';
                                      html.AnchorElement(href: url)
                                        ..setAttribute("download", filename)
                                        ..click();
                                      html.Url.revokeObjectUrl(url);
                                    },
                                  ),
                                TextButton(
                                  child: const Text('ปิด',
                                      style:
                                          TextStyle(fontFamily: Font_.Fonts_T)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('ดูหลักฐาน',
                          style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ] else ...[
          // Upload UI when no slip uploaded yet
          DragDropZone(
            onFileDropped: (bytes, name) async {
              setState(() {
                _uploadedSlipData = null;
                _slipImageBytes = bytes;
                _slipImageName = name;
              });

              if (!mounted) return;
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              );
              final successUp = await _uploadSlipImage(amtRawSlip: amount);
              if (mounted) {
                Navigator.of(context).pop(); // Close dialog
                if (successUp) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('อัปโหลดสลิปสำเร็จ!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop(); // Close bottom sheet
                }
              }
            },
            child: GestureDetector(
              // onTap: _pickSlipImage,
              onTap: () async {
                // Reset uploaded data to allow new upload
                setState(() {
                  _uploadedSlipData = null;
                });
                // Trigger file picker
                final success = await _pickSlipImage();
                if (success && _slipImageBytes != null) {
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  final successUp = await _uploadSlipImage(amtRawSlip: amount);
                  if (mounted) {
                    Navigator.of(context).pop(); // Close dialog
                    if (successUp) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('อัปโหลดสลิปสำเร็จ!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop(); // Close bottom sheet
                    }
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.shade200,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  // image: (_slipImageBytes == null)
                  //     ? null
                  //     : DecorationImage(
                  //         image: MemoryImage(_slipImageBytes!),
                  //         fit: BoxFit.cover,
                  //       ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 48, color: Colors.orange.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'คลิกเพื่อเลือกไฟล์',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'หรือลากไฟล์มาวางที่นี่',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 12,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'รองรับไฟล์: JPG, PNG (สูงสุด 5MB)',
                      style: TextStyle(
                        fontFamily: Font_.Fonts_T,
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text('หรืออัปโหลดผ่าน LINE: @chaoperty',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        ],
      ]),
    );
  }

  // Helper to display slip info row
  Widget _slipInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get status text in Thai
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'รอตรวจสอบ';
      case 'approved':
        return 'อนุมัติแล้ว';
      case 'rejected':
        return 'ปฏิเสธ';
      default:
        return status;
    }
  }

  // Pick slip image using file picker
  Future<bool> _pickSlipImage() async {
    final completer = Completer<bool>();
    try {
      // For web, use HTML file input
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*'
        ..click();

      uploadInput.onChange.listen((event) async {
        final file = uploadInput.files?.first;
        if (file == null) {
          completer.complete(false);
          return;
        }

        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไฟล์มีขนาดใหญ่เกิน 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          completer.complete(false);
          return;
        }

        // Read file as bytes
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _slipImageBytes = reader.result as Uint8List;
            _slipImageName = file.name;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เลือกไฟล์: ${file.name}'),
              backgroundColor: Colors.green,
            ),
          );
          completer.complete(true);
        });
      });

      // Handle cancellation (simplified, as web file picker cancellation is hard to detect reliable, relying on user action)
      // For now we just return the completer future.
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
      completer.complete(false);
    }
    return completer.future;
  }

  // Upload slip image to server
  Future<bool> _uploadSlipImage({required String amtRawSlip}) async {
    if (_slipImageBytes == null || _slipImageName == null) return false;

    // Show loading message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กำลังอัปโหลดสลิป...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Get selected payment intent UUID
      final uuid = numinvoice ?? '';
      if (uuid.isEmpty) {
        throw Exception('ไม่พบ Payment Intent UUID');
      }
      final headers = await MyHeadersIntents.build();

      final uri = Uri.parse(
          '${MyconfigIntents().domainIntents}/v1/payment/intent/$uuid/upload/slip');

      final request = http.MultipartRequest('POST', uri);

      // Add form fields
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      print("uri : $uri");
      print({
        'amount': amtRawSlip,
        'transfer_date': dateStr,
        'transfer_ref_no': return_qr_refapi3 ?? '',
        'transfer_type': 'bank_transfer',
        'notes': 'อัปโหลดจาก QR Sheet',
      });
      request.fields.addAll({
        'amount': amtRawSlip,
        'transfer_date': dateStr,
        'transfer_ref_no': return_qr_refapi3 ?? '',
        'transfer_type': 'bank_transfer',
        'notes': 'อัปโหลดจาก QR Sheet',
      });

      // Detect MIME type from file extension to avoid 'application/octet-stream'
      String contentType = 'image/jpeg'; // default
      final extension = _slipImageName!.toLowerCase().split('.').last;
      if (extension == 'png') {
        contentType = 'image/png';
      } else if (extension == 'jpg' || extension == 'jpeg') {
        contentType = 'image/jpeg';
      }

      debugPrint('📎 File: $_slipImageName, Type: $contentType');

      // Add image file from bytes (for web compatibility)
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _slipImageBytes!,
          filename: _slipImageName!,
          contentType: MediaType.parse(contentType),
        ),
      );

      request.headers.addAll(headers);

      // Send request
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('✅ Upload success: $responseBody');

        final jsonResponse = jsonDecode(responseBody);
        setState(() {
          _slipImageBytes = null;
          _slipImageName = null;
          intentsAttacheSlipNo =
              jsonResponse['slip_no'] ?? intentsAttacheSlipNo;
        });

        if (!mounted) return false;

        // Reload payment intents to reflect updated status
        await redPaymentIntents();
        return true;
      } else {
        final errorBody = await response.stream.bytesToString();
        debugPrint('❌ Upload failed: ${response.statusCode} - $errorBody');

        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Upload error: $e\n$stackTrace');

      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
    return false;
  }

  Widget _stepSlip(int no, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.orange.shade300, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              '$no',
              style: TextStyle(
                fontFamily: Font_.Fonts_T,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Colors.orange.shade700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: Font_.Fonts_T,
                fontSize: 13,
                height: 1.4,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DragDropZone extends StatefulWidget {
  final Widget child;
  final Function(Uint8List bytes, String name) onFileDropped;

  const DragDropZone({
    Key? key,
    required this.child,
    required this.onFileDropped,
  }) : super(key: key);

  @override
  _DragDropZoneState createState() => _DragDropZoneState();
}

class _DragDropZoneState extends State<DragDropZone> {
  StreamSubscription<html.MouseEvent>? _dragOverSub;
  StreamSubscription<html.MouseEvent>? _dropSub;

  @override
  void initState() {
    super.initState();
    _dragOverSub = html.document.onDragOver.listen((event) {
      event.preventDefault();
    });

    _dropSub = html.document.onDrop.listen((event) {
      event.preventDefault();

      final files = event.dataTransfer.files;
      if (files != null && files.isNotEmpty) {
        final file = files.first;
        // Validate file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไฟล์มีขนาดใหญ่เกิน 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        reader.onLoadEnd.listen((e) {
          if (reader.result != null) {
            widget.onFileDropped(reader.result as Uint8List, file.name);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _dragOverSub?.cancel();
    _dropSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
