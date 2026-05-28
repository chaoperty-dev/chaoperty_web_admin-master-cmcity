import 'dart:async';
import 'dart:html' as html;
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
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
import '../../Constant/Myconstant.dart';
import '../../Constant/global_http.dart';
import '../../INSERT_Log/Insert_log.dart';
import '../../Model/GetContractx_Fine_Model.dart';
import '../../Model/GetInvoiceRe_Model.dart';
import '../../Model/GetInvoice_diapay_Model.dart';
import '../../Model/GetInvoice_history_Model.dart';
import '../../Model/GetPayMent_Model.dart';
import '../../Model/GetRenTal_Model.dart';
import '../../Model/GetTrans_Model.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'dart:ui' as ui;
import 'Model/IntentsContractx_Fine_Model.dart';
import 'Model/IntentsInv_history_Model.dart';
import 'Model/IntentsTrans_Model.dart';
import 'bankCodeMap.dart'; // ✅ use only alias

class PaymentIntentsInvPage extends StatefulWidget {
  const PaymentIntentsInvPage({super.key});

  @override
  State<PaymentIntentsInvPage> createState() => _PaymentIntentsInvPageState();
}

class _PaymentIntentsInvPageState extends State<PaymentIntentsInvPage> {
  List<InvoiceReModel> InvoiceCustModels = [];
  List<InvoiceReModel> InvoiceModels = [];
  List<InvoiceReModel> _InvoiceModels = <InvoiceReModel>[];
  List<InvoiceReModel> limitedList_InvoiceModels_ = [];
  List<PayMentModel> _PayMentModels = [];
  List<PaymentIntent> paymentIntents = [];
  List<IntentsTransModel> _TransModels = [];
  List<IntentsContractxFineModel> contractxFineModels = [];
  List<IntentsInvoiceHistoryModel> _InvoiceHistoryModels = [];
  List<InvoiceDisPayModel> _InvoiceDisPayModels = [];
  // ==================
  final List<IntentsInvoiceHistoryModel> _invoiceHistory = [];
  final List<InvoiceDisPayModel> _invoiceDisPay = [];
  final List<IntentsContractxFineModel> _contractxFine = [];
  // ==================
  // Added missing variables for checkPreferance
  String? renTal_user, renTal_name, renTal_foder;
  var datex = DateTime.now().toString();
  // ==================
  String? MONTH_Now, YEAR_Now;
  List<String> YE_Th = [];
  DateTime newDatetime = DateTime.now();
  String? numCustno, intentsCustno, cidSelect;
  // Page selection
  int select_page = 1; // 1 = รายการวางบิล, 2 = Payment Intents
  String? selectedDocNo; // Added for right panel selection
  int? _expandedGroupIndex; // Track the currently expanded group index
  String? _expandedInnerGroupKey; // Track inner group expansion

  // ==================
  // Added missing variables
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

  double fine_total = 0;
  double dis_sum_Pakan = 0;

  final TextEditingController Form_payment1 = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController Formposlokdispri_ = TextEditingController();
  final TextEditingController sum_disamtx = TextEditingController(); // Added
  final TextEditingController sum_dispx = TextEditingController(); // Added
  final TextEditingController descripTion = TextEditingController(); // Added
  final TextEditingController Form_fine = TextEditingController();
  double fine_total2 = 0; // Added
  String? numinvoice; // Added
  String? intentsAttacheSlipNo; // Added
  final GlobalKey qrBlockKey = GlobalKey();
  String? qr_expiresAt;
  String? return_qr_refapi1;
  String? return_qr_refapi2;
  String? return_qr_refapi3;
  String? qr_payload;
  Map<String, dynamic>? _uploadedSlipData;
  Uint8List? _slipImageBytes;
  String? _slipImageName;
  String? qr_softExpiresAt;
  String? custno; // Added for _uploadSlipImage scope
  // ==================

  bool _tapBusy = false;
  int limit = 50; // The maximum number of items you want
  int offset = 0; // The starting index of items you want
  int endIndex = 0;
  // ================== lifecycle ==================
  // Financial calculation variables
  double sum_pvat = 0;
  double sum_dis = 0;
  double sum_fine = 0;
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
  double dis_matjum = 0, dis_sum_Matjum = 0;
  // ===== =====
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _resetToInitialState(targetPage: 0, billAll: false);
    });
  }

  @override
  void dispose() {
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
      // Reset variables
      _TransModels.clear();
      _InvoiceHistoryModels.clear();
      _InvoiceDisPayModels.clear();
      contractxFineModels.clear();
      limitedList_InvoiceModels_.clear();

      // Reset sums
      sum_pvat = 0;
      sum_dis = 0;
      sum_fine = 0;
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
      dis_sum_Matjum = 0;
      dis_sum_Pakan = 0;
      fine_total = 0;
      fine_total2 = 0;

      // Reset selection and form data
      selectedPaymentKey = null;
      paymentSer1 = null;
      payment_ptSer1 = null;
      numinvoice = null;
      intentsAttacheSlipNo = null;

      sum_disamtx.clear();
      descripTion.clear();
      Form_fine.clear();
      Form_payment1.clear();

      // Set page
      if (targetPage > 0) {
        select_page = targetPage;
      } else {
        select_page = 1;
      }

      await checkPreferance();
      await red_InvoiceSelectbill(Cust: '$numCustno');
      red_payMent();

      if (mounted) {
        setState(() {});
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

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

  Future<void> checkPreferance() async {
    int currentYear = DateTime.now().year + 1;
    for (int i = currentYear; i >= currentYear - 10; i--) {
      YE_Th.add(i.toString());
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      MONTH_Now = DateFormat('MM').format(DateTime.parse('${datex}'));
      YEAR_Now = DateFormat('yyyy').format(DateTime.parse('${datex}'));
      renTal_user = preferences.getString('renTalSer');
      renTal_name = preferences.getString('renTalName');
      renTal_name = preferences.getString('renTalName');
    });
    await read_GC_rental();
    red_InvoiceCustomer_bill();
  }

  Future<Null> read_GC_rental() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    String url =
        '${MyConstant().domain}/GC_rental_setring.php?isAdd=true&ren=$ren';
    renTal_name = preferences.getString('renTalName');
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);

      if (result != null) {
        for (var map in result) {
          RenTalModel renTalModel = RenTalModel.fromJson(map);

          setState(() {
            renTal_foder = renTalModel.dbn;
          });
        }
      } else {}
    } catch (e) {}
    // print('name>>>>>  $renname');
  }
  //////---------------------------------->

  Future<void> redPaymentIntents(
      {required String cusno, required String propertyno}) async {
    if (mounted) {
      setState(() {
        paymentIntents.clear();
      });
    }
    // print('🔄 เรียกใช้งาน redPaymentIntents()');
    final response =
        await postPaymentIntentsState(cusno: cusno, propertyno: propertyno);
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

  Future<Null> red_InvoiceCustomer_bill() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    // print('zone>>>ser $zone');

    setState(() {
      InvoiceCustModels.clear();
    });

    String url =
        '${MyConstant().domain}/GC_bill_invoiceCustomer.php?isAdd=true&ren=$ren&grop=grop';
    // print('url $url');
    try {
      var response = await httpClient.get(Uri.parse(url));

      var result = json.decode(response.body);
      // print('result $ciddoc');
      if (result.toString() != 'null') {
        for (var map in result) {
          InvoiceReModel transMeterModel = InvoiceReModel.fromJson(map);
          setState(() {
            InvoiceCustModels.add(transMeterModel);
          });
        }
      }

      Future.delayed(const Duration(milliseconds: 200), () async {
        setState(() {
          _InvoiceModels = InvoiceCustModels;
        });
      });
      read_Invoice_limit();
    } catch (e) {}
  }

  Future<Null> read_Invoice_limit() async {
    setState(() {
      endIndex = offset + limit;
      InvoiceModels = InvoiceCustModels.sublist(
          offset, // Start index
          (endIndex <= InvoiceCustModels.length)
              ? endIndex
              : InvoiceCustModels.length // End index
          );
    });
  }

  Future<Null> red_InvoiceSelectbill({required String Cust}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    var zone = preferences.getString('zonePSer');
    var zone_Sub = preferences.getString('zoneSubSer');

    setState(() {
      limitedList_InvoiceModels_.clear();
      numCustno = Cust;
    });

    String url =
        '${MyConstant().domain}/GC_bill_invoiceCustomer.php?isAdd=true&ren=$ren&grop=custno&custNo=${Cust}';
    print('url $url');
    try {
      var response = await httpClient.get(Uri.parse(url));

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
      print(
          'limitedList_InvoiceModels_.length :  ${limitedList_InvoiceModels_.length}');
    } catch (e) {
      print('Error in red_InvoiceSelectbill: $e'); // Debug print
      print(
          'catch limitedList_InvoiceModels_.length :  ${limitedList_InvoiceModels_.length}');
    }
  }

  Future<Null> in_Trans_select(InvoiceReModel inv) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = inv.cid;
    var qutser = '1';

    // var tser = inv.ser;
    // var tdocno = inv.docno;
    // var total_bill = ((double.parse(inv.total_dis!) +
    //     double.parse(inv.total_vat!)));
    // var total_dis = ((double.parse(inv.total_bill!) -
    //     double.parse(inv.total_dis!)));
    // var total_vat = inv.total_vat;
    // var total_wht = inv.total_wht;
    // var total_amt = inv.total_bill;
    var tser = inv.ser;
    var tdocno = inv.docno;
    var total_bill =
        (inv.total_dis == null) ? 0.00 : double.parse(inv.total_dis!);
    var total_dis = (inv.amt_dis == null) ? 0.00 : double.parse(inv.amt_dis!);
    var total_vat = (inv.total_vat == null) ? 0.00 : inv.total_vat;
    var total_wht = (inv.total_wht == null) ? 0.00 : inv.total_wht;
    var total_amt = (inv.total_bill == null) ? 0.00 : inv.total_bill;
    // print('object $tdocno');
    String url =
        '${MyConstant().domain}/In_tran_select_Inv.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user&total_bill=$total_bill&total_dis=$total_dis&total_vat=$total_vat&total_wht=$total_wht&total_amt=$total_amt';
    // print('url $url');

    try {
      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print('rr>>>>>> $result');
      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select2();
        });
        // print('rrrrrrrrrrrrrr');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.red,
              content: Text('ไม่สามารถเลือกรายการซ้ำได้',
                  style: TextStyle(
                      color: Colors.white, fontFamily: Font_.Fonts_T))),
        );
      }
    } catch (e) {
      // print('rrrrrrrrrrrrrr $e');
    }
  }

  Future<Null> red_Trans_select2() async {
    if (_TransModels.isNotEmpty) {
      setState(() {
        _TransModels.clear();
        sum_pvat = 0;
        sum_vat = 0;
        sum_wht = 0;
        sum_amt = 0;
        sum_tran_dis = 0;
        sum_matjum = 0;
        sum_fine = 0;
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = '';
    var qutser = '';

    String url =
        '${MyConstant().domain}/GC_tran_select_inv.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc'; //GC_tran_select_fin
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
          sum_fine = 0;
        });
        for (var map in result) {
          IntentsTransModel _TransModel = IntentsTransModel.fromJson(map);

          // var sum_pvatx =
          //  double.parse(_TransModel.pvat!);
          var sum_pvatx = (_TransModel.pvat == null)
              ? 0.00
              : double.parse(_TransModel.pvat!);
          var sum_vatx =
              (_TransModel.vat == null) ? 0.00 : double.parse(_TransModel.vat!);
          var sum_whtx =
              (_TransModel.wht == null) ? 0.00 : double.parse(_TransModel.wht!);
          var sum_amtx = (_TransModel.total == null)
              ? 0.00
              : double.parse(_TransModel.total!);
          var sum_disx =
              (_TransModel.dis == null) ? 0.00 : double.parse(_TransModel.dis!);
          var sum_finex = (_TransModel.fine == null)
              ? 0.00
              : double.parse(_TransModel.fine!);
          setState(() {
            sum_pvat = sum_pvat + sum_pvatx;
            sum_vat = sum_vat + sum_vatx;
            sum_wht = sum_wht + sum_whtx;
            sum_amt = sum_amt + sum_amtx;
            sum_tran_dis = sum_tran_dis + sum_disx;
            sum_fine = sum_fine + sum_finex;
            _TransModels.add(_TransModel);
          });
        }
      } else {
        setState(() {
          dis_matjum = 0;
          dis_sum_Matjum = 0.00;
        });
      }
    } catch (e) {}
  }

  Future<Null> de_Trans_item_inv(
      {required int index, required String types}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var tser = (types == 'Item') ? _TransModels[index].ser : '';

    // print('tser >>.> $tser');

    String url =
        '${MyConstant().domain}/De_tran_ser_inv.php?isAdd=true&ren=$ren&tser=$tser&user=$user&type=$types';
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

  Future<void> _updateFineTransaction(int index, String amount) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var ren = preferences.getString('renTalSer');
      var user = preferences.getString('ser');
      var qutser = _TransModels[index].ser;

      String url =
          '${MyConstant().domain}/up_fine_trsnselect.php?isAdd=true&ren=$ren&user=$user&qutser=$qutser&amt=$amount';

      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);

      if (result.toString() == 'true') {
        setState(() {
          red_Trans_select2();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _showReduceFineDialog(BuildContext context, int index) {
    Formposlokdispri_.text = ''; // ถ้าต้องการให้เริ่มว่างทุกครั้ง

    final fineValue =
        double.tryParse(_TransModels[index].fine.toString()) ?? 0.0;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          title: Row(
            children: [
              Expanded(
                child: Translate.TranslateAndSetText(
                  'ส่วนลดค่าปรับ : ${nFormat.format(fineValue)}',
                  PeopleChaoScreen_Color.Colors_Text1_,
                  TextAlign.left,
                  null,
                  Font_.Fonts_T,
                  13,
                  1,
                ),
              ),
              IconButton(
                splashRadius: 18,
                onPressed: () {
                  setState(() => Formposlokdispri_.clear());
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.close, color: Colors.black),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: Formposlokdispri_,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  cursorColor: Colors.green,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'จำนวนส่วนลด',
                    hintText: 'กรอกตัวเลขเท่านั้น',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(width: 1, color: Colors.grey),
                    ),
                    labelStyle: const TextStyle(
                      color: ManageScreen_Color.Colors_Text2_,
                      fontFamily: Font_.Fonts_T,
                    ),
                  ),
                  validator: (value) {
                    final v = (value ?? '').trim();
                    if (v.isEmpty) return 'กรุณากรอกจำนวนส่วนลด';

                    final numVal = int.tryParse(v);
                    if (numVal == null) return 'กรุณากรอกเป็นตัวเลข';
                    if (numVal < 0) return 'ต้องมากกว่าหรือเท่ากับ 0';

                    // ถ้าต้องการกันส่วนลดเกินค่าปรับ (แนะนำ)
                    if (numVal > fineValue) return 'ห้ามมากกว่าค่าปรับ';

                    return null;
                  },
                  onFieldSubmitted: (_) async {
                    if (!_formKey.currentState!.validate()) return;
                    await _updateFineTransaction(
                        index, Formposlokdispri_.text.trim());
                    if (mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await _updateFineTransaction(
                      index, Formposlokdispri_.text.trim());
                  if (mounted) Navigator.pop(ctx);
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontWeight_.Fonts_T,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Null> red_Trans_select(IntentsTransModel inv) async {
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
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = inv.cid;
    var qutser = '';
    var docnoin = inv.docno;
    // String url =
    //     '${MyConstant().domain}/GC_bill_invoice_History.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    String url =
        '${MyConstant().domain}/GC_bill_invoiceHistory_v2.php?isAdd=true&ren=$ren&user=$user&ciddoc=$ciddoc&docnoin=$docnoin';
    // print(url);
    try {
      var response = await httpClient.get(Uri.parse(url));
      var result = json.decode(response.body);
      // print(result);

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
      red_Trans_select_2(inv);
    } catch (e) {}
  }

  Future<Null> red_Trans_select_2(IntentsTransModel inv) async {
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
    var ciddoc = inv.cid;
    var qutser = '';
    var docnoin = inv.docno;

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

  Future<Null> in_Trans_dis_inv(IntentsTransModel inv) async {
    setState(() {
      _InvoiceDisPayModels.clear();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = inv.cid;
    var qutser = '';

    // var tser = inv.ser;
    var tdocno = inv..docno;

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

  Future<Null> in_Trans_fine_re(IntentsTransModel inv) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var ren = preferences.getString('renTalSer');
    var user = preferences.getString('ser');
    var ciddoc = inv.cid;
    var qutser = '';
    var tser = inv.ser;
    var tdocno = inv.docno;
    String url =
        '${MyConstant().domain}/In_tran_select_fine_inv.php?isAdd=true&ren=$ren&ciddoc=$ciddoc&qutser=$qutser&tser=$tser&tdocno=$tdocno&user=$user';
    // print('In_tran_select_fine_inv>>> $url');
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

  Future<Null> read_GC_fine(IntentsTransModel inv) async {
    if (contractxFineModels.isNotEmpty) {
      setState(() {
        contractxFineModels.clear();
      });
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var ren = preferences.getString('renTalSer');
    // var zone = preferences.getString('zoneSer');
    var ciddoc = inv.cid;
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
            Expanded(child: _buildLeftListItems()),
            // _buildLeftBottomActions(),
          ],
        ));
  }

  // ================= Helpers for Right Panel =================
  var nFormat = NumberFormat("#,##0.00", "en_US");

  double _d(dynamic v) {
    final s = (v ?? '0').toString().trim();
    return double.tryParse(s.isEmpty ? '0' : s) ?? 0;
  }

  String _fmtNum(dynamic v) => nFormat.format(_d(v));

  String _fmtDate(String? iso) {
    try {
      return DateFormat('dd-MM-yyyy')
          .format(DateTime.parse('${(iso ?? '').trim()} 00:00:00'));
    } catch (_) {
      return '';
    }
  }

  TextStyle _baseStyle({
    Color? color,
    TextDecoration? deco,
    Color? decoColor,
    FontWeight? weight,
  }) {
    return TextStyle(
      color: color ?? PeopleChaoScreen_Color.Colors_Text2_,
      fontFamily: Font_.Fonts_T,
      fontWeight: weight,
      decoration: deco,
      decorationColor: decoColor,
    );
  }

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

  Widget _buildRightHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.deepPurple, // _headerBrown
        // color: Color(0xFF6D4C41), // _headerBrown
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Text(
        (select_page == 2)
            ? 'รายละเอียดรายการรอชำระ (${selectedDocNo ?? " - "})'
            : 'รายละเอียดบิล (${selectedDocNo ?? " - "})',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildRightTable() {
    return Column(
      children: [
        if (select_page == 1) ...[
          _buildRightTableHeader(),
          _buildRightTable_Page1(),
        ] else if (select_page == 2) ...[
          _buildRightTableHeader(), // Or different header?
          Expanded(child: _buildRightTable_Page2()),
        ]
      ],
    );
  }

  Widget _buildRightTableHeader() {
    return Container(
        color: const Color(0xFFD7CCC8), // Light brown header background
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: (select_page == 1)
            ? Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text('ลำดับ', textAlign: TextAlign.center)),
                  Expanded(
                      flex: 2,
                      child: Text('วันที่', textAlign: TextAlign.center)),
                  Expanded(
                      flex: 3,
                      child: Text('รายการ', textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1, child: Text('vat', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 1, child: Text('wht', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 2, child: Text('ยอด', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 2, child: Text('ส่วนลด', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 2,
                      child: Text('ยอดสุทธิ', textAlign: TextAlign.end)),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                          onPressed: () async {
                            await de_Trans_item_inv(index: 0, types: 'All');
                            await _resetToInitialState(
                                targetPage: 1, billAll: false);
                          },
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red[300],
                            size: 16,
                          )),
                    ),
                  ),
                ],
              )
            : Row(
                children: const [
                  Expanded(
                      flex: 1,
                      child: Text('ลำดับ', textAlign: TextAlign.center)),
                  Expanded(
                      flex: 2,
                      child: Text('วันที่', textAlign: TextAlign.center)),
                  Expanded(
                      flex: 3,
                      child: Text('รายการ', textAlign: TextAlign.center)),
                  Expanded(
                      flex: 1, child: Text('vat', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 1, child: Text('wht', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 2, child: Text('ยอด', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 2, child: Text('ส่วนลด', textAlign: TextAlign.end)),
                  Expanded(
                      flex: 2,
                      child: Text('ยอดสุทธิ', textAlign: TextAlign.end)),
                  SizedBox(width: 3), // For delete icon
                ],
              ));
  }

  Widget _buildRightTable_Page1() {
    // Show details from _TransModels (populated by red_Trans_select2 via select)
    if (_TransModels.isEmpty) {
      return const Expanded(child: Center(child: Text('ไม่พบรายการ')));
    }

    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
        ),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _TransModels.length,
          itemBuilder: (BuildContext context, int index) {
            final item = _TransModels[index];
            // final date = _fmtDate(item.date);
            // Note: TransModel might not have 'date' field explicitly exposed or it might be named differently.
            // Let's assume 'date' exists or use current date or empty if not found.
            // Checking TransModel in payment_intents.dart, it seems to have date.

            final docno = item.docno ?? '';
            final cid = item.refno ?? '';
            final qty =
                '1'; // Default to 1 as usually trans items are single lines

            // Amounts
            final amt = _d(item.amt);
            final vat = _d(item.vat);
            final wht = _d(item.wht);
            final total_net = (_d(item.amt) + _d(item.vat)) - (_d(item.wht));
            final dis = _d(item.dis);
            final total = _d(item.total);
            final totalfine = _d(item.fine);

            return Container(
                padding: EdgeInsetsDirectional.all(2),
                // padding:
                //     const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.black12)),
                ),
                child: Column(children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: Text('${index + 1}',
                              textAlign: TextAlign.center,
                              style: _baseStyle())),
                      Expanded(
                          flex: 2,
                          child: Text(cid,
                              textAlign: TextAlign.center,
                              style: _baseStyle())),
                      Expanded(
                          flex: 3,
                          child: Text(docno,
                              textAlign: TextAlign.center,
                              style: _baseStyle())),
                      // Expanded(
                      //     flex: 1,
                      //     child: Text(qty,
                      //         textAlign: TextAlign.end, style: _baseStyle())),

                      Expanded(
                          flex: 1,
                          child: Text(_fmtNum(vat),
                              textAlign: TextAlign.end, style: _baseStyle())),
                      Expanded(
                          flex: 1,
                          child: Text(_fmtNum(wht),
                              textAlign: TextAlign.end, style: _baseStyle())),
                      Expanded(
                          flex: 2,
                          child: Text(_fmtNum(total_net),
                              textAlign: TextAlign.end, style: _baseStyle())),
                      Expanded(
                          flex: 2,
                          child: Text(_fmtNum(dis),
                              textAlign: TextAlign.end, style: _baseStyle())),
                      Expanded(
                          flex: 2,
                          child: Text(_fmtNum(total),
                              textAlign: TextAlign.end, style: _baseStyle())),
                      Expanded(
                          flex: 1,
                          child: SizedBox(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                  onPressed: () async {
                                    await de_Trans_item_inv(
                                        index: index, types: 'Item');
                                    // setState(() {
                                    //   Refpay_1 = null;
                                    //   Refpay_2 = null;
                                    //   Refpay_3 = null;
                                    // });
                                  },
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.red[300],
                                    size: 16,
                                  )),
                            ),
                          )),
                    ],
                  ),
                  if (_TransModels[index].fine != '0.00')
                    Row(
                      children: [
                        Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                          flex: 2,
                          child: Icon(
                            Icons.subdirectory_arrow_right,
                            color: Colors.red,
                            size: 14,
                          ),
                        ),
                        Expanded(
                            flex: 3,
                            child: Text('ค่าปรับ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontFamily: Font_.Fonts_T,
                                ))),
                        Expanded(flex: 4, child: SizedBox()),
                        Expanded(
                            flex: 2,
                            child: Text(_fmtNum(totalfine),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  fontFamily: Font_.Fonts_T,
                                ))),
                        Expanded(
                            flex: 1,
                            child: SizedBox(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                    onPressed: () async {
                                      PanaraConfirmDialog.showAnimatedGrow(
                                        context,
                                        title: "ทำรายการ",
                                        message: "ปรับลดค่าปรับ หรือ ลบรายการ",
                                        confirmButtonText: "ลบรายการ",
                                        cancelButtonText: "ปรับลดค่าปรับ",
                                        onTapConfirm: () async {
                                          await _updateFineTransaction(
                                              index, '0');
                                          if (mounted) Navigator.pop(context);
                                        },
                                        onTapCancel: () {
                                          Navigator.pop(context);
                                          _showReduceFineDialog(context, index);
                                        },
                                        panaraDialogType:
                                            PanaraDialogType.warning,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.red[300],
                                      size: 16,
                                    )),
                              ),
                            )),
                      ],
                    ),
                ]));
          },
        ),
      ),
    );
  }

  Widget _buildRightTable_Page2() {
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
                              final hasFee = (m.listfee?.isNotEmpty ?? false);

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
                                            if (hasFee)
                                              ...m.listfee!.map<Widget>((f) {
                                                final total = (f.total as num?)
                                                        ?.toDouble() ??
                                                    _d(f.total);
                                                if (total <= 0)
                                                  return const SizedBox
                                                      .shrink();

                                                return subRow(
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
                                                    cellSub(
                                                      data:
                                                          '${f.expname ?? 'ค่าปรับ'}',
                                                      flex: 2,
                                                      align: TextAlign.start,
                                                    ),
                                                    cellSub(
                                                        data: '',
                                                        flex: 1,
                                                        align: TextAlign.start),
                                                    cellSub(
                                                        data: '',
                                                        flex: 1,
                                                        align: TextAlign.end),
                                                    cellSub(
                                                      data: _fmtNum(f.pvat),
                                                      flex: 1,
                                                      align: TextAlign.end,
                                                    ),
                                                    cellSub(
                                                      data: _fmtNum(f.vat),
                                                      flex: 1,
                                                      align: TextAlign.end,
                                                    ),
                                                    cellSub(
                                                      data: _fmtNum(f.wht),
                                                      flex: 1,
                                                      align: TextAlign.end,
                                                    ),
                                                    cellSub(
                                                      data: _fmtNum(total),
                                                      flex: 1,
                                                      align: TextAlign.end,
                                                    ),
                                                  ],
                                                );
                                              }).toList(),
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

  Widget _buildLeftTopTabs() {
    return SizedBox(
      width: 500,
      height: 56,
      child: Row(
        children: [
          // Tab 1: รายการตั้งหนี้
          Expanded(
            child: InkWell(
              onTap: () async {
                // await _resetToInitialState(targetPage: 0, billAll: false);

                setState(() {
                  select_page = 1;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      select_page == 1 ? Colors.green.withOpacity(0.1) : null,
                  border: Border(
                    bottom: BorderSide(
                      color: select_page == 1 ? Colors.green : Colors.black12,
                      width: select_page == 1 ? 3 : 1,
                    ),
                  ),
                ),
                child: Text(
                  'รายการวางบิล',
                  style: TextStyle(
                    fontWeight:
                        select_page == 1 ? FontWeight.bold : FontWeight.normal,
                    color: select_page == 1 ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // Tab 2: Payment Intents
          Expanded(
            child: InkWell(
              onTap: () async {
                await _resetToInitialState(targetPage: 2, billAll: false);

                setState(() {
                  select_page = 2;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      select_page == 2 ? Colors.green.withOpacity(0.1) : null,
                  border: Border(
                    bottom: BorderSide(
                      color: select_page == 2 ? Colors.green : Colors.black12,
                      width: select_page == 2 ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  'รายการรอชำระ',
                  style: TextStyle(
                    fontWeight:
                        select_page == 2 ? FontWeight.bold : FontWeight.normal,
                    color: select_page == 2 ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _searchBar() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        // fontSize: 22.0,
        color: TextHome_Color.TextHome_Colors,
      ),
      decoration: InputDecoration(
        filled: true,
        // fillColor: Colors.white,
        hintText: ' Search...',
        hintStyle: const TextStyle(
          // fontSize: 20.0,
          color: TextHome_Color.TextHome_Colors,
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
      onChanged: (text) {},
    );
  }

  Widget _buildLeftSubTabs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border:
                  select_page == 0 ? null : Border.all(color: Colors.black12),
            ),
            child: Text(
              'ค้นรายชื่อ',
              style: TextStyle(
                color: select_page == 0 ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: _searchBar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftListHeader() {
    List datalist = [
      {
        'ser': 1,
        'pn': 'เลขที่สัญญา',
      },
      {
        'ser': 2,
        'pn': 'เลขที่วางบิล',
      },
      {
        'ser': 3,
        'pn': 'กำหนดชำระ',
      },
      {
        'ser': 4,
        'pn': 'ส่วนลด',
      },
      {
        'ser': 5,
        'pn': 'ยอดรวม',
      }
    ];
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
          ...datalist.map((m) {
            return Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Text(
                    '${m['pn']}',
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
            );
          })
        ],
      ),
    );
  }

  Widget _buildLeftListItems() {
    bool _isAlreadyInvInPaymentIntent(InvoiceReModel bill) {
      return paymentIntents.any(
          (pi) => pi.invoices.any((inv) => inv.billReference == bill.docno));
    }

    // Grouping logic
    Map<String, List<InvoiceReModel>> grouped = {};
    for (var inv in InvoiceModels) {
      String key = inv.custno ?? '-';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(inv);
    }

    return Container(
      // height: 420,
      decoration: const BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: (select_page == 1)
          ? ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: grouped.keys.length,
              itemBuilder: (BuildContext context, int groupIndex) {
                String custno = grouped.keys.elementAt(groupIndex);
                List<InvoiceReModel> groupItems = grouped[custno]!;
                String cname = groupItems.first.cname ??
                    '-'; // Correctly get name from item
                String totalDocs = groupItems.first.total_docs ??
                    '-'; // Correctly get name from item
                String pserInv = groupItems.first.payser ??
                    '-'; // Correctly get name from item
                final bool isExpanded = _expandedGroupIndex == groupIndex;

                return ExpansionTile(
                  key: Key(
                      '$custno-$groupIndex-$isExpanded'), // Unique key to force rebuild on state change
                  title: Text(
                    '$custno : $cname (${totalDocs})',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                      fontSize: 14,
                    ),
                  ),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (bool expanded) async {
                    if (expanded) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      );
                      await red_InvoiceSelectbill(Cust: custno);

                      setState(() {
                        _expandedGroupIndex = groupIndex;
                      });

                      try {
                        // // User requirement: "await redPaymentIntents(); ให้เสร็จก่อน"
                        // await redPaymentIntents(
                        //     cusno: custno, propertyno: renTal_user ?? '');
                      } catch (e) {
                        // Handle error
                      } finally {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    } else {
                      if (_expandedGroupIndex == groupIndex) {
                        setState(() {
                          _expandedGroupIndex = null;
                        });
                      }
                    }
                  },
                  children: () {
                    // Group by payser
                    Map<String, List<InvoiceReModel>> byPayser =
                        {}; // payser -> List
                    for (var inv in limitedList_InvoiceModels_) {
                      String k = inv.payser ?? '';
                      if (!byPayser.containsKey(k)) byPayser[k] = [];
                      byPayser[k]!.add(inv);
                    }

                    return byPayser.entries.map((entry) {
                      final subList = entry.value;
                      final first = subList.first;
                      // Determine Title
                      String bankName = '';
                      for (final e in _PayMentModels) {
                        if ('${e.ser}' == '${first.payser}') {
                          bankName = '${e.bank}';
                          break;
                        }
                      }
                      String bank = '';
                      String title = bankName.isNotEmpty
                          ? bankName
                          : (first.ptname ?? '-');

                      String titleBno =
                          bankName.isNotEmpty ? first.bno! : (first.bno ?? '-');

                      for (final e in _PayMentModels) {
                        if ('${e.ser}' == '${first.payser}') {
                          bank = '${e.bank}';
                          break;
                        }
                      }

                      final bankInfo = bankCodeMap[bank];
                      final logoFile = bankInfo?['logo'] ?? 'default.png';
                      String thisGroupKey = '${first.custno}-${first.payser}';

                      return ExpansionTile(
                          // backgroundColor: Colors.grey.shade100.withOpacity(0.5),
                          key: Key(
                              '$thisGroupKey-${subList.length}-$_expandedInnerGroupKey'),
                          initiallyExpanded:
                              _expandedInnerGroupKey == thisGroupKey,
                          onExpansionChanged: (bool expanded) async {
                            if (expanded) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                },
                              );
                              await de_Trans_item_inv(index: 0, types: 'All');

                              setState(() {
                                selectedPaymentKey = null;
                                if (expanded) {
                                  _expandedInnerGroupKey = thisGroupKey;
                                } else {
                                  if (_expandedInnerGroupKey == thisGroupKey) {
                                    _expandedInnerGroupKey = null;
                                  }
                                }
                              });

                              try {
                                int _toU16(String? v) =>
                                    (int.tryParse((v ?? '0').trim()) ?? 0) +
                                    65535; // ✅ 16-bit unsigned (0..65535)

                                String? custno16Bit =
                                    _toU16('$custno').toString();
                                final ren16Bit = _toU16('$renTal_user');

                                // User requirement: "await redPaymentIntents(); ให้เสร็จก่อน"
                                // await Future.delayed(const Duration(
                                //     seconds: 2)); // Simulate loading delay
                                await redPaymentIntents(
                                    cusno: custno16Bit,
                                    propertyno: ren16Bit.toString() ?? '');
                                for (final e in _PayMentModels) {
                                  if ('${e.ser}' == '${first.payser}') {
                                    selectedPaymentKey = '${e.ser}:${e.ptname}';
                                    setState(() {
                                      paymentSer1 = '${e.ser}';
                                      payment_ptSer1 = '${e.ptser}';
                                    });

                                    break;
                                  }
                                }
                                // await red_InvoiceSelectbill(Cust: custno);
                              } catch (e) {
                                // Handle error
                              } finally {
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }
                              }
                            } else {
                              if (_expandedInnerGroupKey == thisGroupKey) {
                                setState(() {
                                  _expandedInnerGroupKey = null;
                                });
                              }
                            }
                          },
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
                          title: Text('$title (${subList.length})',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.blueGrey)),
                          subtitle: Text('$titleBno',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.blueGrey)),
                          children: [
                            FutureBuilder(
                                future:
                                    Future.delayed(const Duration(seconds: 1)),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState !=
                                      ConnectionState.done) {
                                    return const SizedBox(
                                      height: 100,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return Column(
                                    children: subList.map((rowInv) {
                                      // --- Inner Item Logic ---
                                      // Use indexWhere because rowInv might be a new instance from limitedList_InvoiceModels_
                                      // int index = limitedList_InvoiceModels_
                                      //    .indexWhere((inv) => inv.docno == rowInv.docno);
                                      final isSelectedSpecific =
                                          (_TransModels.any(
                                              (A) => A.docno == rowInv.docno));
                                      // selectedDocNo == rowInv.docno;
                                      final alreadyIntent =
                                          _isAlreadyInvInPaymentIntent(rowInv);

                                      // Find bank name for logic (re-find to be safe for rowInv specific, though grouped)
                                      String bank = '';
                                      for (final e in _PayMentModels) {
                                        if ('${e.ser}' == '${rowInv.payser}') {
                                          bank = '${e.bank}';
                                          break;
                                        }
                                      }

                                      final bankInfo = bankCodeMap[bank];
                                      final logoFile =
                                          bankInfo?['logo'] ?? 'default.png';

                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 0),
                                        child: Material(
                                          color: Colors.grey.shade200
                                              .withOpacity(0.5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: alreadyIntent
                                                  ? Colors.red.shade100
                                                  : (isSelectedSpecific
                                                      ? tappedIndex_Color
                                                          .tappedIndex_Colors
                                                      : null),
                                              border: const Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey,
                                                    width: 0.3),
                                              ),
                                            ),
                                            child: ListTile(
                                              leading: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                child: Icon(
                                                  Icons
                                                      .subdirectory_arrow_right,
                                                  color: Colors.grey,
                                                  size: 16,
                                                ),
                                              ),
                                              onTap: (alreadyIntent ||
                                                      isSelectedSpecific)
                                                  ? null
                                                  : () async {
                                                      if (_tapBusy) return;
                                                      if (mounted)
                                                        setState(() =>
                                                            _tapBusy = true);

                                                      try {
                                                        if (mounted) {
                                                          await in_Trans_select(
                                                              rowInv);

                                                          // 1) รอให้โหลด/select เสร็จก่อน
                                                          // await red_Trans_select(
                                                          //     rowInv);

                                                          // // 2) ทำต่อหลัง select เสร็จ (เหมือนใน then)
                                                          // await in_Trans_dis_inv(
                                                          //     rowInv);

                                                          // // 3) เงื่อนไขเดิม
                                                          // if (contractxFineModels
                                                          //     .isNotEmpty) {
                                                          //   in_Trans_fine_re(rowInv);
                                                          //   // red_Trans_select2_fin(); // ถ้าจะใช้ค่อยเปิด
                                                          // }
                                                          setState(() {
                                                            cidSelect =
                                                                rowInv.cid;
                                                            selectedDocNo =
                                                                rowInv.docno;
                                                          });
                                                        }
                                                      } catch (e) {
                                                        // debugPrint('onTap error: $e');
                                                      } finally {
                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    300));
                                                        if (mounted)
                                                          setState(() =>
                                                              _tapBusy = false);
                                                      }
                                                    },
                                              dense: true,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      rowInv.cid ?? '',
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            Font_.Fonts_T,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: AutoSizeText(
                                                      rowInv.docno ?? '',
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              Font_.Fonts_T),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      _fmtNum(rowInv.total_dis),
                                                      minFontSize: 8,
                                                      maxFontSize: 14,
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                })
                          ]);
                    }).toList();
                  }(),
                );
              },
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: grouped.keys.length,
              itemBuilder: (BuildContext context, int groupIndex) {
                String custno = grouped.keys.elementAt(groupIndex);
                List<InvoiceReModel> groupItems = grouped[custno]!;
                String cname = groupItems.first.cname ??
                    '-'; // Correctly get name from item
                String totalDocs = groupItems.first.total_docs ??
                    '-'; // Correctly get name from item
                String pserInv = groupItems.first.payser ??
                    '-'; // Correctly get name from item
                final bool isExpanded = _expandedGroupIndex == groupIndex;

                return ExpansionTile(
                  key: Key(
                      '$custno-$groupIndex-$isExpanded'), // Unique key to force rebuild on state change
                  title: Text(
                    '$custno : $cname',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                      fontFamily: Font_.Fonts_T,
                      fontSize: 14,
                    ),
                  ),
                  initiallyExpanded: isExpanded,
                  onExpansionChanged: (bool expanded) async {
                    if (expanded) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      );
                      /* int _toU16(String? v) =>
                          (int.tryParse((v ?? '0').trim()) ?? 0) +
                          65535; */ // Moved to class method

                      String? custno16Bit = _toU16('$custno').toString();
                      final ren16Bit = _toU16('$renTal_user');

                      // User requirement: "await redPaymentIntents(); ให้เสร็จก่อน"
                      await redPaymentIntents(
                          cusno: custno16Bit, propertyno: ren16Bit.toString());

                      setState(() {
                        _expandedGroupIndex = groupIndex;
                        this.custno = custno;
                        this.renTal_user = '$renTal_user';
                      });

                      try {
                        // Logic moved above
                      } catch (e) {
                        // Handle error
                      } finally {
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    } else {
                      if (_expandedGroupIndex == groupIndex) {
                        setState(() {
                          _expandedGroupIndex = null;
                        });
                      }
                    }
                  },
                  children: [
                    ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: paymentIntents.length,
                      itemBuilder: (BuildContext context, int index) {
                        final intent = paymentIntents[index];
                        // หา bank name จาก _PayMentModels ด้วย bankmerchantid
                        final matchBank = _PayMentModels.firstWhere(
                          (e) => '${e.ser}' == '${intent.bankmerchantid}',
                          orElse: () => PayMentModel(),
                        );
                        String bank = matchBank.bank ?? '';

                        final bankInfo = bankCodeMap[bank];
                        final logoFile = bankInfo?['logo'] ?? 'default.png';
                        final bankCode = bankInfo?['code'] ?? '';
                        final bankEn = bankInfo?['en'] ?? bank;
                        // intentsCustno = intent.customerNo;
                        // setState(() {
                        //   intentsCustno = intent.customerNo;
                        // });

                        return Material(
                          color: (selectedDocNo == intent.intentNo)
                              ? tappedIndex_Color.tappedIndex_Colors
                              : AppbackgroundColor.Sub_Abg_Colors,
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
                                  selectedDocNo = intent.intentNo;
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
                                          const Row(
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
                                      intent.intentNo ?? '-',
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
                    ),
                  ],
                );
              },
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
        // sum_tran_dis -
        dis_sum_Matjum;

    String _fmtDT(DateTime? d) =>
        d == null ? '-' : DateFormat('d-MM-yyyy HH:mm').format(d.toLocal());

    // -------- footer texts --------
    final sumFineTotalFooter = _fmtN(
      _TransModels.fold<num>(
        0,
        (sum, item) => sum + (num.tryParse(item.fine.toString()) ?? 0),
      ),
    );

    final sumPvatFooter = _fmtN(sum_pvat);
    final sumVatFooter = _fmtN(sum_vat);
    final sumWhtFooter = _fmtN(sum_wht);
    final sumNetFooter = _fmtN(_netPayAmount);
    final sumTotalFooter = _fmtN(sum_amt + (_asDouble(sumFineTotalFooter)));
    final sumDislistFooter = _fmtN(sum_tran_dis);
    final sumAllTotalFooter =
        _fmtN(_netPayAmount + _asDouble(sumFineTotalFooter));

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
                        readOnly: select_page == 2 ? true : false,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        decoration:
                            InputDecoration.collapsed(hintText: 'หมายเหตุ'),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // ---------------- Right summary / intent card ----------------
              Expanded(
                flex: 6,
                child: (select_page == 2)
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

                          final amountIntents =
                              firstIntent.requestedAmount ?? 0;

                          return Column(children: [
                            _buildSummaryRow('ประเภท', paymentName1 ?? ""),
                            _buildSummaryRow('ธนาคาร', '$paybname'),
                            _buildSummaryRow('เลขที่บัญชี', '$paybno'),
                            _buildSummaryRow('วันที่สร้าง', intentCreatedAt),
                            _buildSummaryRow(
                                'วันที่หมดอายุ', intentSoftExpireAt),

                            // _buildSummaryRow('วันที่อัพเดต', intentUpdatedAt),
                            _buildSummaryRow('ยอดชำระ', _fmtN(amountIntents)),
                          ]);
                        },
                      )
                    : Column(
                        children: [
                          // _buildSummaryRow(
                          //     'จำนวน(ใบเสร็จ)', '${_TransModels.length}'),
                          const SizedBox(height: 4),
                          _buildSummaryRow('รวม', sumNetFooter),
                          _buildSummaryRow('ค่าปรับ', sumFineTotalFooter),

                          // _buildSummaryRow('ภาษีมูลค่าเพิ่ม(vat)', sumVatFooter),
                          // _buildSummaryRow('หัก ณ ที่จ่าย', sumWhtFooter),
                          // _buildSummaryRow('ยอดรวม', sumTotalFooter),
                          // _buildSummaryRow('ส่วนลดรายการ', sumDislistFooter),

                          const SizedBox(height: 4),

                          // ---------------- ส่วนลด ----------------
                          // _buildSummaryRow('ส่วนลด', sumTotalFooter),
                          // Row(
                          //   children: [
                          //     const Expanded(
                          //       child: Text('ส่วนลด(ท้ายบิล)',
                          //           style: TextStyle(fontSize: 12)),
                          //     ),
                          //     const SizedBox(width: 8),
                          //     SizedBox(
                          //       width: 100,
                          //       height: 24,
                          //       child: TextField(
                          //         controller: sum_disamtx,
                          //         keyboardType: TextInputType.number,
                          //         textAlign: TextAlign.end,
                          //         decoration: const InputDecoration(
                          //           border: OutlineInputBorder(),
                          //           contentPadding: EdgeInsets.symmetric(
                          //               horizontal: 4, vertical: 0),
                          //         ),
                          //         onChanged: (value) async {
                          //           final totalFooter = _netPayAmount;
                          //           final valuenum = _asDouble(value);

                          //           setState(() {
                          //             if (value.isEmpty) {
                          //               sum_disamtx.text = '0.00';
                          //             } else if (_asDouble(value) > totalFooter) {
                          //               sum_disamtx.text = '0.00';
                          //             } else {
                          //               sum_dis = valuenum;
                          //               sum_disamt = valuenum;
                          //               sum_dispx.clear();
                          //               Form_payment1.text =
                          //                   _netPayAmount.toStringAsFixed(2);
                          //             }
                          //           });
                          //         },
                          //         inputFormatters: <TextInputFormatter>[
                          //           FilteringTextInputFormatter.allow(
                          //               RegExp(r'[0-9 .]')),
                          //         ],
                          //         style: const TextStyle(
                          //           fontSize: 12,
                          //           fontFamily: Font_.Fonts_T,
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 8),
                          _buildSummaryRow('ยอดชำระ', sumAllTotalFooter,
                              isTotal: true),
                        ],
                      ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ---------------- Pay Now ----------------
          if (select_page == 1) ...[
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
                          // onChanged: (value) {
                          //   setState(() {
                          //     selectedPaymentKey = value;
                          //     var it = _PayMentModels.firstWhere(
                          //         (e) => '${e.ser}:${e.ptname}' == value);
                          //     paymentSer1 = it.ser;
                          //     payment_ptSer1 = it.ptser;
                          //   });
                          // },
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
                        onPressed: (_TransModels.isEmpty)
                            ? null
                            : () async {
                                bool dialogShown = false;

                                try {
                                  // เปิด loading (ใช้ rootNavigator กัน pop ผิดอัน)
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    useRootNavigator: true,
                                    builder: (_) => const Center(
                                        child: CircularProgressIndicator()),
                                  );
                                  dialogShown = true;

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final ren =
                                      prefs.getString('renTalSer') ?? '';
                                  final ren16Bit = _toU16(ren).toString();

                                  final String custnoLocal =
                                      (numCustno != null) ? '$numCustno' : '';
                                  final custno16Bit =
                                      _toU16(custnoLocal).toString();

                                  // parse ที่รองรับ comma
                                  final All_lateFee = double.tryParse(
                                          Form_fine.text.replaceAll(',', '')) ??
                                      0.0;
                                  final All_discountAmount = double.tryParse(
                                          sum_disamtx.text
                                              .replaceAll(',', '')) ??
                                      0.0;

                                  const All_depositAmount = 0.0;
                                  const All_insuranceAmount = 0.0;
                                  const All_withholdingAmount = 0.0;

                                  // ---------- สะสมข้อมูลใน local ก่อน (ไม่ setState ใน loop) ----------
                                  final List<IntentsInvoiceHistoryModel>
                                      invoiceHistoryAll = [];
                                  final List<InvoiceDisPayModel>
                                      invoiceDisPayAll = [];
                                  final List<IntentsContractxFineModel>
                                      contractxFineAll = [];
                                  final List<Map<String, dynamic>> invs = [];

                                  for (final rowInv in _TransModels) {
                                    if (!mounted) return;

                                    await red_Trans_select(rowInv);
                                    await in_Trans_dis_inv(rowInv);
                                    await read_GC_fine(rowInv);

                                    if (contractxFineModels.isNotEmpty) {
                                      await in_Trans_fine_re(rowInv);
                                    }

                                    // ใช้ “ของรอบนี้” แล้วค่อย add เข้า all
                                    invoiceHistoryAll
                                        .addAll(_InvoiceHistoryModels);
                                    invoiceDisPayAll
                                        .addAll(_InvoiceDisPayModels);
                                    contractxFineAll
                                        .addAll(contractxFineModels);

                                    final invFine = await GC_Inv_fine(
                                        docno: rowInv.docno.toString());
                                    final double fineTotal =
                                        (invFine['total'] as num?)
                                                ?.toDouble() ??
                                            0.0;

                                    final List<Map<String, dynamic>>
                                        listFineINV =
                                        (invFine['ok'] == true && fineTotal > 0)
                                            ? [
                                                {
                                                  "docno": rowInv.docno,
                                                  "expser": int.tryParse(
                                                          '${invFine['expser'] ?? 0}') ??
                                                      0,
                                                  "expname":
                                                      invFine['expname'] ??
                                                          "ชำระเกินกำหนด",
                                                  "no": int.tryParse(
                                                          '${invFine['no'] ?? 0}') ??
                                                      0,
                                                  "pvat":
                                                      (invFine['pvat'] as num?)
                                                              ?.toDouble() ??
                                                          0.0,
                                                  "vser": int.tryParse(
                                                          '${invFine['vser'] ?? 0}') ??
                                                      0,
                                                  "vtype":
                                                      invFine['vtype'] ?? '',
                                                  "nvat":
                                                      (invFine['nvat'] as num?)
                                                              ?.toInt() ??
                                                          0,
                                                  "vat":
                                                      (invFine['vat'] as num?)
                                                              ?.toDouble() ??
                                                          0.0,
                                                  "wht":
                                                      (invFine['wht'] as num?)
                                                              ?.toDouble() ??
                                                          0.0,
                                                  "total": fineTotal,
                                                }
                                              ]
                                            : [];

                                    final List<Map<String, dynamic>>
                                        metadataList = _InvoiceHistoryModels
                                            .map<Map<String, dynamic>>((b) {
                                      final totalBill =
                                          double.tryParse('${b.total ?? 0}') ??
                                              0.0;

                                      return {
                                        'expname': '${b.expname ?? ''}',
                                        'docno': '${b.refno ?? ''}',
                                        'date': (b.date is DateTime)
                                            ? (b.date as DateTime)
                                                .toIso8601String()
                                            : b.date,
                                        'cid': '${b.cid ?? ''}',
                                        'payser':
                                            int.tryParse('$paymentSer1') ?? 0,
                                        'pri_bill':
                                            double.tryParse('${b.pri ?? 0}') ??
                                                0.0,
                                        'pvat_bill':
                                            double.tryParse('${b.pvat ?? 0}') ??
                                                0.0,
                                        'vat_bill':
                                            double.tryParse('${b.vat ?? 0}') ??
                                                0.0,
                                        'nvat':
                                            int.tryParse('${b.nvat ?? 0}') ??
                                                0, // ✅ int
                                        'wht_bill':
                                            double.tryParse('${b.wht ?? 0}') ??
                                                0.0,
                                        'late_fee': 0,
                                        'list_fee': <Map<String,
                                            dynamic>>[], // ของบรรทัดนี้
                                        'total_bill': totalBill,
                                        'selected': rowInv.docno,
                                      };
                                    }).toList();

                                    final pvat = _d(rowInv.pvat);
                                    final vat = _d(rowInv.vat);
                                    final wht = _d(rowInv.wht);
                                    final amtnet = (_d(rowInv.amt) + vat) - wht;
                                    final dis = _d(rowInv.dis);
                                    final total = _d(rowInv.total);
                                    final totalfine = _d(rowInv.fine);

                                    invs.add({
                                      "invoice_id": 0,
                                      "bill_reference": rowInv.docno,
                                      "amount": amtnet,
                                      "late_fee": totalfine,
                                      "discount_amount": dis,
                                      "deposit_amount": 0,
                                      "insurance_amount": 0,
                                      "withholding_amount": 0,
                                      "total": total,
                                      "list_fee": listFineINV,
                                      "metadata": metadataList,
                                    });
                                  }

                                  // sync state ครั้งเดียว
                                  // ✅ sync state ครั้งเดียว (อัปเดตตัวแปรใน class/state)
                                  if (!mounted) return;
                                  setState(() {
                                    _invoiceHistory
                                      ..clear()
                                      ..addAll(invoiceHistoryAll);

                                    _invoiceDisPay
                                      ..clear()
                                      ..addAll(invoiceDisPayAll);

                                    _contractxFine
                                      ..clear()
                                      ..addAll(contractxFineAll);
                                  });

                                  if (custno16Bit.isEmpty ||
                                      ren16Bit.isEmpty ||
                                      ren16Bit == '65535') {
                                    Dialog_error(
                                        context, 'ข้อมูลไม่ครบถ้วน #65535');
                                    return;
                                  }

                                  await PostPaymentIntents(
                                    cusNo: custno16Bit,
                                    propertyNo: ren16Bit,
                                    payedType: "invoice",
                                    payser: int.tryParse('$paymentSer1') ?? 0,
                                    typepayser:
                                        int.tryParse('$payment_ptSer1') ?? 0,
                                    requestedAmount:
                                        _netPayAmount + _d(sumFineTotalFooter),
                                    lateFee: All_lateFee,
                                    discountAmount: All_discountAmount,
                                    depositAmount: All_depositAmount,
                                    insuranceAmount: All_insuranceAmount,
                                    withholdingAmount: All_withholdingAmount,
                                    inVoices: invs,
                                    transselect: invoiceHistoryAll
                                        .map((e) => e.toJson())
                                        .toList(),
                                  );

                                  await redPaymentIntents(
                                    cusno: custno16Bit,
                                    propertyno: ren16Bit,
                                  );
                                } catch (e, st) {
                                  // อย่างน้อย print จะช่วยไล่บั๊กได้
                                  debugPrint('onPressed error: $e');
                                  debugPrint('$st');
                                } finally {
                                  if (!mounted) return;

                                  setState(() {
                                    selectedPaymentKey = null;
                                    _expandedInnerGroupKey = null;
                                  });

                                  await _resetToInitialState(
                                      targetPage: 1, billAll: false);

                                  if (dialogShown &&
                                      Navigator.of(context, rootNavigator: true)
                                          .canPop()) {
                                    Navigator.of(context, rootNavigator: true)
                                        .pop();
                                  }
                                }
                              },

                        // onPressed: (_TransModels.length < 1)
                        //     ? null
                        //     : () async {
                        //         try {
                        //           showDialog(
                        //             context: context,
                        //             barrierDismissible: false,
                        //             builder: (BuildContext context) {
                        //               return const Center(
                        //                   child: CircularProgressIndicator());
                        //             },
                        //           );
                        //           final prefs =
                        //               await SharedPreferences.getInstance();
                        //           final ren = prefs.getString('renTalSer');

                        //           final ren16Bit = _toU16('$ren').toString();

                        //           // custno ใช้ตัวเดียว (ทุก invoice ลูกค้าเดียวกัน)
                        //           final String custnoLocal =
                        //               numCustno != null ? '$numCustno' : '';

                        //           final custno16Bit =
                        //               _toU16(custnoLocal).toString();
                        //           final All_lateFee =
                        //               double.tryParse(Form_fine.text) ?? 0.0;
                        //           final All_discountAmount =
                        //               double.tryParse(sum_disamtx.text) ?? 0.0;
                        //           final All_depositAmount = 0.0;
                        //           final All_insuranceAmount = 0.0;
                        //           final All_withholdingAmount = 0.0;

                        //           // ----------
                        //           List<IntentsInvoiceHistoryModel>
                        //               _InvoiceHistory = [];
                        //           List<InvoiceDisPayModel> _InvoiceDisPay = [];
                        //           List<IntentsContractxFineModel>
                        //               contractxFine = [];
                        //           final List<Map<String, dynamic>> invs = [];

                        //           // ---------- dteilData ----------
                        //           for (var Indexinv = 0;
                        //               Indexinv < _TransModels.length;
                        //               Indexinv++) {
                        //             final rowInv = _TransModels[Indexinv];
                        //             // 1) รอให้โหลด/select เสร็จก่อน
                        //             await red_Trans_select(rowInv);

                        //             // 2) ทำต่อหลัง select เสร็จ (เหมือนใน then)
                        //             await in_Trans_dis_inv(rowInv);

                        //             await read_GC_fine(rowInv);

                        //             // 3) เงื่อนไขเดิม
                        //             if (contractxFineModels.isNotEmpty) {
                        //               await in_Trans_fine_re(rowInv);
                        //             }
                        //             setState(() {
                        //               _InvoiceHistory.addAll(
                        //                   _InvoiceHistoryModels);
                        //               _InvoiceDisPay.addAll(
                        //                   _InvoiceDisPayModels);
                        //               contractxFine.addAll(contractxFineModels);
                        //             });
                        //             final refnosSelected =
                        //                 _InvoiceHistoryModels.map(
                        //                     (m) => m.refno).toSet().join(',');

                        //             final invFine = await GC_Inv_fine(
                        //                 docno: rowInv.docno.toString());
                        //             final double fineTotal =
                        //                 (invFine['total'] as num?)
                        //                         ?.toDouble() ??
                        //                     0.0;

                        //             final List<Map<String, dynamic>>
                        //                 listFineINV =
                        //                 (invFine['ok'] == true && fineTotal > 0)
                        //                     ? [
                        //                         {
                        //                           "docno": rowInv.docno,
                        //                           "expser": int.tryParse(
                        //                                   '${invFine['expser'] ?? 0}') ??
                        //                               0,
                        //                           "expname":
                        //                               invFine['expname'] ??
                        //                                   "ชำระเกินกำหนด",
                        //                           "no": int.tryParse(
                        //                                   '${invFine['no'] ?? 0}') ??
                        //                               0,
                        //                           "pvat":
                        //                               (invFine['pvat'] as num?)
                        //                                       ?.toDouble() ??
                        //                                   0.0,
                        //                           "vser": int.tryParse(
                        //                                   '${invFine['vser'] ?? 0}') ??
                        //                               0,
                        //                           "vtype":
                        //                               invFine['vtype'] ?? '',
                        //                           "nvat":
                        //                               (invFine['nvat'] as num?)
                        //                                       ?.toInt() ??
                        //                                   0,
                        //                           "vat":
                        //                               (invFine['vat'] as num?)
                        //                                       ?.toDouble() ??
                        //                                   0.0,
                        //                           "wht":
                        //                               (invFine['wht'] as num?)
                        //                                       ?.toDouble() ??
                        //                                   0.0,
                        //                           "total": fineTotal,
                        //                         }
                        //                       ]
                        //                     : [];

                        //             // ---------- metadata (Use CURRENT invoice history, not accumulated) ----------
                        //             final List<Map<String, dynamic>>
                        //                 metadataList = _InvoiceHistoryModels
                        //                     .map<Map<String, dynamic>>((b) {
                        //               final expname = '${b.expname ?? ''}';
                        //               final totalBill =
                        //                   double.tryParse('${b.total ?? 0}') ??
                        //                       0.0;
                        //               final List<Map<String, dynamic>>
                        //                   listFine = []; // ✅ สำคัญมาก
                        //               return {
                        //                 'expname': expname,
                        //                 'docno': '${b.refno ?? ''}',
                        //                 'date': (b.date is DateTime)
                        //                     ? (b.date as DateTime)
                        //                         .toIso8601String()
                        //                     : b.date,
                        //                 'cid': '${b.cid ?? ''}',
                        //                 // 'custno': custno16Bit,
                        //                 // 'st': '${b.st ?? ''}',
                        //                 // 'status': '',
                        //                 'payser':
                        //                     int.tryParse('$paymentSer1') ?? 0,
                        //                 // 'docno_all': refnosSelected,
                        //                 'pri_bill':
                        //                     double.tryParse('${b.pri ?? 0}') ??
                        //                         0.0,
                        //                 'pvat_bill':
                        //                     double.tryParse('${b.pvat ?? 0}') ??
                        //                         0.0,
                        //                 'vat_bill':
                        //                     double.tryParse('${b.vat ?? 0}') ??
                        //                         0.0,
                        //                 'nvat':
                        //                     int.tryParse('${b.nvat ?? 0}') ??
                        //                         0.0,
                        //                 'wht_bill':
                        //                     double.tryParse('${b.wht ?? 0}') ??
                        //                         0.0,
                        //                 'late_fee': 0,
                        //                 'list_fee': listFine,
                        //                 'total_bill': totalBill,
                        //                 'selected': rowInv.docno,
                        //               };
                        //             }).toList();

                        //             final pvat = _d(rowInv.pvat);
                        //             final vat = _d(rowInv.vat);
                        //             final wht = _d(rowInv.wht);
                        //             final amtnet =
                        //                 (_d(rowInv.amt) + _d(rowInv.vat)) -
                        //                     _d(rowInv.wht);
                        //             final dis = _d(rowInv.dis);
                        //             final total = _d(rowInv.total);
                        //             final totalfine = _d(rowInv.fine);
                        //             // ---------- invoices ----------
                        //             invs.add({
                        //               "invoice_id": 0,
                        //               "bill_reference": rowInv.docno,
                        //               "amount": amtnet,
                        //               "late_fee": totalfine,
                        //               "discount_amount": dis,
                        //               "deposit_amount": 0, // ถ้ามี
                        //               "insurance_amount": 0, // ถ้ามี
                        //               "withholding_amount": 0,
                        //               "total": total,
                        //               "list_fee": listFineINV, // ✅ ใส่ตรงนี้
                        //               "metadata": metadataList,
                        //             });
                        //           }

                        //           print({
                        //             'cusNo': custno16Bit,
                        //             'propertyNo': ren16Bit,
                        //             'payedType': "invoice",
                        //             'payser': int.tryParse('$paymentSer1') ?? 0,
                        //             'typepayser':
                        //                 int.tryParse('$payment_ptSer1') ?? 0,
                        //             'requestedAmount': _netPayAmount +
                        //                 _d(sumFineTotalFooter), // ✅ ไม่ใช้ string format
                        //             'inVoices': invs,
                        //             'transselect':
                        //                 _InvoiceHistory.map((e) => e.toJson())
                        //                     .toList(),
                        //           });
                        //           if (custno16Bit.isEmpty ||
                        //               ren16Bit.isEmpty ||
                        //               ren16Bit.toString() == '65535') {
                        //             return Dialog_error(
                        //                 context, 'ข้อมูลไม่ครบถ้วน #65535');
                        //           } else {
                        //             await PostPaymentIntents(
                        //               cusNo: custno16Bit,
                        //               propertyNo: ren16Bit,
                        //               payedType: "invoice",
                        //               payser: int.tryParse('$paymentSer1') ?? 0,
                        //               typepayser:
                        //                   int.tryParse('$payment_ptSer1') ?? 0,
                        //               requestedAmount: _netPayAmount +
                        //                   _d(sumFineTotalFooter), // ✅ ไม่ใช้ string format
                        //               lateFee: All_lateFee,
                        //               discountAmount: All_discountAmount,
                        //               depositAmount: All_depositAmount,
                        //               insuranceAmount: All_insuranceAmount,
                        //               withholdingAmount: All_withholdingAmount,
                        //               inVoices: invs,
                        //               transselect:
                        //                   _InvoiceHistory.map((e) => e.toJson())
                        //                       .toList(),
                        //             );
                        //             await redPaymentIntents(
                        //                 cusno: custno16Bit,
                        //                 propertyno: ren16Bit.toString() ?? '');
                        //           }
                        //         } catch (e) {
                        //         } finally {
                        //           setState(() {
                        //             selectedPaymentKey = null;
                        //             _expandedInnerGroupKey = null;
                        //           });
                        //           await _resetToInitialState(
                        //               targetPage: 1, billAll: false);
                        //           if (mounted) {
                        //             Navigator.of(context).pop();
                        //           }
                        //         }
                        //       },
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
                              : 'รับชำระทันที',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  // paymentSer1 = '${e.ser}:${e.ser}';
                  //                     payment_ptSer1 = '${e.ser}:${e.ptser}';
                ],
              ),
            ),
          ] else if (select_page == 2) ...[
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
                                          int _toU16(String? v) =>
                                              (int.tryParse(
                                                      (v ?? '0').trim()) ??
                                                  0) +
                                              65535; // ✅ 16-bit unsigned (0..65535)

                                          // User requirement: "await redPaymentIntents(); ให้เสร็จก่อน"
                                          // await Future.delayed(const Duration(
                                          //     seconds: 2)); // Simulate loading delay
                                          await redPaymentIntents(
                                              cusno: custno16Bit,
                                              propertyno:
                                                  ren16Bit.toString() ?? '');
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
    final imgUrl =
        '${MyConstant().domain}/files/$renTal_foder/payment/${payimg ?? ''}';
    // (MyConstant().domain) + '/$renTal_name/' + '/payment/' + (payimg ?? '');
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
            ? '|$bno\r$ref1\r$ref2\r${amtRaw.replaceAll('.', '')}'
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
        maxHeight: 1.0, anchors: const [1.0], // ✅ ล็อกตาย ไม่มีให้ลาก
        // anchors: const [0.48, 0.55, 1.0],
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
                                                                      child:
                                                                          InteractiveViewer(
                                                                        panEnabled:
                                                                            true,
                                                                        boundaryMargin:
                                                                            const EdgeInsets.all(20),
                                                                        minScale:
                                                                            0.1,
                                                                        maxScale:
                                                                            4,
                                                                        child: Image
                                                                            .network(
                                                                          payimg!.isNotEmpty && payimg != '' && payimg != 'null'
                                                                              ? imgUrl
                                                                              : 'https://www.shutterstock.com/image-vector/no-qr-code-icon-vector-260nw-1815277187.jpg',
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              qrSize + qrSize,
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
                                                                              height: qrSize + qrSize,
                                                                              child: Center(
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
                                                                              width: double.infinity,
                                                                              height: qrSize + qrSize,
                                                                              color: Colors.grey.shade200,
                                                                              alignment: Alignment.center,
                                                                              child: Column(
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

                                                                      // Image
                                                                      //     .network(
                                                                      //   payimg!.isNotEmpty &&
                                                                      //           payimg != '' &&
                                                                      //           payimg != 'null'
                                                                      //       ? imgUrl
                                                                      //       : 'https://www.shutterstock.com/image-vector/no-qr-code-icon-vector-260nw-1815277187.jpg',
                                                                      //   width: double
                                                                      //       .infinity,
                                                                      //   height: qrSize +
                                                                      //       qrSize,
                                                                      //   fit: BoxFit
                                                                      //       .contain,
                                                                      //   loadingBuilder: (context,
                                                                      //       child,
                                                                      //       progress) {
                                                                      //     if (progress ==
                                                                      //         null) {
                                                                      //       return child;
                                                                      //     }
                                                                      //     return SizedBox(
                                                                      //       height:
                                                                      //           qrSize + qrSize,
                                                                      //       child:
                                                                      //           Center(
                                                                      //         child: CircularProgressIndicator(
                                                                      //           value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null,
                                                                      //         ),
                                                                      //       ),
                                                                      //     );
                                                                      //   },
                                                                      //   errorBuilder: (context,
                                                                      //       error,
                                                                      //       stackTrace) {
                                                                      //     return Container(
                                                                      //       width:
                                                                      //           double.infinity,
                                                                      //       height:
                                                                      //           qrSize + qrSize,
                                                                      //       color:
                                                                      //           Colors.grey.shade200,
                                                                      //       alignment:
                                                                      //           Alignment.center,
                                                                      //       child:
                                                                      //           Column(
                                                                      //         mainAxisAlignment: MainAxisAlignment.center,
                                                                      //         children: const [
                                                                      //           Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                                                                      //           SizedBox(height: 8),
                                                                      //           Text(
                                                                      //             'ไม่สามารถโหลด QR ได้',
                                                                      //             style: TextStyle(
                                                                      //               fontFamily: Font_.Fonts_T,
                                                                      //               color: Colors.black54,
                                                                      //               fontSize: 13,
                                                                      //             ),
                                                                      //           ),
                                                                      //         ],
                                                                      //       ),
                                                                      //     );
                                                                      //   },
                                                                      // ),
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
                                                                            'กรุณาชำระเงินผ่านช่องทางด้านล่าง หากชำระแล้วกรุณาแนบหลักฐานการชำระเงิน',
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

  Future<bool> _pickSlipImage() async {
    final completer = Completer<bool>();
    // Web only: use FileUploadInputElement
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isEmpty) return;
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((e) {
        setState(() {
          _slipImageBytes = reader.result as Uint8List?;
          _slipImageName = file.name;
        });
        completer.complete(true);
      });
    });
    return completer.future;
  }

  int _toU16(String? v) =>
      (int.tryParse((v ?? '0').trim()) ?? 0) +
      65535; // ✅ 16-bit unsigned (0..65535)

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
        int _toU16(String? v) =>
            (int.tryParse((v ?? '0').trim()) ?? 0) +
            65535; // ✅ 16-bit unsigned (0..65535)

        String? custno16Bit = _toU16('$custno').toString();
        final ren16Bit = _toU16('$renTal_user');

        // User requirement: "await redPaymentIntents(); ให้เสร็จก่อน"
        // await Future.delayed(const Duration(
        //     seconds: 2)); // Simulate loading delay
        await redPaymentIntents(
            cusno: custno16Bit, propertyno: ren16Bit.toString() ?? '');
        // Reload payment intents to reflect updated status
        // await redPaymentIntents();
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

  Widget _slipInfoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  color: Colors.black54,
                  fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              val,
              style: TextStyle(
                  fontFamily: Font_.Fonts_T,
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'PENDING':
        return 'รอตรวจสอบ';
      case 'APPROVED':
        return 'อนุมัติแล้ว';
      case 'REJECTED':
        return 'ไม่อนุมัติ';
      default:
        return status ?? '-';
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
