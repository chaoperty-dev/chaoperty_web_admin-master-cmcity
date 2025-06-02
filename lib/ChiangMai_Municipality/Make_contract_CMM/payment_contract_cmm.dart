import 'dart:convert';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../Constant/Myconstant.dart';
import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetPayMent_Model.dart';
import '../../PeopleChao/webviewPay.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../Model/Payments_Model.dart';
import '../unity/API_addfile_payment.dart';
import '../unity/API_payment.dart';
import '../unity/API_renTal.dart';
import '../unity/PickThaiDate.dart';
import '../unity/UploadFileSlip_base64.dart';
import '../unity/show_dialog_cmm.dart';

class BillPaymentScreen extends StatefulWidget {
  final uuid_Request;
  final response_Post_payment;
  String payment_uuid;
  String payment_amount;
  List<Map<String, dynamic>> payment_jsonx;

  BillPaymentScreen(
      {super.key,
      this.uuid_Request,
      this.response_Post_payment,
      required this.payment_uuid,
      required this.payment_amount,
      required this.payment_jsonx});
  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  late Future<String> _translatedText;
  var nFormat = NumberFormat("#,##0.00", "en_US");
  final Form_payment1 = TextEditingController();
  final Form_payment2 = TextEditingController();
  final Form_time = TextEditingController();
  List<PaymentsModelCMM> paymentsmodel = [];
  List<ExpAutoModel> expAutoModels = [];
  DateTime selectedDate = DateTime.now();
  String paymentMethod = 'พร้อมเพย์ (QR)';
  double amount = 500.00;
  String? selectedFileName;

  String? Value_newDateY = '',
      Value_newDateD = '',
      Value_newDateY1 = '',
      Value_newDateD1 = '';
  String? base64_Slip, fileName_Slip;
  String? paymentbcode1,
      paymentbcode2,
      paymentSer1,
      paymentName1,
      paymentSer2,
      paymentName2,
      newValuePDFimg_QR,
      foder;
  String _getPaymentTypeText(String ptser) {
    switch (ptser) {
      case '1':
        return '( รับชำระแบบเงินสด )';
      case '2':
        return '( แนบรูป QR เอง )';
      case '5':
        return '( ระบบ Gen PromptPay QR )';
      case '6':
        return '( ระบบ Gen Standard QR )';
      case '7':
        return '( ตัวกลางรับชำระ )';
      case '8':
        return '( AIP รับชำระ ชอยส์ )';
      default:
        return '';
    }
  }

  String? name_isBcode, name_bankTH, name_banknames;
  bool? name_isCash;
  dynamic valueBodyPost = {};
  String? uuid_postpayment;
  List<Map<String, dynamic>> jsonx = [];
  final _formKey_pay = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    red_setdata();
    red_payMent();
    red_Rental();
    Value_newDateY1 = DateFormat('yyyy-MM-dd').format(selectedDate);
    Value_newDateD1 = DateFormat('dd-MM-yyyy').format(selectedDate);
    Value_newDateY = DateFormat('yyyy-MM-dd').format(selectedDate);
    Value_newDateD = DateFormat('dd-MM-yyyy').format(selectedDate);

    Form_time.text = DateFormat('HH:mm:ss', 'th').format(selectedDate);
    _translatedText = Future.delayed(
      const Duration(milliseconds: 500),
      () => translateText('รับชำระ'),
    );
  }

  var TypeStyle1 = TextStyle(
    color: PeopleChaoScreen_Color.Colors_Text1_,
    fontWeight: FontWeight.w600,
    fontFamily: FontWeight_.Fonts_T,
    //fontSize: 10.0
  );
  var TypeStyle2 = TextStyle(
    color: PeopleChaoScreen_Color.Colors_Text1_,

    fontFamily: Font_.Fonts_T,
    //fontSize: 10.0
  );
  /////////----------------------------------------------------------->
  int TitleType_Default_Typepay = 0;
  double sum_pvat = 0.00,
      sum_vat = 0.00,
      sum_wht = 0.00,
      sum_amt = 0.00,
      sum_dis = 0.00,
      sum_disamt = 0.00,
      sum_disp = 0,
      sum_Pakan = 0,
      sum_Pakan_KF = 0,
      dis_Pakan = 0,
      dis_matjum = 0,
      dis_sum_Pakan = 0.00,
      dis_sum_Matjum = 0.00,
      sum_Matjum_KF = 0,
      sum_tran_dis = 0,
      sum_matjum = 0.00,
      sum_tran_fine = 0,
      sum_tran_fine_amt = 0,
      fine_total = 0,
      fine_total2 = 0,
      sum_tran_fine_vat = 0,
      sum_dislist = 0;
  var renTal_name, Refpay_1, Refpay_2, Refpay_3, Pay_Ke;
  String? payment_ptSer1, payment_ptSer2;
  String? selectedValue, selectedValue2;
  String? bname1, bname2;
  int? ser_paymentMethodId;
  /////////----------------------------------------------------------->
  var extension_;
  var file_;

  Future<void> red_Rental() async {
    final result = await read_GC_rental();
    if (result != null) {
      setState(() {
        foder = result.dbn;
      });
    }
  }

  final List<Map<String, dynamic>> _roles = [
    // {"name": "Super Admin", "desc": "Having full access rights", "role": 1},
  ];
  List<PaymentsModelCMM> _list = [];
  // List<Map<String, dynamic>> jsonx = [];
  // Loading_Data_Step3() async {
  //   // var uuid_user = 'd87fec79-6020-449f-8b8b-724e4d6a0d4c';

  //   // print('Loading_Data_Step3');
  //   // print(result);
  //   setState(() {
  //     expAutoModels.addAll(
  //       jsonx.map((e) => ExpAutoModel.fromJson(e)).toList(),
  //     );
  //   });
  // }

  Future<void> red_setdata() async {
    setState(() {
      expAutoModels.clear();
      jsonx = widget.payment_jsonx;
    });
    // ตรวจสอบว่ามี response_Post_payment จากการ POST หรือไม่
    print("ตรวจสอบว่ามี response_Post_payment จากการ POST หรือไม่");
    print("payment_jsonx : ${widget.payment_jsonx}");
    print("payment_jsonx : $jsonx");
    print("response_Post_payment : ${widget.response_Post_payment}");

    if (widget.payment_uuid != null) {
      setState(() {
        uuid_postpayment = widget.payment_uuid.toString();
        expAutoModels.addAll(
          jsonx.map((e) => ExpAutoModel.fromJson(e)).toList(),
        );
      });
    } else if (widget.response_Post_payment != null &&
        widget.response_Post_payment.body.isNotEmpty) {
      try {
        final Map<String, dynamic> responseBody =
            jsonDecode(widget.response_Post_payment.body);
        print(
            "responseBody json: ${responseBody['data']['json'].map((e) => ExpAutoModel.fromJson(e)).toList()}");
        setState(() {
          uuid_postpayment = responseBody['data']['uuid'] ?? '';
          expAutoModels.addAll(
            responseBody['data']['json']
                .map((e) => ExpAutoModel.fromJson(e))
                .toList(),
          );
        });
      } catch (e) {
        print('❌ ไม่สามารถ decode response ได้: $e');
      }
    }

    print('📌 uuid_postpayment: $uuid_postpayment');
  }

  Future<void> red_payMent() async {
    print('🔄 เรียกใช้งาน red_payMent  ***');

    // โหลดข้อมูลการชำระเงิน
    final result = await read_GC_payment();
    print('📥 โหลดรายการวิธีชำระเงิน2: ${result.length} รายการ');

    if (result.isNotEmpty) {
      setState(() {
        paymentsmodel = result;
        _list = result
            .map((payment) => PaymentsModelCMM(
                  id: payment.id,
                  uuid: payment.uuid,
                  code: payment.code,
                  name_th: payment.name_th,
                  meta: payment.meta,
                ))
            .toList();
      });

      for (var payment in _list) {
        print('✅ วิธีชำระ: ${payment.name_th}');
      }
    } else {
      print('⚠️ ไม่พบข้อมูลวิธีชำระเงิน');
    }
  }

  final _formKey = GlobalKey<FormState>();
  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: Font_.Fonts_T,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: Font_.Fonts_T,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  ////////------------------------->
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildBillDetails(),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: buildPaymentSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBillDetails() {
    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade300,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0)),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'รายละเอียดบิล',
                style: TypeStyle1,
              ),
            ),
          ),
          Expanded(
              child: Column(
            children: [
              // หัวตาราง
              Container(
                color: Colors.brown.shade300,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    _buildHeaderCell('ลำดับ', flex: 1),
                    // _buildHeaderCell('กำหนดชำระ', flex: 2),
                    _buildHeaderCell('รายการ', flex: 1),
                    _buildHeaderCell('จำนวน', flex: 1),
                    _buildHeaderCell('หน่วย', flex: 1),
                    // _buildHeaderCell('VAT', flex: 1),
                    // _buildHeaderCell('WHT', flex: 1),
                    _buildHeaderCell('ยอดสุทธิ', flex: 1),
                  ],
                ),
              ),

              // ตารางข้อมูล
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(expAutoModels.length, (index) {
                        final exp = expAutoModels[index];
                        return InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                              ),
                            ),
                            // color:
                            //     index % 2 == 0 ? Colors.white : Colors.grey[50],
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                _buildCell('${index + 1}', flex: 1),
                                // _buildCell(
                                //     DateFormat('dd-MM-yyyy')
                                //         .format(selectedDate),
                                //     flex: 2),
                                // _buildCell('${exp.sday}', flex: 3),
                                _buildCell('${exp.expname}', flex: 1),
                                _buildCell('1', flex: 1),
                                _buildCell('${exp.unit}', flex: 1),
                                // _buildCell('${exp.unit}', flex: 1),
                                _buildCell(
                                    '${double.parse(exp.pri_auto.toString()) ?? 0.00}',
                                    flex: 1),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          )),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 0),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.1),
                      //     spreadRadius: 2,
                      //     blurRadius: 6,
                      //     offset: const Offset(0, 2),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      children: [
                        // Container(
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         flex: 1,
                        //         child: Translate.TranslateAndSetText(
                        //             'รวม',
                        //             PeopleChaoScreen_Color.Colors_Text2_,
                        //             TextAlign.start,
                        //             null,
                        //             Font_.Fonts_T,
                        //             12,
                        //             1),
                        //         //  AutoSizeText(
                        //         //   minFontSize: 10,
                        //         //   maxFontSize: 15,
                        //         //   'รวม',
                        //         //   style: TextStyle(
                        //         //       color: PeopleChaoScreen_Color
                        //         //           .Colors_Text2_,
                        //         //       //fontWeight: FontWeight.bold,
                        //         //       fontFamily: Font_
                        //         //           .Fonts_T),
                        //         // ),
                        //       ),
                        //       Expanded(
                        //         flex: 1,
                        //         child: AutoSizeText(
                        //           minFontSize: 8,
                        //           maxFontSize: 12,
                        //           textAlign: TextAlign.end,
                        //           '${nFormat.format(sum_pvat)}',
                        //           style: const TextStyle(
                        //               color:
                        //                   PeopleChaoScreen_Color.Colors_Text2_,
                        //               //fontWeight: FontWeight.bold,
                        //               fontFamily: Font_.Fonts_T),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       flex: 1,
                        //       child: Translate.TranslateAndSetText(
                        //           'ภาษีมูลค่าเพิ่ม(vat)',
                        //           PeopleChaoScreen_Color.Colors_Text2_,
                        //           TextAlign.start,
                        //           null,
                        //           Font_.Fonts_T,
                        //           12,
                        //           1),
                        //       // AutoSizeText(
                        //       //   minFontSize: 10,
                        //       //   maxFontSize: 15,
                        //       //   'ภาษีมูลค่าเพิ่ม(vat)',
                        //       //   style: TextStyle(
                        //       //       color: PeopleChaoScreen_Color
                        //       //           .Colors_Text2_,
                        //       //       //fontWeight: FontWeight.bold,
                        //       //       fontFamily: Font_
                        //       //           .Fonts_T),
                        //       // ),
                        //     ),
                        //     Expanded(
                        //       flex: 1,
                        //       child: AutoSizeText(
                        //         minFontSize: 8,
                        //         maxFontSize: 12,
                        //         textAlign: TextAlign.end,
                        //         '${nFormat.format(sum_vat)}',
                        //         style: const TextStyle(
                        //             color: PeopleChaoScreen_Color.Colors_Text2_,
                        //             //fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       flex: 1,
                        //       child: Translate.TranslateAndSetText(
                        //           'หัก ณ ที่จ่าย',
                        //           PeopleChaoScreen_Color.Colors_Text2_,
                        //           TextAlign.start,
                        //           null,
                        //           Font_.Fonts_T,
                        //           12,
                        //           1),
                        //       //  AutoSizeText(
                        //       //   minFontSize: 10,
                        //       //   maxFontSize: 15,
                        //       //   'หัก ณ ที่จ่าย',
                        //       //   style: TextStyle(
                        //       //       color: PeopleChaoScreen_Color
                        //       //           .Colors_Text2_,
                        //       //       //fontWeight: FontWeight.bold,
                        //       //       fontFamily: Font_
                        //       //           .Fonts_T),
                        //       // ),
                        //     ),
                        //     Expanded(
                        //       flex: 1,
                        //       child: AutoSizeText(
                        //         minFontSize: 8,
                        //         maxFontSize: 12,
                        //         textAlign: TextAlign.end,
                        //         '${nFormat.format(sum_wht)}',
                        //         style: const TextStyle(
                        //             color: PeopleChaoScreen_Color.Colors_Text2_,
                        //             //fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       flex: 1,
                        //       child: Translate.TranslateAndSetText(
                        //           'ยอดรวม',
                        //           PeopleChaoScreen_Color.Colors_Text2_,
                        //           TextAlign.start,
                        //           null,
                        //           Font_.Fonts_T,
                        //           12,
                        //           1),
                        //       //  AutoSizeText(
                        //       //   minFontSize: 10,
                        //       //   maxFontSize: 15,
                        //       //   'ยอดรวม',
                        //       //   style: TextStyle(
                        //       //       color: PeopleChaoScreen_Color
                        //       //           .Colors_Text2_,
                        //       //       //fontWeight: FontWeight.bold,
                        //       //       fontFamily: Font_
                        //       //           .Fonts_T),
                        //       // ),
                        //     ),
                        //     Expanded(
                        //       flex: 1,
                        //       child: AutoSizeText(
                        //         minFontSize: 8,
                        //         maxFontSize: 12,
                        //         textAlign: TextAlign.end,
                        //         '${nFormat.format(sum_amt - (fine_total + fine_total2))}',
                        //         style: const TextStyle(
                        //             color: PeopleChaoScreen_Color.Colors_Text2_,
                        //             //fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // fine_total == 0.00
                        //     ? SizedBox()
                        //     : Row(
                        //         children: [
                        //           Expanded(
                        //             flex: 1,
                        //             child: Translate.TranslateAndSetText(
                        //                 'ค่าธรรมเนียม',
                        //                 Colors.red,
                        //                 TextAlign.start,
                        //                 null,
                        //                 Font_.Fonts_T,
                        //                 12,
                        //                 1),
                        //             //     AutoSizeText(
                        //             //   minFontSize: 10,
                        //             //   maxFontSize: 15,
                        //             //   'ค่าธรรมเนียม',
                        //             //   style: TextStyle(
                        //             //       color: Colors.red,
                        //             //       //fontWeight: FontWeight.bold,
                        //             //       fontFamily: Font_.Fonts_T),
                        //             // ),
                        //           ),
                        //           Expanded(
                        //             flex: 1,
                        //             child: AutoSizeText(
                        //               minFontSize: 8,
                        //               maxFontSize: 12,
                        //               textAlign: TextAlign.end,
                        //               '${nFormat.format(fine_total + fine_total2)}',
                        //               style: const TextStyle(
                        //                   color: Colors.red,
                        //                   //fontWeight: FontWeight.bold,
                        //                   fontFamily: Font_.Fonts_T),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        // sum_dislist != 0
                        //     ? Row(
                        //         children: [
                        //           Expanded(
                        //             flex: 2,
                        //             child: Row(
                        //               children: [
                        //                 Translate.TranslateAndSetText(
                        //                     'ส่วนลดรายการ',
                        //                     PeopleChaoScreen_Color
                        //                         .Colors_Text2_,
                        //                     TextAlign.start,
                        //                     null,
                        //                     Font_.Fonts_T,
                        //                     12,
                        //                     1),
                        //               ],
                        //             ),
                        //           ),
                        //           Expanded(
                        //             flex: 1,
                        //             child: AutoSizeText(
                        //               minFontSize: 8,
                        //               maxFontSize: 12,
                        //               '${nFormat.format(sum_dislist)}',
                        //               textAlign: TextAlign.end,
                        //               style: TextStyle(
                        //                   color: PeopleChaoScreen_Color
                        //                       .Colors_Text2_,
                        //                   //fontWeight: FontWeight.bold,
                        //                   fontFamily: Font_.Fonts_T),
                        //             ),
                        //             // AutoSizeText(
                        //             //   minFontSize: 10,
                        //             //   maxFontSize: 15,
                        //             //   textAlign: TextAlign.end,
                        //             //   '${nFormat.format(0.00)}',
                        //             //   style: TextStyle(
                        //             //       color: PeopleChaoScreen_Color
                        //             //           .Colors_Text2_,
                        //             //       //fontWeight: FontWeight.bold,
                        //             //       fontFamily: Font_.Fonts_T),
                        //             // ),
                        //           ),
                        //         ],
                        //       )
                        //     : SizedBox(),
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       flex: 2,
                        //       child: Row(
                        //         children: [
                        //           Translate.TranslateAndSetText(
                        //               'ส่วนลด',
                        //               PeopleChaoScreen_Color.Colors_Text2_,
                        //               TextAlign.start,
                        //               null,
                        //               Font_.Fonts_T,
                        //               12,
                        //               1),
                        //           // const AutoSizeText(
                        //           //   minFontSize: 10,
                        //           //   maxFontSize: 15,
                        //           //   'ส่วนลด',
                        //           //   style: TextStyle(
                        //           //       color: PeopleChaoScreen_Color
                        //           //           .Colors_Text2_,
                        //           //       //fontWeight: FontWeight.bold,
                        //           //       fontFamily: Font_
                        //           //           .Fonts_T),
                        //           // ),
                        //           const SizedBox(
                        //             width: 10,
                        //           ),
                        //           SizedBox(
                        //             width: 60,
                        //             height: 20,
                        //             child: AutoSizeText(
                        //               minFontSize: 8,
                        //               maxFontSize: 12,
                        //               '$sum_disp  %',
                        //               style: const TextStyle(
                        //                   color: PeopleChaoScreen_Color
                        //                       .Colors_Text2_,
                        //                   //fontWeight: FontWeight.bold,
                        //                   fontFamily: Font_.Fonts_T),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     Expanded(
                        //       flex: 1,
                        //       child: AutoSizeText(
                        //         minFontSize: 8,
                        //         maxFontSize: 12,
                        //         '${nFormat.format(sum_disamt)}',
                        //         textAlign: TextAlign.end,
                        //         style: const TextStyle(
                        //             color: PeopleChaoScreen_Color.Colors_Text2_,
                        //             //fontWeight: FontWeight.bold,
                        //             fontFamily: Font_.Fonts_T),
                        //       ),
                        //       // AutoSizeText(
                        //       //   minFontSize: 10,
                        //       //   maxFontSize: 15,
                        //       //   textAlign: TextAlign.end,
                        //       //   '${nFormat.format(0.00)}',
                        //       //   style: TextStyle(
                        //       //       color: PeopleChaoScreen_Color
                        //       //           .Colors_Text2_,
                        //       //       //fontWeight: FontWeight.bold,
                        //       //       fontFamily: Font_.Fonts_T),
                        //       // ),
                        //     ),
                        //   ],
                        // ),
                        Center(
                          child: Translate.TranslateAndSetText(
                              'ยอดสุทธิรับชำระ',
                              PeopleChaoScreen_Color.Colors_Text2_,
                              TextAlign.start,
                              null,
                              Font_.Fonts_T,
                              12,
                              1),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Translate.TranslateAndSetText(
                                    'ยอดชำระ',
                                    PeopleChaoScreen_Color.Colors_Text2_,
                                    TextAlign.start,
                                    null,
                                    Font_.Fonts_T,
                                    12,
                                    1),
                                // AutoSizeText(
                                //   minFontSize: 10,
                                //   maxFontSize: 15,
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
                                  maxFontSize: 12,
                                  textAlign: TextAlign.end,
                                  '${nFormat.format(sum_amt - sum_disamt - sum_tran_dis - dis_sum_Matjum)}',
                                  style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      //fontWeight: FontWeight.bold,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppBarColors.hexColor.withOpacity(0.7),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              // border: Border.all(
              //     color: Colors.grey, width: 1),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                InkWell(
                  child: Icon(
                    Icons.bubble_chart_rounded,
                    // Icons.next_plan,
                    color: Colors.grey[300],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.green[200]!.withOpacity(0.5),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        // border: Border.all(
                        //     color: Colors.grey, width: 1),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Center(
                        child: Translate.TranslateAndSetText(
                            'รับชำระ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {},
                  child: Icon(
                    Icons.sync_sharp,
                    // Icons.next_plan,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 50,
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  padding: const EdgeInsets.all(8.0),
                  child: Translate.TranslateAndSetText(
                      'ยอดชำระรวม',
                      PeopleChaoScreen_Color.Colors_Text2_,
                      TextAlign.start,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      1),
                  // Text(
                  //   'ยอดชำระรวม',
                  //   textAlign: TextAlign.start,
                  //   style: TextStyle(
                  //       color:
                  //           PeopleChaoScreen_Color.Colors_Text1_,
                  //       fontWeight: FontWeight.bold,
                  //       fontFamily: FontWeight_.Fonts_T
                  //       //fontSize: 10.0
                  //       ),
                  // ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  height: 50,
                  color: AppbackgroundColor.Sub_Abg_Colors,
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[50]!.withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      // border: Border.all(
                      //     color: Colors.grey, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        // '${nFormat.format(sum_amt - sum_disamt)}',
                        '${nFormat.format(500.00)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T
                            //fontSize: 10.0
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppbackgroundColor.Sub_Abg_Colors,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 🔷 แถวแรก: รูปแบบการชำระ
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Translate.TranslateAndSetText(
                            Responsive.isDesktop(context)
                                ? 'รูปแบบการชำระ'
                                : 'การชำระ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.start,
                            FontWeight.bold,
                            FontWeight_.Fonts_T,
                            14,
                            1,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.payment,
                              size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                          padding: const EdgeInsets.all(2.0),
                          child: CustomDropdown<PaymentsModelCMM>(
                            overlayHeight: 400,
                            items: _list,
                            hintText: 'เลือกรูปแบบชำระ',
                            // initialItem: _list.isNotEmpty
                            //     ? _list.first
                            //     : null, // เริ่มต้นเลือกตัวแรก ถ้ามี
                            onChanged: (PaymentsModelCMM? selectedItem) {
                              if (selectedItem != null) {
                                print('✅ พบข้อมูลช่องทางการชำระเงิน');
                                print(
                                    '➡️ UUID Method          : ${selectedItem.uuid}');
                                print(
                                    '➡️ Payment Method ID    : ${selectedItem.id}');
                                print(
                                    '➡️ Payment Code         : ${selectedItem.code}');

                                final hasMeta =
                                    selectedItem.meta?.isNotEmpty ?? false;

                                int bankId = 0;
                                if (hasMeta) {
                                  final meta = selectedItem.meta!.first;
                                  bankId = meta.bank_id ?? 0;

                                  print(
                                      '➡️ Bank ID              : ${meta.bank_id}');
                                  print(
                                      '➡️ Bank Name            : ${meta.bank_names}');
                                  print(
                                      '➡️ Bank Account         : ${meta.bank_account}');
                                } else {
                                  print(
                                      'ℹ️ ไม่มีข้อมูลธนาคาร (meta ว่างหรือไม่มี)');
                                }

                                setState(() {
                                  ser_paymentMethodId = selectedItem.id;
                                  valueBodyPost = {
                                    "requestUuid": widget.uuid_Request! ?? '',
                                    "paymentMethodId": selectedItem.id ?? 0,
                                    "paymentMethodCode": selectedItem.id ??
                                        0, // ✅ ใช้ ID (int) แทน code (String)
                                    "bankaccountId": bankId,
                                    "paidat": DateTime.now().toIso8601String(),
                                    "referencecode": "",
                                    "reference1": "",
                                    "reference2": "",
                                    "paymentAmount": 500.0,
                                  };
                                });
                              } else {
                                print('❌ selectedItem เป็น null');
                              }

                              print('----------------------------------');
                            },
                            // แสดงชื่อธนาคารใน header
                            headerBuilder: (context, item, isExpanded) =>
                                ListTile(
                              // title: Text(
                              //     item.meta != null && item.meta!.isNotEmpty
                              //         ? item.meta!.first.bank_names ?? ''
                              //         : item.name_th!),
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 11,
                                    backgroundImage: item.code! == 'CASH'
                                        ? AssetImage('images/LogoBank/CASH.png')
                                        : (item.meta != null &&
                                                item.meta!.isNotEmpty
                                            ? AssetImage(
                                                'images/LogoBank/${item.meta!.first.bcode}.png')
                                            : null),
                                    backgroundColor: (item.meta != null &&
                                            item.meta!.isNotEmpty)
                                        ? Colors.transparent
                                        : (item.code! == 'CASH')
                                            ? Colors.transparent
                                            : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(item.meta != null &&
                                            item.meta!.isNotEmpty
                                        ? item.meta!.first.bank_names ?? ''
                                        : item.name_th!),
                                  ),
                                ],
                              ),
                              subtitle: item.meta != null &&
                                      item.meta!.isNotEmpty
                                  ? Text(item.meta!.first.bank_account ?? '')
                                  : null,
                            ),
                            //  Text(
                            //   item.meta!.first.bank_names ?? '',
                            //   style: TextStyle(fontSize: 14),
                            // ),
                            // แสดงชื่อในรายการ dropdown
                            listItemBuilder:
                                (context, item, isSelected, onTap) => ListTile(
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 11,
                                    backgroundImage: item.code! == 'CASH'
                                        ? AssetImage('images/LogoBank/CASH.png')
                                        : (item.meta != null &&
                                                item.meta!.isNotEmpty
                                            ? AssetImage(
                                                'images/LogoBank/${item.meta!.first.bcode}.png')
                                            : null),
                                    backgroundColor: (item.meta != null &&
                                            item.meta!.isNotEmpty)
                                        ? Colors.transparent
                                        : (item.code! == 'CASH')
                                            ? Colors.transparent
                                            : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(item.meta != null &&
                                            item.meta!.isNotEmpty
                                        ? item.meta!.first.bank_names ?? ''
                                        : item.name_th!),
                                  ),
                                ],
                              ),
                              subtitle: item.meta != null &&
                                      item.meta!.isNotEmpty
                                  ? Text(item.meta!.first.bank_account ?? '')
                                  : null,
                              onTap: onTap,
                            ),
                            // validator: (PaymentsModelCMM? item) =>
                            //     item == null ? 'กรุณาเลือกรูปแบบชำระ' : null,
                            // validateOnChange: true,
                          )

                          //  CustomDropdown<PaymentsModelCMM>(
                          //   hintText: 'เลือกรูปแบบชำระ',
                          //   items: _list,
                          //   initialItem: _list.isNotEmpty ? _list.first : null,

                          //   onChanged: (selectedText) {
                          //     print('$selectedText');
                          //     // if (selectedText == null ||
                          //     //     !selectedText.contains(':')) {
                          //     //   print('❌ รูปแบบข้อมูลไม่ถูกต้อง: $selectedText');
                          //     //   return;
                          //     // } else {}

                          //     // if (selectedText.toString() != 'โอนผ่านธนาคาร') {
                          //     //   final matchingMethods = paymentsmodel
                          //     //       .where((method) =>
                          //     //           method.name_th?.trim() == selectedText)
                          //     //       .toList();
                          //     //   print(
                          //     //       'ไม่พบช่องทางการชำระเงินที่ตรงกับ: $matchingMethods');
                          //     // } else {
                          //     //   final separatorIndex = selectedText!.indexOf(':');
                          //     //   final selectedId = selectedText!
                          //     //       .substring(0, separatorIndex)
                          //     //       .trim();
                          //     //   final selectedAccount = selectedText
                          //     //       .substring(separatorIndex + 1)
                          //     //       .trim();

                          //     //   final matchingMethods = paymentsmodel
                          //     //       .where((method) =>
                          //     //           method.meta?.any((meta) =>
                          //     //               meta.bank_account?.trim() ==
                          //     //               selectedAccount) ??
                          //     //           false)
                          //     //       .toList();
                          //     //   if (matchingMethods.isNotEmpty) {
                          //     //     final matchedUuid = matchingMethods.first.uuid;
                          //     //     final matchedId = matchingMethods.first.id;
                          //     //     final matchedcode = matchingMethods.first.code;

                          //     //     final matchedBankId =
                          //     //         matchingMethods.first.meta!.first.bank_id;

                          //     //     print('✅ พบข้อมูลช่องทางการชำระเงิน');
                          //     //     print('➡️ UUID Method : $matchedUuid');
                          //     //     print('➡️ Payment Method ID: $matchedId');
                          //     //     print('➡️ Payment Code ID: $matchedcode');
                          //     //     print('➡️ Payment Bank ID: $matchedBankId');
                          //     //   } else {
                          //     //     print('$selectedAccount');
                          //     //   }

                          //     //   print(
                          //     //       '🔍 เลือก ID: $selectedId | บัญชี: $selectedAccount');
                          //     //   print('----------------------------------->');
                          //     // }
                          //   },

                          //   // Run validation on item selected
                          //   validateOnChange: true,
                          //   // Function to validate if the current selected item is valid or not
                          //   validator: (value) =>
                          //       value == null ? "Must not be null" : null,
                          // ),

                          //  DropdownFormField<Map<String, dynamic>>(
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     suffixIcon: Icon(Icons.arrow_drop_down),
                          //   ),
                          //   displayItemFn: (dynamic item) => Text(
                          //     name_banknames ?? '',
                          //     style: TextStyle(fontSize: 16),
                          //   ),
                          //   findFn: (dynamic str) async {
                          //     print('🔍 findFn called with: $str');
                          //     print('📦 roles: $_roles');
                          //     return _roles;
                          //   },
                          //   selectedFn: (dynamic item1, dynamic item2) {
                          //     name_banknames = item1['name'];
                          //     return item1 != null &&
                          //         item2 != null &&
                          //         item1['name'] == item2['name'];
                          //   },
                          //   dropdownItemFn: (dynamic item,
                          //           int position,
                          //           bool focused,
                          //           bool selected,
                          //           Function() onTap) =>
                          //       ListTile(
                          //     title: Text(item['name']),
                          //     subtitle: Text(item['desc'] ?? ''),
                          //     tileColor: focused
                          //         ? Color.fromARGB(20, 0, 0, 0)
                          //         : Colors.transparent,
                          //     onTap: () {
                          //       print('✅ Selected: ${item['name']}');
                          //       onTap(); // ✅ สำคัญสุด
                          //     },
                          //   ),
                          //   onChanged: (dynamic value) {
                          //     print('✅ onChanged: ${value['name']}');
                          //   },
                          // ),

                          //  DropdownButtonFormField2<String>(
                          //   decoration: InputDecoration(
                          //     isDense: true,
                          //     contentPadding: EdgeInsets.zero,
                          //     border: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //       borderSide: BorderSide(color: Colors.grey),
                          //     ),
                          //   ),
                          //   icon: Icon(Icons.arrow_drop_down,
                          //       color: Colors.grey[700], size: 20),
                          //   dropdownDecoration: BoxDecoration(
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   buttonHeight: 65,
                          //   buttonPadding:
                          //       const EdgeInsets.symmetric(horizontal: 10),
                          //   isExpanded: true,
                          //   // hint: Text(
                          //   //   selectedValue ?? '',
                          //   //   style: TextStyle(
                          //   //     fontSize: 11,
                          //   //     color: Colors.grey[600],
                          //   //     fontFamily: Font_.Fonts_T,
                          //   //   ),
                          //   //   textAlign: TextAlign.right,
                          //   // ),
                          //   items: paymentsmodel.map((item) {
                          //     final isCash =
                          //         item.code == 'CASH' || item.code == null;
                          //     final meta =
                          //         (item.meta != null && item.meta!.isNotEmpty)
                          //             ? item.meta!.first
                          //             : null;

                          //     final bcode = meta?.bcode ?? '';
                          //     final bankName = meta?.bank_names ?? '';
                          //     final bankAccount = meta?.bank_account ?? '';
                          //     final bankBranch = meta?.branch ?? '';

                          //     return DropdownMenuItem<String>(
                          //       value: item.uuid!, // UUID ไม่ซ้ำ
                          //       onTap: () {
                          //         setState(() {
                          //           paymentName1 = item.name_th;
                          //           paymentbcode1 = bcode;
                          //           selectedValue = item.uuid;
                          //           // selectedValue = item.name_th;
                          //         });
                          //       },
                          //       child: Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           Row(children: [
                          //             CircleAvatar(
                          //               radius: 11,
                          //               backgroundImage: isCash
                          //                   ? AssetImage(
                          //                       'images/LogoBank/CASH.png')
                          //                   : (bcode.isNotEmpty
                          //                       ? AssetImage(
                          //                           'images/LogoBank/$bcode.png')
                          //                       : null),
                          //               backgroundColor:
                          //                   (bcode.isEmpty && !isCash)
                          //                       ? Colors.grey[600]
                          //                       : Colors.transparent,
                          //             ),
                          //             const SizedBox(width: 6),
                          //             Expanded(
                          //               child: Text(
                          //                 bcode.isNotEmpty
                          //                     ? '$bcode : ${item.name_th}'
                          //                     : (item.name_th ?? ''),
                          //                 style: TextStyle(
                          //                   fontSize: 12,
                          //                   color: Colors.grey[800],
                          //                   fontFamily: Font_.Fonts_T,
                          //                 ),
                          //               ),
                          //             ),
                          //             Text(
                          //               bankName,
                          //               style: TextStyle(
                          //                 fontSize: 11,
                          //                 color: Colors.grey[600],
                          //                 fontFamily: Font_.Fonts_T,
                          //               ),
                          //               textAlign: TextAlign.right,
                          //             ),
                          //           ]),
                          //           const SizedBox(height: 4),
                          //           Row(children: [
                          //             Expanded(
                          //               child: Text(
                          //                 bankBranch,
                          //                 style: TextStyle(
                          //                     fontSize: 9, color: Colors.grey),
                          //               ),
                          //             ),
                          //             Expanded(
                          //               child: Text(
                          //                 bankAccount,
                          //                 textAlign: TextAlign.end,
                          //                 style: TextStyle(
                          //                     fontSize: 9,
                          //                     color: Colors.grey[600]),
                          //               ),
                          //             ),
                          //           ]),
                          //         ],
                          //       ),
                          //     );
                          //   }).toList(),
                          //   onChanged: (value) {
                          //     print(value);
                          //     setState(() {
                          //       selectedValue = value;
                          //     });
                          //   },
                          // )
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 🔷 แถวสอง: จำนวนเงิน
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 45,
                      alignment: Alignment.centerLeft,
                      child: Translate.TranslateAndSetText(
                        'จำนวนเงิน',
                        PeopleChaoScreen_Color.Colors_Text2_,
                        TextAlign.start,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Form(
                        key: _formKey_pay,
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: Form_payment1,
                            readOnly: false,
                            style: const TextStyle(
                              fontFamily: Font_.Fonts_T,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'Please data';
                            //   }
                            //   return null;
                            // },
                            cursorColor: Colors.green,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontFamily: Font_.Fonts_T,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: InputBorder.none,
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9 .]')),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // วันที่ทำรายการ
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
                          alignment: Alignment.center,
                          child: Translate.TranslateAndSetText(
                            'วันที่ทำรายการ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.bold,
                            Font_.Fonts_T,
                            14,
                            1,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () async {
                            final DateTime? newDate =
                                await pickThaiDate(context);
                            if (newDate == null) return;

                            setState(() {
                              Value_newDateY1 =
                                  DateFormat('yyyy-MM-dd').format(newDate);
                              Value_newDateD1 =
                                  DateFormat('dd-MM-yyyy').format(newDate);
                            });
                          },
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              Value_newDateD1!.isEmpty
                                  ? 'เลือกวันที่'
                                  : '$Value_newDateD1',
                              minFontSize: 10,
                              maxFontSize: 16,
                              style: TextStyle(
                                color: Colors.black87,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // วันที่ชำระ
                Expanded(
                  flex: 4,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          height: 35,
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)),
                          ),
                          alignment: Alignment.center,
                          child: Translate.TranslateAndSetText(
                            'วันที่ชำระ',
                            PeopleChaoScreen_Color.Colors_Text2_,
                            TextAlign.center,
                            FontWeight.bold,
                            Font_.Fonts_T,
                            14,
                            1,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () async {
                            final DateTime? newDate =
                                await pickThaiDate(context);
                            if (newDate == null) return;

                            setState(() {
                              Value_newDateY =
                                  DateFormat('yyyy-MM-dd').format(newDate);
                              Value_newDateD =
                                  DateFormat('dd-MM-yyyy').format(newDate);
                            });
                          },
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              Value_newDateD!.isEmpty
                                  ? 'เลือกวันที่'
                                  : '$Value_newDateD',
                              minFontSize: 10,
                              maxFontSize: 16,
                              style: TextStyle(
                                color: Colors.black87,
                                fontFamily: Font_.Fonts_T,
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
          SizedBox(
            height: 5,
          ),
          Row(children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 35,
                color: AppbackgroundColor.Sub_Abg_Colors,
                padding: const EdgeInsets.all(4.0),
                child: Center(
                  child: Translate.TranslateAndSetText(
                    ' เวลา/หลักฐาน',
                    PeopleChaoScreen_Color.Colors_Text2_,
                    TextAlign.center,
                    FontWeight.bold,
                    Font_.Fonts_T,
                    14,
                    1,
                  ),
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: Container(
                    width: 100,
                    height: 35,
                    color: AppbackgroundColor.Sub_Abg_Colors,
                    child: Center(
                        child: Row(
                      children: [
                        // ช่องกรอกเวลา
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextFormField(
                              controller: Form_time,
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.green,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.access_time,
                                    color: Colors.grey),
                                hintText: '00:00:00',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.7),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      width: 1, color: Colors.grey),
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                              inputFormatters: [
                                MaskedInputFormatter('##:##:##'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // ปุ่มอัปโหลด slip
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                            child: ElevatedButton.icon(
                                icon: Icon(base64_Slip == null
                                    ? Icons.upload_file
                                    : Icons.file_open),
                                label: Text(
                                  base64_Slip == null
                                      ? 'เพิ่มไฟล์'
                                      : 'อัพไฟล์อีกครั้ง',
                                  style: const TextStyle(
                                    fontFamily: Font_.Fonts_T,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      // Colors.green,
                                      base64_Slip == null
                                          ? Colors.green
                                          : Colors.deepOrange.shade600,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () async {
                                  Dia_log3(context); // แสดง dialog loading ก่อน

                                  final result = await PaypickAndUpload(
                                    '$uuid_postpayment',
                                    '${widget.uuid_Request}',
                                  );

                                  Navigator.of(context)
                                      .pop(); // ปิด loading dialog หลังจากเลือกไฟล์แล้ว

                                  if (result != null) {
                                    final base64 = result['base64'];
                                    final extension = result['extension'];

                                    if (base64 != null && extension != null) {
                                      setState(() {
                                        base64_Slip = base64;
                                        extension_ = extension;
                                      });
                                      Dialog_success(context, 'อัปโหลดสำเร็จ');
                                    } else {
                                      setState(() {
                                        base64_Slip = null;
                                      });
                                      Dialog_error(context,
                                          'ไม่ได้เลือกหรือเกิดข้อผิดพลาดระหว่างเลือกภาพ');
                                    }
                                  } else {
                                    setState(() {
                                      base64_Slip = null;
                                    });
                                    Dialog_error(context,
                                        'ไม่ได้เลือกหรือเกิดข้อผิดพลาดระหว่างเลือกภาพ');
                                  }
                                }),
                          ),
                        ),
                      ],
                    ))))
          ]),
          Container(
            decoration: const BoxDecoration(
              color: AppbackgroundColor.Sub_Abg_Colors,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
              // border: Border.all(color: Colors.grey, width: 1),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 4.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: base64_Slip != null
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: base64_Slip != null
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            base64_Slip != null
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            color: base64_Slip != null
                                ? Colors.green
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              base64_Slip != null
                                  ? 'เลือกไฟล์แล้ว'
                                  : 'ยังไม่ได้เลือกไฟล์',
                              style: TextStyle(
                                color: base64_Slip != null
                                    ? Colors.grey[800]
                                    : Colors.grey[800],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: base64_Slip == null
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor:
                                      AppbackgroundColor.Sub_Abg_Colors,
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(10.0),
                                  actionsPadding: const EdgeInsets.all(6.0),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // SizedBox(),
                                      // const Icon(Icons.receipt_long,
                                      //     color: Colors.green, size: 36),
                                      IconButton(
                                        icon: Icon(Icons.highlight_off,
                                            color: Colors.red[700]),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height *
                                                0.65,
                                        // เพื่อให้แนวนอนไม่หลุดไปเรื่อยๆ
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.55,
                                      ),
                                      // decoration: BoxDecoration(
                                      //   border: Border.all(
                                      //       color: Colors.grey.shade300),
                                      //   borderRadius: BorderRadius.circular(10),
                                      // ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          base64Decode(base64_Slip!),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 12),
                      ),
                      icon: const Icon(Icons.image_search),
                      label: const Text(
                        'เรียกดูไฟล์',
                        style: TextStyle(
                          fontFamily: Font_.Fonts_T,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (paymentName1.toString().trim() == 'เงินโอน' ||
              paymentName2.toString().trim() == 'เงินโอน')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                child: Container(
                  width: double.infinity,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.indigo[800],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(
                    child: Text(
                      'QR Code ที่แนบไว้',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: Font_.Fonts_T,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onTap: () async {
                  double value1 =
                      double.tryParse(Form_payment1.text.replaceAll(',', '')) ??
                          0.0;
                  double value2 =
                      double.tryParse(Form_payment2.text.replaceAll(',', '')) ??
                          0.0;
                  double totalQr_ = 0.0;

                  final isOnline1 = paymentName1?.trim() == 'Online Payment';
                  final isOnline2 = paymentName2?.trim() == 'Online Payment';

                  if (isOnline1 && isOnline2) {
                    totalQr_ = value1 + value2;
                  } else if (isOnline1) {
                    totalQr_ = value1;
                  } else if (isOnline2) {
                    totalQr_ = value2;
                  }

                  final double sum = value1 + value2;

                  setState(() {
                    // ใช้ค่า totalQr_ และ sum ได้ที่นี่ตามต้องการ
                    print('✅ รวมทั้งหมด: $sum');
                    print('💰 ยอดชำระผ่าน Online: $totalQr_');
                  });
                  print(newValuePDFimg_QR);
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        insetPadding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                        titlePadding: const EdgeInsets.all(0.0),
                        contentPadding: const EdgeInsets.all(10.0),
                        actionsPadding: const EdgeInsets.all(6.0),
                        content: StreamBuilder(
                          stream: Stream.periodic(const Duration(seconds: 0)),
                          builder: (context, snapshot) {
                            bool isTransfer =
                                paymentName1?.trim() == 'เงินโอน' ||
                                    paymentName2?.trim() == 'เงินโอน';
                            bool isOnline1 =
                                paymentName1?.trim() == 'Online Payment';
                            bool isOnline2 =
                                paymentName2?.trim() == 'Online Payment';
                            double totalAmount = value1 + value2;

                            return SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.cancel,
                                          color: Colors.red),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                  if (isTransfer)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'รูปแบบ : โอนตามเลขบัญชี หรือรูปที่แนบไว้',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T,
                                            color: AccountScreen_Color
                                                .Colors_Text1_,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey[200],
                                          ),
                                          child: (newValuePDFimg_QR == null ||
                                                  newValuePDFimg_QR!.isEmpty)
                                              ? const Icon(
                                                  Icons.image_not_supported,
                                                  size: 80,
                                                  color: Colors.grey)
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    // newValuePDFimg_QR!,
                                                    (newValuePDFimg_QR ==
                                                                null ||
                                                            newValuePDFimg_QR
                                                                    .toString() ==
                                                                '')
                                                        ? '${MyConstant().domain}/Awaitdownload/imagenot.png'
                                                        : '${MyConstant().domain}/files/$foder/payment/${newValuePDFimg_QR}',
                                                    height: 180,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Container(
                                                        height: 180,
                                                        color: Colors.grey[200],
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Icon(
                                                                  Icons
                                                                      .broken_image,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 40),
                                                              SizedBox(
                                                                  height: 8),
                                                              Text(
                                                                'ไม่สามารถโหลดรูปภาพได้',
                                                                style:
                                                                    TypeStyle1,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text('ธนาคาร/Bank : $selectedValue',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            'ทั้งสิ้น/Total : ${nFormat.format(sum)}',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                  else
                                    SizedBox(
                                      width: 320,
                                      child: WebViewX2Page(
                                        id_ser: isOnline1
                                            ? '$selectedValue'
                                            : isOnline2
                                                ? '$selectedValue2'
                                                : 'Error Account number ...??',
                                        amt_ser: isOnline1 && isOnline2
                                            ? '$totalAmount'
                                            : isOnline1
                                                ? '$value1'
                                                : isOnline2
                                                    ? '$value2'
                                                    : '0.00',
                                        name_ser: isOnline1
                                            ? '$bname1'
                                            : isOnline2
                                                ? '$bname2'
                                                : 'Error Account number ...??',
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppbackgroundColor.Abg_Colors,
                borderRadius: BorderRadius.circular(10),
              ),
              child: FutureBuilder<String>(
                future: _translatedText,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'เกิดข้อผิดพลาดในการแปล',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    );
                  } else {
                    return OtpTimerButton(
                      height: 50,
                      text: Text(
                        snapshot.data ?? '',
                        style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text1_,
                          fontWeight: FontWeight.bold,
                          fontFamily: FontWeight_.Fonts_T,
                        ),
                      ),
                      duration: 3,
                      radius: 8,
                      backgroundColor: (ser_paymentMethodId == 2)
                          ? Colors.orange
                          : (base64_Slip != null && ser_paymentMethodId != null)
                              ? Colors.orange
                              : Colors.grey,
                      textColor: Colors.black,
                      buttonType: ButtonType.elevated_button,
                      loadingIndicator: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                      loadingIndicatorColor: Colors.red,
                      onPressed: (ser_paymentMethodId == null)
                          ? () async {
                              Dialog_error(context, 'กรุณาเลือกรูปแบบชำระ');
                            }
                          : (ser_paymentMethodId == 2)
                              ? () async {
                                  if (Form_payment1.text.isNotEmpty &&
                                      Form_payment1.text != '' &&
                                      Form_payment1.text != '0.00') {
                                    print(valueBodyPost);
                                    PUT_GC_payment(
                                      requestUuid: valueBodyPost["requestUuid"]
                                          as String,
                                      paymentMethodId: int.parse(
                                          valueBodyPost["paymentMethodId"]
                                              .toString()),
                                      paymentMethodCode: int.parse(
                                          valueBodyPost["paymentMethodCode"]
                                              .toString()),
                                      bankaccountId: int.parse(
                                          valueBodyPost["bankaccountId"]
                                              .toString()),
                                      paidat:
                                          valueBodyPost["paidat"].toString(),
                                      referencecode:
                                          valueBodyPost["referencecode"]
                                              as String,
                                      reference1:
                                          valueBodyPost["reference1"] as String,
                                      reference2:
                                          valueBodyPost["reference2"] as String,
                                      paymentAmount: double.parse(
                                          valueBodyPost["paymentAmount"]
                                              .toString()),
                                      paymentReceived: double.parse(
                                              Form_payment1.text.toString()) ??
                                          0.00,
                                      uuidPayment: uuid_postpayment.toString(),
                                      slipDate: Value_newDateY1.toString(),
                                      slipPdate: Value_newDateY.toString(),
                                      slipTime: Form_time.text.toString(),
                                    ).then((value) => {});
                                  } else {
                                    Dialog_error(
                                        context, 'กรุณากรอกจำนวนเงินรับมา');
                                  }
                                }
                              : () async {
                                  if (base64_Slip != null) {
                                    if (Form_payment1.text.isNotEmpty &&
                                        Form_payment1.text != '' &&
                                        Form_payment1.text != '0.00') {
                                      print(valueBodyPost);
                                      PUT_GC_payment(
                                        requestUuid:
                                            valueBodyPost["requestUuid"]
                                                as String,
                                        paymentMethodId: int.parse(
                                            valueBodyPost["paymentMethodId"]
                                                .toString()),
                                        paymentMethodCode: int.parse(
                                            valueBodyPost["paymentMethodCode"]
                                                .toString()),
                                        bankaccountId: int.parse(
                                            valueBodyPost["bankaccountId"]
                                                .toString()),
                                        paidat:
                                            valueBodyPost["paidat"].toString(),
                                        referencecode:
                                            valueBodyPost["referencecode"]
                                                as String,
                                        reference1: valueBodyPost["reference1"]
                                            as String,
                                        reference2: valueBodyPost["reference2"]
                                            as String,
                                        paymentAmount: double.parse(
                                            valueBodyPost["paymentAmount"]
                                                .toString()),
                                        paymentReceived: double.parse(
                                                Form_payment1.text
                                                    .toString()) ??
                                            0.00,
                                        uuidPayment:
                                            uuid_postpayment.toString(),
                                        slipDate: Value_newDateY1.toString(),
                                        slipPdate: Value_newDateY.toString(),
                                        slipTime: Form_time.text.toString(),
                                      ).then((value) => {});
                                    } else {
                                      Dialog_error(
                                          context, 'กรุณากรอกจำนวนเงินรับมา');
                                    }
                                  } else {
                                    Dialog_error(
                                        context, 'กรุณาอัพโหลดหลักฐานการชำระ');
                                  }
                                },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
