import 'dart:convert';
import 'dart:html';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_plus/dropdown_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:otp_timer_button/otp_timer_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:step_progress/step_progress.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../AdminScaffold/AdminScaffold.dart';
import '../../Constant/Myconstant.dart';
import '../../Model/GetExp_type_auto.dart';
import '../../Model/GetPayMent_Model.dart';
import '../../PeopleChao/webviewPay.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';
import '../Model/AutoExpTrans_ModelCMM.dart';
import '../Model/Payments_Model.dart';
import '../Model/Receipt_Model.dart';
import '../Model/ReviewUuid_Model.dart';
import '../PDF_CMM/license_form_cmm.dart';
import '../PDF_CMM/receipt_cmm.dart';
import '../PDF_CMM/receipt_img_cmm.dart';
import '../PDF_CMM/unity_pdf_cmm/perviewpdf2_cmm.dart';
import '../PDF_CMM/unity_pdf_cmm/unitypdf_cmm.dart';
import '../unity/API_addfile_payment.dart';
import '../unity/API_admin_signature.dart';
import '../unity/API_payment.dart';
import '../unity/API_renTal.dart';
import '../unity/API_requests_reviews.dart';
import '../unity/PickThaiDate.dart';
import '../unity/ReusableSignaturePad.dart';
import '../unity/SecurePrefs_helper.dart';
import '../unity/UploadFileSlip_base64.dart';
import '../unity/show_dialog_cmm.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:developer' as dev;

class BillPaymentScreen extends StatefulWidget {
  final uuid_Request;
  final response_Post_payment;
  String payment_uuid;
  String payment_amount;
  List<Map<String, dynamic>> payment_jsonx;
  final Repay_jsonDataReceipt;
  final Repay_document_uuid_receipt;
  final bool popOnSuccess;
  final String initialPaymentMethod; // รูปแบบการชำระเงินเริ่มต้น เช่น 'เงินสด'

  BillPaymentScreen(
      {super.key,
      this.uuid_Request,
      this.response_Post_payment,
      required this.payment_uuid,
      required this.payment_amount,
      required this.payment_jsonx,
      this.Repay_jsonDataReceipt,
      this.Repay_document_uuid_receipt,
      this.popOnSuccess = false,
      this.initialPaymentMethod = 'เงินสด'});
  @override
  State<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends State<BillPaymentScreen> {
  late Future<String> _translatedText;
  var nFormat = NumberFormat("#,##0.00", "en_US");
  final Form_payment1 = TextEditingController();
  final Form_payment2 = TextEditingController();
  final Form_time = TextEditingController();

  final Form_Nobill = TextEditingController();
  final Form_docnobill = TextEditingController();
  List<PaymentsModelCMM> paymentsmodel = [];
  List<ReceiptModel> receiptmodel = [];
  // List<ExpAutoModel> expAutoModels = [];
  List<AutoExpTransModelCMM> expAutoModels = [];
  DateTime selectedDate = DateTime.now();
  String paymentMethod = 'เงินสด'; // ค่าเริ่มต้นเป็นเงินสด
  PaymentsModelCMM? _initialPayment;
  double amount = 500.00;
  String? selectedFileName;

  String? Value_newDateY = '',
      Value_newDateD = '',
      Value_newDateY1 = '',
      Value_newDateD1 = '';

  String? Value_newDateY1_docbill = '', Value_newDateD1_docbill = '';
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
  String? uuid_postpayment, document_uuid_receipt;
  List<Map<String, dynamic>> jsonx = [];
  final _formKey_pay = GlobalKey<FormState>();
  final _formKey_docnobill = GlobalKey<FormState>();
  bool _openingDialog = false;
  Map<String, dynamic> jsonDataReceipt = {
    "documentUuid": '',
    "clientsName": '',
    "receiptDocno": '',
    "receiptDate": '',
    "nameTh": '',
    "zn": '',
    "ln": ''
  };
  // @override
  // void initState() {
  //   super.initState();
  //   Prepayment();

  //   red_setdata();
  //   red_payMent();
  //   red_Rental();
  //   StoredAuthData().then((value) => WidgetsBinding.instance
  //       .addPostFrameCallback((_) => readRepayReceipt()));
  //   Value_newDateY1 = DateFormat('yyyy-MM-dd').format(selectedDate);
  //   Value_newDateD1 = DateFormat('dd-MM-yyyy').format(selectedDate);
  //   Value_newDateY = DateFormat('yyyy-MM-dd').format(selectedDate);
  //   Value_newDateD = DateFormat('dd-MM-yyyy').format(selectedDate);

  //   Form_time.text = DateFormat('HH:mm:ss', 'th').format(selectedDate);
  //   _translatedText = Future.delayed(
  //     const Duration(milliseconds: 500),
  //     () => translateText('รับชำระ'),
  //   );
  // }
  @override
  void initState() {
    // _translatedText = translateText('รับชำระ'); // ถ้าเป็น Future<String> ก็โอเค
    // _translatedText = translateText('รับชำระ'); // กำหนดทันที
    super.initState();

    // 1) ตั้งค่าจาก selectedDate ทันที (sync)
    final d = selectedDate; // สมมติประกาศไว้แล้ว
    Value_newDateY1 = DateFormat('yyyy-MM-dd').format(d);
    Value_newDateD1 = DateFormat('dd-MM-yyyy').format(d);
    Value_newDateY = DateFormat('yyyy-MM-dd').format(d);
    Value_newDateD = DateFormat('dd-MM-yyyy').format(d);

    ///----------<
    Value_newDateY1_docbill = DateFormat('yyyy-MM-dd').format(d);
    Value_newDateD1_docbill = DateFormat('dd-MM-yyyy').format(d);
    // ถ้าจะใช้โลเคชันไทยจริง ๆ ต้อง ensure initializeDateFormatting('th')
    Form_time.text = DateFormat('HH:mm:ss', 'th').format(d);

    // ตั้งค่าเริ่มต้นรูปแบบการชำระเงินจาก parameter
    if (widget.initialPaymentMethod.isNotEmpty) {
      paymentMethod = widget.initialPaymentMethod;
    }
    // ตั้งค่าจำนวนเงินเริ่มต้นจาก payment_amount (ถ้ามี)
    if (widget.payment_amount.isNotEmpty && widget.payment_amount != '0') {
      amount = double.tryParse(widget.payment_amount) ?? 0.0;
      Form_payment1.text = amount.toStringAsFixed(2);
    }

    // 2) บูทงาน async
    _bootAsync();
  }

  bool _loadingTranslated = true;

  Future<T> timeIt<T>(String label, Future<T> Function() task) async {
    final sw = Stopwatch()..start();
    try {
      final r = await task();
      return r;
    } finally {
      sw.stop();
      // ทั้ง debugPrint / print / Timeline
      //   debugPrint('⏱ $label took ${sw.elapsedMilliseconds} ms');
      dev.Timeline.timeSync(label, () {}, arguments: {
        'elapsed_ms': sw.elapsedMilliseconds,
      });
    }
  }

  Future<void> _bootAsync() async {
    try {
      // 2.1 ทำขนานเหมือนเดิม แต่หุ้มด้วย timeIt ทีละงาน
      await Future.wait([
        timeIt('red_Rental', () => red_Rental()),
        timeIt('Prepayment', () => Prepayment()),
        timeIt('red_setdata', () => red_setdata()),
        timeIt('red_payMent', () => red_payMent()),
      ], eagerError: true);

      // 2.2
      await timeIt('StoredAuthData', () => StoredAuthData());

      if (!mounted) return;

      // 2.4 งานหลัง build เสร็จ
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await timeIt('Dia_log1', () async {
          Dia_log1(context);
        });
        await timeIt('readRepayReceipt', () => readRepayReceipt());
        setState(() {
          _loadingTranslated = false;
        });
      });
    } catch (e, st) {
      //   debugPrint('init boot error: $e\n$st');
    }
  }

  // Future<void> _bootAsync() async {
  //   try {
  //     // 2.1 งานที่ไม่ต้องรอกัน → ขนาน
  //     await Future.wait([
  //       red_Rental(),
  //       Prepayment(),
  //       red_setdata(),
  //       red_payMent(),
  //     ]);

  //     // 2.2 ถ้าต้องมี auth/ค่าเก็บไว้ก่อน
  //     await StoredAuthData();

  //     if (!mounted) return;

  //     // setState(() {
  //     //   _translatedText =
  //     //       translateText('รับชำระ'); // ถ้าเป็น Future<String> ก็โอเค
  //     // });
  //     // 2.3 แปลข้อความ (ไม่ต้อง delay ถ้าไม่จำเป็น)

  //     // 2.4 ถ้า readRepayReceipt ใช้ context/ต้องให้ tree สร้างเสร็จก่อน
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (!mounted) return;
  //       Dia_log1(context);
  //       readRepayReceipt();
  //       _loadingTranslated = false;
  //     });
  //     // translateText('รับชำระ').then((v) {
  //     //   if (!mounted) return;
  //     //   setState(() {
  //     //     _translatedText =
  //     //         translateText('รับชำระ'); // ถ้าเป็น Future<String> ก็โอเค
  //     //     _loadingTranslated = false;
  //     //   });
  //     // });
  //   } catch (e, st) {
  //     debugPrint('init boot error: $e\n$st');
  //     // TODO: ใส่ error state ถ้าต้องแสดงใน UI
  //   }
  // }

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
  double? _totalSumpay = 0.00;
// Future<http.Response?> readDocnoPayment({
//   required String requestUuid,
// }) async {

  Future<void> readRepayReceipt() async {
    try {
      final raw = widget.Repay_jsonDataReceipt;
      if (raw == null) return;

      dynamic payload = raw;

      // ถ้าเป็นสตริง: ตัดช่องว่าง/กัน 'null'/ลอง decode JSON
      if (payload is String) {
        final s = payload.trim();
        if (s.isEmpty || s.toLowerCase() == 'null') return;
        if (s.startsWith('{') || s.startsWith('[')) {
          try {
            payload = jsonDecode(s);
          } catch (_) {}
        }
      }

      // ดึง uuid ให้ได้จากหลาย key ทั่วไป
      String? uuid;
      if (payload is Map) {
        uuid = (payload['document_uuid'] ??
                payload['documentUuid'] ??
                payload['receipt_uuid'] ??
                payload['receiptUuid'] ??
                payload['uuid'] ??
                payload['id'])
            ?.toString()
            .trim();
      } else if (payload is String) {
        uuid = payload.trim();
      }

      if (!mounted) return;
      setState(() {
        jsonDataReceipt = payload; // เก็บ payload ดิบไว้ใช้ต่อ
        if (uuid != null && uuid.isNotEmpty) {
          document_uuid_receipt = uuid; // เก็บ uuid ให้ชัด
        }
        // ถ้าต้องการโชว์กำลังสร้างไฟล์ ให้ตั้ง flag ไว้ เช่น _isGenerating = true;
      });

      // ไม่ต้อง delay โดยไม่มีเหตุผล: เรียกสร้าง PDF ตรง ๆ
      final generated = await GeneratePDF_Receipt_CMM(
          context: context,
          type: 0,
          DataDetail: reviewDetail,
          expAutoModels: expAutoModels,
          receiptmodel: jsonDataReceipt,
          Signature_user: Signature_user,
          fullNameAdmin: fullNameAdmin,
          positionAdmin: positionAdmin);

      if (!mounted) return;
      setState(() {
        _stepProgressController.nextStep();
        pdfx = generated; // ไม่ต้องเซ็ต null ก่อน
        // _isGenerating = false;
      });
    } catch (e, st) {
      //debugPrint('readRepayReceipt error: $e\n$st');
      if (!mounted) return;
      setState(() {
        // _isGenerating = false;
        // เก็บ error state ถ้าต้องใช้
      });
    }
  }

  Future<void> red_Rental() async {
    final result = await read_GC_rental();
    if (result != null) {
      setState(() {
        foder = result.dbn;
      });
    }
  }

  Future<void> Prepayment() async {
    final response =
        await readPrepayment(requestUuid: widget.uuid_Request.toString());
    // print('Prepayment response');
    if (response != null && response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // print('body Prepayment ${body}');
      if (body['data']['details'] != null && body['data']['details'] is List) {
        final List<dynamic> list = body['data']['details'];
        final models =
            list.map((e) => AutoExpTransModelCMM.fromJson(e)).toList();

        setState(() {
          expAutoModels.addAll(models);
        });
      } else {
        // print('⚠️ ไม่มีข้อมูลใน field "data->details"');
      }
    } else {
      //  print('❌ Prepayment failed or null response');
    }
    final totalSum = expAutoModels.fold<double>(
      0.0,
      (previousValue, element) =>
          previousValue + (double.tryParse(element.total ?? '0.0') ?? 0.0),
    );
    setState(() {
      _totalSumpay = totalSum;
    });
    // print('Prepayment--1');
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
      // expAutoModels.clear();
      jsonx = widget.payment_jsonx;
    });
    // ตรวจสอบว่ามี response_Post_payment จากการ POST หรือไม่
    // print("ตรวจสอบว่ามี response_Post_payment จากการ POST หรือไม่");
    // print("payment_jsonx : ${widget.payment_jsonx}");
    // print("payment_jsonx : $jsonx");
    // print("response_Post_payment : ${widget.response_Post_payment}");

    if (widget.payment_uuid != null) {
      setState(() {
        uuid_postpayment = widget.payment_uuid.toString();

        // กำหนดค่า valueBodyPost เริ่มต้น (สำหรับกรณีใช้ค่า default ไม่ได้เลือกใหม่)
        valueBodyPost = {
          "requestUuid": widget.uuid_Request ?? '',
          "paymentMethodId": 2, // เงินสด default
          "paymentMethodCode": 'CASH',
          "bankaccountId": 0,
          "paidat": DateTime.now().toIso8601String(),
          "referencecode": "",
          "reference1": "",
          "reference2": "",
          "paymentAmount": double.tryParse(widget.payment_amount) ?? 500.0,
        };

        // expAutoModels.addAll(
        //   jsonx.map((e) => ExpAutoModel.fromJson(e)).toList(),
        // );
      });
      // print('red_setdata--2.1');
    } else if (widget.response_Post_payment != null &&
        widget.response_Post_payment.body.isNotEmpty) {
      try {
        final Map<String, dynamic> responseBody =
            jsonDecode(widget.response_Post_payment.body);
        // print(
        //   "responseBody json: ${responseBody['data']['json'].map((e) => ExpAutoModel.fromJson(e)).toList()}");
        setState(() {
          uuid_postpayment = responseBody['data']['uuid'] ?? '';
          // expAutoModels.addAll(
          //   responseBody['data']['json']
          //       .map((e) => ExpAutoModel.fromJson(e))
          //       .toList(),
          // );
        });
        //print('red_setdata--2.2');
      } catch (e) {
        //  print('red_setdata--2.3');
        //  print('❌ ไม่สามารถ decode response ได้: $e');
      }
    }
    // print('red_setdata--2.4');
    // print('📌 uuid_postpayment: $uuid_postpayment');
  }

  Future<void> red_payMent() async {
    // print('🔄 เรียกใช้งาน red_payMent  ***');

    // โหลดข้อมูลการชำระเงิน
    final result = await read_GC_payment();
    //  print('📥 โหลดรายการวิธีชำระเงิน2: ${result.length} รายการ');

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
        final cashIndex = _list.indexWhere(
          (p) => p.code == 'CASH' || (p.name_th?.contains('เงินสด') ?? false),
        );
        _initialPayment = cashIndex >= 0
            ? _list[cashIndex]
            : (_list.isNotEmpty ? _list.first : null);
        if (_initialPayment != null) {
          ser_paymentMethodId = _initialPayment!.id;
        }
      });

      for (var payment in _list) {
        //   print('✅ วิธีชำระ: ${payment.name_th}');
      }
    } else {
      //  print('⚠️ ไม่พบข้อมูลวิธีชำระเงิน');
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

  //////////////------------------------------------------------------>
  int activeStep = 0; // stepper
//////////////------------------------------------------------------>
  String headerText() {
    switch (activeStep) {
      case 0:
        return 'ผู้เช่า ';
      case 1:
        return 'ข้อมูลการเช่า';
      case 2:
        return 'ค่าบริการ';

      // case 3:
      //   return 'การชำระ';

      // case 4:
      //   return 'สัญญาเช่า';

      default:
        return '';
    }
  }

  void _goToNextStep() {
    setState(() {
      activeStep += 1;
    });
  }

  final _stepProgressController =
      StepProgressController(totalSteps: 2, initialStep: 0);
  Header_Stepper(context) {
    return SizedBox(
        child: Column(children: [
      // const SizedBox(
      //   height: 15,
      // ),
      // Center(
      //   child: Text(headerText(),
      //       maxLines: 3,
      //       overflow: TextOverflow.ellipsis,
      //       softWrap: false,
      //       style: const TextStyle(
      //         fontSize: 25,
      //         color: PeopleChaoScreen_Color.Colors_Text1_,
      //         // fontWeight: FontWeight.bold,
      //         fontFamily: FontWeight_.Fonts_T,
      //         fontWeight: FontWeight.bold,
      //       )),
      // ),
      // const SizedBox(
      //   height: 10,
      // ),
      // IconStepper(
      //   stepColor: Colors.orange,
      //   activeStepBorderColor: Colors.orange,
      //   activeStepColor: Colors.white,
      //   lineColor: Colors.red,
      //   enableNextPreviousButtons: false,
      //   enableStepTapping: false,
      //   stepRadius: 15,
      //   icons: const [
      //     Icon(
      //       Icons.payment,
      //       // size: 30,
      //     ),
      //     Icon(
      //       Icons.filter_2,
      //       // size: 30,
      //     ),
      //     Icon(
      //       Icons.filter_3,
      //       // size: 30,
      //     ),
      //     // Icon(Icons.filter_4),
      //     // Icon(Icons.filter_5),
      //   ],

      //   // activeStep property set to activeStep variable defined above.
      //   activeStep: activeStep,

      //   // This ensures step-tapping updates the activeStep.
      //   onStepReached: (index) {
      //     setState(() {
      //       activeStep = index;
      //     });
      //   },
      // ),
      StepProgress(
        totalSteps: 2,
        padding: const EdgeInsets.all(4),
        lineTitles: const [
          'การรับชำระ',
          // 'line title 2',
          // 'line title 3',
        ],
        controller: _stepProgressController,
        nodeIconBuilder: (index, completedStepIndex) {
          if (index <= completedStepIndex) {
            return const Icon(
              Icons.check,
              color: Colors.white,
            );
          } else {
            return const Icon(
              Icons.more_horiz,
              color: Colors.white,
            );
          }
        },
        theme: const StepProgressThemeData(
          lineLabelAlignment: Alignment.bottomCenter,
          lineLabelStyle: StepLabelStyle(
            defualtColor: Colors.grey,
            activeColor: Colors.green,
          ),
          stepLineSpacing: 20,
          stepLineStyle: StepLineStyle(
            lineThickness: 3,
            borderRadius: Radius.circular(4),
          ),
        ),
      ),
    ]));
  }

  File? pdfFile;
  dynamic pdfx = pw.Document();
  // String? Signature_user;
  Uint8List? Signature_user;
  String fullNameAdmin = '',
      positionAdmin = '',
      proFileUuid = '',
      sigNatureUuid = '';
  // String signaturesUrl = '';
  Uint8List? signaturesUrl; // รูปลายเซ็นของแอดมิน (จาก API)
  final TextEditingController controller_fullNameAdmin =
      TextEditingController();
  final TextEditingController controller_positionAdmin =
      TextEditingController();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  String functionName = "GeneratePDF_1",
      pdfName = "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ";
  List data_doccid = [];
  List<ReviewDetail> reviewDetail = [];

  Future<void> StoredAuthData() async {
    final response = await read_AdminSignature();
    final result = json.decode(response!.body);
    final profileUuid = result['data']['profile_uuid'];
    final profile = result['data']['profile'];
    final signatureUuid = result['data']['signature_uuid'];
    final positionName = result['data']['position_name'];

    final accessToken =
        await SecurePrefs.getDecrypted(SecurePrefsType.authAccessToken);
    final userUuid =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserUuid);
    final userEmail =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserEmail);
    final userJson =
        await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      final pretty = const JsonEncoder.withIndent('  ').convert(userMap);
      // print(pretty);
// โหลดภาพลายเซ็นเป็น bytes
      Uint8List? sigBytes;
      if (signatureUuid != null && signatureUuid.isNotEmpty) {
        final sigResp = await img_signatureUuid(signatureUuid: signatureUuid);
        if (sigResp != null && sigResp.statusCode == 200) {
          sigBytes = sigResp.bodyBytes;
        } else {
          debugPrint('❌ Failed to load signature image');
        }
      }
      setState(() {
        signaturesUrl = sigBytes;
        // signaturesUrl = (result['data']['signature_uuid'] != null)
        //     ? '${MyConstant().domain_v1}/admin/users/signatures/${signatureUuid}/preview'
        //     : '';
        proFileUuid = profileUuid ?? '';
        sigNatureUuid = signatureUuid ?? '';
        fullNameAdmin = profile ?? '';
        controller_fullNameAdmin.text = profile ?? '';
        controller_positionAdmin.text = positionName ?? '';
        positionAdmin = positionName ?? '';
        // fullNameAdmin = userMap['fname'] + ' ' + userMap['lname'] ?? '';
        // positionAdmin = userMap['position'] ?? '';
      });
      SetData();
    } else {
      //  print('(null)');
    }
  }

  Future<void> SetData() async {
    setState(() => Signature_user = signaturesUrl);
    setState(() => _pdfViewerKey.currentState);

    // setState(() => base64_Slip = signaturesUrl.toString());
    await Future.delayed(Duration.zero); // แยกเฟรมให้อัปเดตจอเสร็จ
    showBlockingLoader(context); // ❗ ไม่ต้อง await
    setState(() {
      pdfx = null;
    });
    try {
      readRepayReceipt();
      // ทำงานหนักที่ต้องรอ
      // await doWork();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // ปิด loader
      }
    }
  }

//////////////------------------------------------------------------>
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: _loadingTranslated
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: (_stepProgressController.currentStep == 0) ? 2 : 1,
                  child: Padding(
                    padding: (_stepProgressController.currentStep == 0)
                        ? EdgeInsets.fromLTRB(0, 16, 0, 16)
                        : EdgeInsets.all(16),
                    child: (_stepProgressController.currentStep == 0)
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(2.0),
                            // width: 400,
                            // height: 450,
                            child: buildBillDetails())
                        : Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                padding: const EdgeInsets.all(2.0),
                                child: pdfx != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: PreviewPdfgen2_CMM(
                                            doc: pdfx, title: '$pdfName'))
                                    : Center(
                                        child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Icon(Icons.picture_as_pdf),
                                          ),
                                          Text(
                                            "PDF Download ...",
                                            style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T),
                                          ),
                                        ],
                                      )),
                                //  Column(
                                //   children: [
                                //     Container(
                                //       width: 400,
                                //       height: 450,
                                //       decoration: BoxDecoration(
                                //         color: Colors.white,
                                //         borderRadius: BorderRadius.only(
                                //             topLeft: Radius.circular(10),
                                //             topRight: Radius.circular(10),
                                //             bottomLeft: Radius.circular(10),
                                //             bottomRight: Radius.circular(10)),
                                //         border: Border.all(color: Colors.grey, width: 1),
                                //       ),
                                //       child: pdfx != null
                                //           ? Padding(
                                //               padding: const EdgeInsets.all(8.0),
                                //               child: PreviewPdfgen2_CMM(
                                //                   doc: pdfx, title: '$pdfName'),
                                //             )
                                //           : Center(
                                //               child: Column(
                                //               crossAxisAlignment: CrossAxisAlignment.center,
                                //               mainAxisAlignment: MainAxisAlignment.center,
                                //               children: [
                                //                 Padding(
                                //                   padding: const EdgeInsets.all(8.0),
                                //                   child: Icon(Icons.picture_as_pdf),
                                //                 ),
                                //                 Text(
                                //                   "PDF Download ...",
                                //                   style: TextStyle(
                                //                       color: PeopleChaoScreen_Color
                                //                           .Colors_Text2_,
                                //                       fontFamily: Font_.Fonts_T),
                                //                 ),
                                //               ],
                                //             )),
                                //     ),
                                //     Padding(
                                //       padding: const EdgeInsets.all(8.0),
                                //       child: IconButton(
                                //           onPressed: () async {
                                //             // Navigator.push(
                                //             //     context,
                                //             //     MaterialPageRoute(
                                //             //       builder: (context) =>
                                //             //           ReceiptPage(),
                                //             //     ));
                                //             // final pdfGenerators = {
                                //             //   "GeneratePDF_1": () =>
                                //             //       GeneratePDF_Receipt_CMM(
                                //             //           context,
                                //             //           1,
                                //             //           reviewDetail)
                                //             // };
                                //             // final fn =
                                //             //     pdfGenerators[functionName];
                                //             // if (fn != null) await fn();
                                //             if (Signature_user != null) {
                                //               // print(Signature_user);
                                //               GeneratePDF_Receipt_CMM(
                                //                   context: context,
                                //                   type: 1,
                                //                   DataDetail: reviewDetail,
                                //                   expAutoModels: expAutoModels,
                                //                   receiptmodel: jsonDataReceipt,
                                //                   Signature_user: Signature_user,
                                //                   fullNameAdmin: fullNameAdmin,
                                //                   positionAdmin: positionAdmin);
                                //             } else {
                                //               Dialog_error(
                                //                   context,
                                //                   (Signature_user == null)
                                //                       ? 'กรุณาประทับลายเซ็น'
                                //                       : '$Signature_user');
                                //             }
                                //           },
                                //           icon: Icon(Icons.print)),
                                //     ),
                                //     // IconButton(
                                //     //     onPressed: () {},
                                //     //     icon: Icon(Icons.print)),
                                //   ],
                                // ),
                              ),
                              Positioned(
                                bottom: 20,
                                right: 30,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    child: Center(
                                      child: IconButton(
                                          onPressed: () async {
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //       builder: (context) =>
                                            //           ReceiptPage(),
                                            //     ));
                                            // final pdfGenerators = {
                                            //   "GeneratePDF_1": () =>
                                            //       GeneratePDF_Receipt_CMM(
                                            //           context,
                                            //           1,
                                            //           reviewDetail)
                                            // };
                                            // final fn =
                                            //     pdfGenerators[functionName];
                                            // if (fn != null) await fn();
                                            GeneratePDF_Receipt_CMM(
                                                context: context,
                                                type: 1,
                                                DataDetail: reviewDetail,
                                                expAutoModels: expAutoModels,
                                                receiptmodel: jsonDataReceipt,
                                                Signature_user: Signature_user,
                                                fullNameAdmin: fullNameAdmin,
                                                positionAdmin: positionAdmin);
                                            // if (Signature_user != null) {
                                            //   // print(Signature_user);
                                            //   GeneratePDF_Receipt_CMM(
                                            //       context: context,
                                            //       type: 1,
                                            //       DataDetail: reviewDetail,
                                            //       expAutoModels: expAutoModels,
                                            //       receiptmodel: jsonDataReceipt,
                                            //       Signature_user: Signature_user,
                                            //       fullNameAdmin: fullNameAdmin,
                                            //       positionAdmin: positionAdmin);
                                            // } else {
                                            //   Dialog_error(
                                            //       context,
                                            //       (Signature_user == null)
                                            //           ? 'กรุณาประทับลายเซ็น'
                                            //           : '$Signature_user');
                                            // }
                                          },
                                          icon: Icon(Icons.print)),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:
                        (_stepProgressController.currentStep ==
                                0) //(activeStep == 1)
                            ? buildPaymentSection()
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 73,
                                        decoration: BoxDecoration(
                                          color: AppBarColors.hexColor
                                              .withOpacity(0.7),
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
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 4, 8, 4),
                                                child: Header_Stepper(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                      minWidth: 400,
                                                      minHeight: 450,
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.7,
                                                    ),
                                                    // height:
                                                    //     MediaQuery.of(context)
                                                    //             .size
                                                    //             .height *
                                                    //         0.7,
                                                    // width: 400,
                                                    // height: 450,
                                                    // decoration: BoxDecoration(
                                                    //   color: Colors.white,
                                                    //   borderRadius:
                                                    //       BorderRadius.only(
                                                    //           topLeft: Radius
                                                    //               .circular(10),
                                                    //           topRight: Radius
                                                    //               .circular(10),
                                                    //           bottomLeft: Radius
                                                    //               .circular(10),
                                                    //           bottomRight:
                                                    //               Radius
                                                    //                   .circular(
                                                    //                       10)),
                                                    //   border: Border.all(
                                                    //       color: Colors.grey,
                                                    //       width: 1),
                                                    // ),
                                                    child: buildBillDetails()),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Form(
                                                key: _formKey,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 400,
                                                      // height: 450,
                                                      child: Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4.0),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
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
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: 1),
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                    height: 120,
                                                                    width: 200,
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(8.0),
                                                                        topRight:
                                                                            Radius.circular(8.0),
                                                                        bottomLeft:
                                                                            Radius.circular(8.0),
                                                                        bottomRight:
                                                                            Radius.circular(8.0),
                                                                      ),
                                                                      child: (Signature_user ==
                                                                              null)
                                                                          ? const SizedBox()
                                                                          : FittedBox(
                                                                              // fit: BoxFit.cover,
                                                                              child: Image.memory(
                                                                                Signature_user!,
                                                                                height: 110,
                                                                              ),
                                                                            ),
                                                                      // (Signature_user ==
                                                                      //             null ||
                                                                      //         Signature_user ==
                                                                      //             '')
                                                                      //     ? null
                                                                      //     : ClipRRect(
                                                                      //         borderRadius:
                                                                      //             BorderRadius.circular(
                                                                      //                 8.0),
                                                                      //         child:
                                                                      //             FittedBox(
                                                                      //           // fit: BoxFit
                                                                      //           //     .fill,
                                                                      //           child: Image
                                                                      //               .network(
                                                                      //             '$Signature_user',
                                                                      //             // height:
                                                                      //             //     160,
                                                                      //           ),
                                                                      //         ),
                                                                      //       ),
                                                                    ),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              0),
                                                                          topRight: Radius.circular(
                                                                              0),
                                                                          bottomLeft: Radius.circular(
                                                                              0),
                                                                          bottomRight:
                                                                              Radius.circular(0)),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      color: AppbackgroundColor
                                                                          .Abg_Colors,
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              0),
                                                                          topRight: Radius.circular(
                                                                              0),
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                      // border: Border.all(color: Colors.grey, width: 1),
                                                                    ),
                                                                    child: Row(
                                                                      children: <Widget>[
                                                                        TextButton(
                                                                            child:
                                                                                AutoSizeText(
                                                                              minFontSize: 12,
                                                                              maxFontSize: 16,
                                                                              maxLines: 1,
                                                                              'ประทับลายเซ็น',
                                                                              textAlign: TextAlign.left,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(color: Colors.blueGrey, fontFamily: Font_.Fonts_T),
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              setState(() => Signature_user = signaturesUrl);
                                                                              setState(() => _pdfViewerKey.currentState);

                                                                              await Future.delayed(Duration.zero); // แยกเฟรมให้อัปเดตจอเสร็จ
                                                                              showBlockingLoader(context); // ❗ ไม่ต้อง await
                                                                              setState(() {
                                                                                pdfx = null;
                                                                              });
                                                                              try {
                                                                                readRepayReceipt();
                                                                                // ทำงานหนักที่ต้องรอ
                                                                                // await doWork();
                                                                              } finally {
                                                                                if (mounted) {
                                                                                  Navigator.of(context, rootNavigator: true).pop(); // ปิด loader
                                                                                }
                                                                              }
                                                                            }

                                                                            // onPressed:
                                                                            //     () async {
                                                                            //   final ttf =
                                                                            //       await font1();
                                                                            //   setState(() {
                                                                            //     Signature_user = signaturesUrl;
                                                                            //   });
                                                                            //   // dynamic
                                                                            //   //     widget_Signaturex =
                                                                            //   //     await Signature_PDF(
                                                                            //   //   value: '',
                                                                            //   //   font: ttf,
                                                                            //   //   height: 50,
                                                                            //   //   width: 150,
                                                                            //   //   imageBytes:
                                                                            //   //       signaturesUrl,
                                                                            //   //   // signatureImageUrl:
                                                                            //   //   //     Signature_user, // ✅ ใช้ URL ที่สมบูรณ์
                                                                            //   // );
                                                                            //   setState(() {
                                                                            //     _pdfViewerKey.currentState;
                                                                            //   });
                                                                            //   Dia_log1(context);
                                                                            // },
                                                                            ),
                                                                        TextButton(
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: AutoSizeText(
                                                                                minFontSize: 12,
                                                                                maxFontSize: 16,
                                                                                maxLines: 1,
                                                                                'ยกเลิกลายเซ็น',
                                                                                textAlign: TextAlign.left,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(color: Colors.blueGrey, fontFamily: Font_.Fonts_T),
                                                                              ),
                                                                            ),
                                                                            onPressed:
                                                                                () async {
                                                                              setState(() => Signature_user = null);

                                                                              await Future.delayed(Duration.zero); // แยกเฟรมให้อัปเดตจอเสร็จ
                                                                              showBlockingLoader(context); // ❗ ไม่ต้อง await
                                                                              setState(() {
                                                                                pdfx = null;
                                                                              });
                                                                              try {
                                                                                readRepayReceipt();
                                                                                // ทำงานหนักที่ต้องรอ
                                                                                // await doWork();
                                                                              } finally {
                                                                                if (mounted) {
                                                                                  Navigator.of(context, rootNavigator: true).pop(); // ปิด loader
                                                                                }
                                                                              }
                                                                            }

                                                                            // onPressed:
                                                                            //     () async {
                                                                            //   setState(() {
                                                                            //     Signature_user = null;
                                                                            //     _pdfViewerKey.currentState;
                                                                            //   });
                                                                            //   Dia_log1(context);
                                                                            // },
                                                                            ),
                                                                      ],
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          for (int index = 0;
                                                              index < 2;
                                                              index++)
                                                            SizedBox(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        AutoSizeText(
                                                                      minFontSize:
                                                                          12,
                                                                      maxFontSize:
                                                                          16,
                                                                      maxLines:
                                                                          1,
                                                                      (index ==
                                                                              0)
                                                                          ? 'ชื่อผู้ตรวจสอบเอกสาร'
                                                                          : 'ชื่อตำแหน่ง',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          color: PeopleChaoScreen_Color
                                                                              .Colors_Text2_,
                                                                          fontFamily:
                                                                              Font_.Fonts_T),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            2.0),
                                                                    child:
                                                                        TextFormField(
                                                                      readOnly:
                                                                          true,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      // controller: Formbecause_,
                                                                      initialValue: (index ==
                                                                              0)
                                                                          ? '$fullNameAdmin'
                                                                          : '$positionAdmin',
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'ใส่ข้อมูลให้ครบถ้วน ';
                                                                        }
                                                                        // if (int.parse(value.toString()) < 13) {
                                                                        //   return '< 13';
                                                                        // }
                                                                        return null;
                                                                      },
                                                                      onChanged:
                                                                          (value) {
                                                                        // setState(() {
                                                                        //   Formbecause_.text =
                                                                        //       value.toString();
                                                                        // });
                                                                      },
                                                                      maxLines:
                                                                          1,
                                                                      cursorColor:
                                                                          Colors
                                                                              .green,
                                                                      decoration: InputDecoration(
                                                                          fillColor: Colors.white.withOpacity(0.3),
                                                                          filled: true,
                                                                          // prefixIcon: const Icon(Icons.water,
                                                                          //     color: Colors.blue),
                                                                          // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                                                          focusedBorder: const OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(8)),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              width: 1,
                                                                              color: Colors.black,
                                                                            ),
                                                                          ),
                                                                          enabledBorder: const OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(8)),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              width: 1,
                                                                              color: Colors.grey,
                                                                            ),
                                                                          ),
                                                                          // labelText: 'คำอธิบาย',
                                                                          labelStyle: const TextStyle(
                                                                            color:
                                                                                ManageScreen_Color.Colors_Text2_,
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
                                                                ],
                                                              ),
                                                            ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          _buttonfool()
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // _buttonfool()
                                    ])),
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
        // border: Border.all(color: Colors.grey, width: 1),
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
                                    '${double.parse(exp.total.toString()) ?? 0.00}',
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
                                  '${nFormat.format(_totalSumpay)}',
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
          // Container(width: 100,
          //   height: 40,
          //   child: Header_Stepper(context),
          // ),
          Container(
            height: 73,
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
                // InkWell(
                //   child: Icon(
                //     Icons.bubble_chart_rounded,
                //     // Icons.next_plan,
                //     color: Colors.grey[300],
                //   ),
                // ),
                Expanded(
                  flex: 1,
                  child: Container(
                    // decoration: BoxDecoration(
                    //   // color: Colors.green[200]!.withOpacity(0.5),
                    //   borderRadius: BorderRadius.all(Radius.circular(10)),
                    //   // border: Border.all(
                    //   //     color: Colors.grey, width: 1),
                    // ),
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Header_Stepper(context),
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Center(
                //     child: Container(
                //       width: 200,
                //       decoration: BoxDecoration(
                //         color: Colors.green[200]!.withOpacity(0.5),
                //         borderRadius: BorderRadius.all(Radius.circular(10)),
                //         // border: Border.all(
                //         //     color: Colors.grey, width: 1),
                //       ),
                //       padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                //       child: Center(
                //         child: Translate.TranslateAndSetText(
                //             'รับชำระ',
                //             PeopleChaoScreen_Color.Colors_Text2_,
                //             TextAlign.start,
                //             FontWeight.bold,
                //             FontWeight_.Fonts_T,
                //             14,
                //             1),
                //       ),
                //     ),
                //   ),
                // ),
                // InkWell(
                //   onTap: () async {},
                //   child: Icon(
                //     Icons.sync_sharp,
                //     // Icons.next_plan,
                //     color: Colors.grey[300],
                //   ),
                // ),
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
                        '${nFormat.format(_totalSumpay)}',
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
                            initialItem: _initialPayment,
                            onChanged: (PaymentsModelCMM? selectedItem) {
                              if (selectedItem == null) {
                                //   print('❌ selectedItem เป็น null');
                                return;
                              }

                              // print('✅ พบข้อมูลช่องทางการชำระเงิน');
                              // print(
                              //     '➡️ UUID Method          : ${selectedItem.uuid}');
                              // print(
                              //     '➡️ Payment Method ID    : ${selectedItem.id}');
                              // print(
                              //     '➡️ Payment Code         : ${selectedItem.code}');

                              final hasMeta = selectedItem.meta != null &&
                                  selectedItem.meta!.isNotEmpty;

                              int bankId = 0;
                              String bankName = '';
                              String bankAccount = '';
                              String imgPath = '';

                              if (hasMeta) {
                                final meta = selectedItem
                                    .meta!.first; // ✅ ปลอดภัยเพราะเช็กก่อนแล้ว

                                // ดึงค่าตรง ๆ ตามโมเดล
                                bankId = meta.bank_id ?? 0;
                                bankName = meta.bank_names ?? '';
                                bankAccount = meta.bank_account ?? '';
                                imgPath = (meta.image_path ?? '').trim();

                                // ถ้า imgPath ยังว่าง ลอง fallback คีย์อื่น ๆ เผื่อแบ็กเอนด์สะกดต่าง
                                if (imgPath.isEmpty) {
                                  // ignore: unnecessary_raw_strings
                                  final asMap =
                                      meta.toJson(); // ใช้ของคลาสคุณเลย
                                  for (final k in const [
                                    'imagePath',
                                    'qr',
                                    'qr_path',
                                    'qrPath',
                                    'qrcode',
                                    'qrCode',
                                    'image',
                                    'qrImage'
                                  ]) {
                                    final v = asMap[k];
                                    if (v is String && v.trim().isNotEmpty) {
                                      imgPath = v.trim();
                                      break;
                                    }
                                  }
                                }

                                // ถ้าต้องการทำให้เป็น URL เต็ม (กรณีได้มาเป็นชื่อไฟล์)
                                // final base = MyConstant().domain_v1; // ปรับตามจริง
                                // if (imgPath.isNotEmpty && !imgPath.startsWith('http')) {
                                //   imgPath = '$base/uploads/$imgPath'; // ปรับ path ให้ตรงแบ็กเอนด์
                                // }

                                // print('➡️ Bank ID              : $bankId');
                                // print('➡️ Bank Name            : $bankName');
                                // print('➡️ Bank Account         : $bankAccount');
                                // print('➡️ Bank QR              : $imgPath');

                                // เพิ่มดีบักเจาะจง ถ้า QR ยังว่าง
                                if (imgPath.isEmpty) {
                                  // print(
                                  //    '🕵️ image_path ว่าง ตรวจ meta ต้นทาง: ${meta.toJson()}');
                                }
                              } else {
                                //  print(
                                //  'ℹ️ ไม่มีข้อมูลธนาคาร (meta ว่างหรือไม่มี)');
                              }

                              setState(() {
                                newValuePDFimg_QR = imgPath; // ← ใช้ค่าที่ได้
                                ser_paymentMethodId = selectedItem.id;

                                valueBodyPost = {
                                  "requestUuid": widget.uuid_Request ?? '',
                                  "paymentMethodId": selectedItem.id ?? 0,
                                  "paymentMethodCode":
                                      selectedItem.code ?? '', // ✅ ใช้ code
                                  "bankaccountId": bankId,
                                  "paidat": DateTime.now().toIso8601String(),
                                  "referencecode": "",
                                  "reference1": "",
                                  "reference2": "",
                                  "paymentAmount": 500.0,
                                };
                              });

                              //      print('----------------------------------');
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
                const SizedBox(height: 8),
                // 🔷 แถวสอง: จำนวนเงิน
                Container(
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 45,
                        alignment: Alignment.centerLeft,
                        child: Translate.TranslateAndSetText(
                          'เล่มที่',
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
                        flex: 1,
                        child: Form(
                          // key: _formKey_docnobill,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: Form_docnobill,
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
                              cursorColor: Colors.purple,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                hintText: '',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontFamily: Font_.Fonts_T,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                border: OutlineInputBorder(),
                              ),
                              // inputFormatters: <TextInputFormatter>[
                              //   FilteringTextInputFormatter.allow(
                              //       RegExp(r'[0-9 .]')),
                              // ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 100,
                        height: 45,
                        alignment: Alignment.centerLeft,
                        child: Translate.TranslateAndSetText(
                          'เลขที่ใบเสร็จ',
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
                        flex: 2,
                        child: Form(
                          key: _formKey_docnobill,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: Form_Nobill,

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
                              cursorColor: Colors.purple,
                              textAlign: TextAlign.center,
                              // textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: 'REXX-XX-XXXX',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontFamily: Font_.Fonts_T,
                                ),
                                // floatingLabelAlignment:
                                //     FloatingLabelAlignment.center,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                border: OutlineInputBorder(),
                              ),
                              // inputFormatters: <TextInputFormatter>[
                              //   FilteringTextInputFormatter.allow(
                              //       RegExp(r'[0-9 .]')),
                              // ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      // // Icon(Icons.money_outlined),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 35,
                                // decoration: BoxDecoration(
                                //   color: AppbackgroundColor.Sub_Abg_Colors,
                                //   borderRadius: const BorderRadius.only(
                                //       topLeft: Radius.circular(8),
                                //       bottomLeft: Radius.circular(8)),
                                // ),
                                alignment: Alignment.center,
                                child: Translate.TranslateAndSetText(
                                  'วันที่ใบเสร็จ',
                                  PeopleChaoScreen_Color.Colors_Text2_,
                                  TextAlign.start,
                                  FontWeight.bold,
                                  FontWeight_.Fonts_T,
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
                                    Value_newDateY1_docbill =
                                        DateFormat('yyyy-MM-dd')
                                            .format(newDate);
                                    Value_newDateD1_docbill =
                                        DateFormat('dd-MM-yyyy')
                                            .format(newDate);
                                  });
                                },
                                child: Container(
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                    border:
                                        Border.all(color: Colors.grey.shade400),
                                  ),
                                  alignment: Alignment.center,
                                  child: AutoSizeText(
                                    Value_newDateD1_docbill!.isEmpty
                                        ? 'เลือกวันที่'
                                        : '$Value_newDateD1_docbill',
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
                const SizedBox(height: 8),

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
                            cursorColor: Colors.purple,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontFamily: Font_.Fonts_T,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(),
                            ),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9 .]')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    // Icon(Icons.money_outlined),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey.shade800,
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          Form_payment1.text =
                              double.tryParse(_totalSumpay.toString() ?? '0')
                                  .toString();
                        });
                      },
                      child: Text(
                        'รับเท่าจำนวน',
                        style: TextStyle(
                            color: Colors.white, fontFamily: Font_.Fonts_T),
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
                if (newValuePDFimg_QR != null &&
                    newValuePDFimg_QR != 'null' &&
                    newValuePDFimg_QR != '')
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ElevatedButton.icon(
                        onPressed: newValuePDFimg_QR == null
                            ? null
                            : () async {
                                // คำนวณก่อนเปิด dialog
                                final double value1 = double.tryParse(
                                        Form_payment1.text
                                            .replaceAll(',', '')) ??
                                    0.0;
                                final double value2 = double.tryParse(
                                        Form_payment2.text
                                            .replaceAll(',', '')) ??
                                    0.0;

                                final bool isOnline1 =
                                    paymentName1?.trim() == 'Online Payment';
                                final bool isOnline2 =
                                    paymentName2?.trim() == 'Online Payment';
                                final double totalQr_ = (isOnline1 && isOnline2)
                                    ? (value1 + value2)
                                    : (isOnline1
                                        ? value1
                                        : (isOnline2 ? value2 : 0.0));
                                final double sum = value1 + value2;

// เตรียม URL รูป
                                final String imgFile =
                                    (newValuePDFimg_QR ?? '').trim();
                                final String imgUrl = imgFile.isEmpty
                                    ? '${MyConstant().domain}/Awaitdownload/imagenot.png'
                                    : '${MyConstant().domain}/files/$foder/payment/$imgFile';

// เปิด Dialog สวย ๆ
                                showDialog<void>(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      insetPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      titlePadding: EdgeInsets.zero,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          14, 0, 14, 10),
                                      actionsPadding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 12),

                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.red),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            tooltip: 'ปิด',
                                          ),
                                        ],
                                      ),

                                      content: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          // จำกัดขนาดให้พอดีทุกจอ
                                          maxWidth: 480,
                                          // ปรับสูงสุดเพื่อเลี่ยง overflow
                                          maxHeight: 620,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // Header: วิธีชำระ + ยอดรวม
                                              // Container(
                                              //   padding: const EdgeInsets.all(12),
                                              //   decoration: BoxDecoration(
                                              //     color: Colors.white.withOpacity(0.9),
                                              //     borderRadius: BorderRadius.circular(12),
                                              //   ),
                                              //   child: Column(
                                              //     crossAxisAlignment:
                                              //         CrossAxisAlignment.start,
                                              //     children: [
                                              //       // ชื่อวิธีชำระ
                                              //       Row(
                                              //         children: [
                                              //           const Icon(Icons.payments, size: 20),
                                              //           const SizedBox(width: 8),
                                              //           Expanded(
                                              //             child: Text(
                                              //               (paymentName1 ??
                                              //                   paymentName2 ??
                                              //                   'ชำระเงิน'),
                                              //               style: Theme.of(context)
                                              //                   .textTheme
                                              //                   .titleMedium
                                              //                   ?.copyWith(
                                              //                       fontWeight:
                                              //                           FontWeight.w700),
                                              //               overflow: TextOverflow.ellipsis,
                                              //             ),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //       const SizedBox(height: 8),
                                              //       // แสดงยอดรวมและยอด Online
                                              //       Row(
                                              //         children: [
                                              //           const Icon(Icons.receipt_long,
                                              //               size: 18),
                                              //           const SizedBox(width: 6),
                                              //           Text('รวมทั้งหมด: ',
                                              //               style: Theme.of(context)
                                              //                   .textTheme
                                              //                   .bodyMedium),
                                              //           Text(
                                              //             sum.toStringAsFixed(2),
                                              //             style: Theme.of(context)
                                              //                 .textTheme
                                              //                 .titleMedium
                                              //                 ?.copyWith(
                                              //                     fontWeight:
                                              //                         FontWeight.bold),
                                              //           ),
                                              //           const Spacer(),
                                              //           const Icon(Icons.qr_code_2, size: 18),
                                              //           const SizedBox(width: 6),
                                              //           Text('ผ่าน Online: ',
                                              //               style: Theme.of(context)
                                              //                   .textTheme
                                              //                   .bodyMedium),
                                              //           Text(
                                              //             totalQr_.toStringAsFixed(2),
                                              //             style: Theme.of(context)
                                              //                 .textTheme
                                              //                 .titleMedium
                                              //                 ?.copyWith(
                                              //                     fontWeight:
                                              //                         FontWeight.bold),
                                              //           ),
                                              //         ],
                                              //       ),
                                              //     ],
                                              //   ),
                                              // ),

                                              // const SizedBox(height: 12),

                                              // การ์ด QR + ข้อมูลธนาคาร
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.06),
                                                      blurRadius: 16,
                                                      offset:
                                                          const Offset(0, 6),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    // ชื่อธนาคาร + เลขบัญชี (ถ้ามี)
                                                    // Row(
                                                    //   children: [
                                                    //     const Icon(Icons.account_balance,
                                                    //         size: 20),
                                                    //     const SizedBox(width: 8),
                                                    //     Expanded(
                                                    //       child: Text(
                                                    //         // ปรับชื่อ/เลขบัญชีจากตัวแปรเดิมของคุณได้
                                                    //         (paymentName1 == 'เงินโอน' ||
                                                    //                 paymentName2 == 'เงินโอน')
                                                    //             ? 'โอนผ่านธนาคาร'
                                                    //             : 'ข้อมูลบัญชี',
                                                    //         style: Theme.of(context)
                                                    //             .textTheme
                                                    //             .titleMedium
                                                    //             ?.copyWith(
                                                    //                 fontWeight:
                                                    //                     FontWeight.w700),
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                    const SizedBox(height: 8),

                                                    // Box QR (สี่เหลี่ยมจัตุรัส โค้งมน)
                                                    AspectRatio(
                                                      aspectRatio: 0.8,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        child: Container(
                                                          color:
                                                              Colors.grey[100],
                                                          child: imgFile.isEmpty
                                                              ? Center(
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Icon(
                                                                          Icons
                                                                              .image_not_supported,
                                                                          size:
                                                                              56,
                                                                          color:
                                                                              Colors.grey),
                                                                      const SizedBox(
                                                                          height:
                                                                              8),
                                                                      Text(
                                                                          'ไม่มี QR หรือยังไม่ตั้งค่า',
                                                                          style: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyMedium),
                                                                    ],
                                                                  ),
                                                                )
                                                              : Image.network(
                                                                  imgUrl,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  // placeholder อย่างหยาบ ๆ (ไม่ใช้แพ็กเกจเพิ่ม)
                                                                  loadingBuilder:
                                                                      (context,
                                                                          child,
                                                                          progress) {
                                                                    if (progress ==
                                                                        null)
                                                                      return child;
                                                                    return Center(
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const SizedBox(
                                                                            height:
                                                                                36,
                                                                            width:
                                                                                36,
                                                                            child:
                                                                                CircularProgressIndicator(strokeWidth: 3),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 8),
                                                                          Text(
                                                                              'กำลังโหลดรูป...',
                                                                              style: Theme.of(context).textTheme.bodySmall),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Center(
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Icon(
                                                                              Icons.broken_image,
                                                                              color: Colors.red,
                                                                              size: 40),
                                                                          const SizedBox(
                                                                              height: 8),
                                                                          Text(
                                                                              'โหลดรูปภาพไม่สำเร็จ',
                                                                              style: Theme.of(context).textTheme.bodyMedium),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                        ),
                                                      ),
                                                    ),

                                                    // const SizedBox(height: 12),

                                                    // // ชื่อไฟล์/ลิงก์ และปุ่มลัด
                                                    // Row(
                                                    //   children: [
                                                    //     Expanded(
                                                    //       child: Text(
                                                    //         imgFile.isEmpty ? '—' : imgFile,
                                                    //         overflow: TextOverflow.ellipsis,
                                                    //         style: Theme.of(context)
                                                    //             .textTheme
                                                    //             .bodySmall,
                                                    //       ),
                                                    //     ),
                                                    //     const SizedBox(width: 8),
                                                    //     if (imgFile.isNotEmpty)
                                                    //       OutlinedButton.icon(
                                                    //         style: OutlinedButton.styleFrom(
                                                    //           padding:
                                                    //               const EdgeInsets.symmetric(
                                                    //                   horizontal: 10,
                                                    //                   vertical: 8),
                                                    //           shape: RoundedRectangleBorder(
                                                    //               borderRadius:
                                                    //                   BorderRadius.circular(
                                                    //                       10)),
                                                    //         ),
                                                    //         onPressed: () {
                                                    //           // เปิดรูปในเบราว์เซอร์ภายนอกได้ตามต้องการ
                                                    //           // launchUrlString(imgUrl); // ถ้าใช้ url_launcher
                                                    //         },
                                                    //         icon: const Icon(
                                                    //             Icons.open_in_new,
                                                    //             size: 18),
                                                    //         label: const Text('เปิดรูป'),
                                                    //       ),
                                                    //   ],
                                                    // ),

                                                    const SizedBox(height: 8),

                                                    // แถว copy เลขบัญชี (ถ้าคุณมีตัวแปร bankAccount/bankName ให้ pass มาจาก onChanged)
                                                    // Row(
                                                    //   children: [
                                                    //     const Icon(Icons.credit_card,
                                                    //         size: 18),
                                                    //     const SizedBox(width: 6),
                                                    //     Expanded(
                                                    //       child: Text(
                                                    //         // ใส่เลขบัญชีจาก state ของคุณ (ตัวอย่างใช้ Form_payment1/2 ไม่เกี่ยว)
                                                    //         // ถ้าคุณเก็บ bankAccount/bankName ใน state ให้เอามาแทนข้อความด้านล่าง
                                                    //         'คัดลอกเลขบัญชีเพื่อโอนเงิน',
                                                    //         style: Theme.of(context)
                                                    //             .textTheme
                                                    //             .bodyMedium,
                                                    //       ),
                                                    //     ),
                                                    //     TextButton.icon(
                                                    //       onPressed: () async {
                                                    //         // import 'package:flutter/services.dart';
                                                    //         // await Clipboard.setData(ClipboardData(text: bankAccount));
                                                    //         ScaffoldMessenger.of(context)
                                                    //             .showSnackBar(
                                                    //           const SnackBar(
                                                    //               content: Text(
                                                    //                   'คัดลอกเลขบัญชีแล้ว')),
                                                    //         );
                                                    //       },
                                                    //       icon: const Icon(Icons.copy,
                                                    //           size: 18),
                                                    //       label: const Text('คัดลอก'),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                  ],
                                                ),
                                              ),

                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // ปุ่มด้านล่าง
                                      // actions: [
                                      //   TextButton.icon(
                                      //     onPressed: () => Navigator.pop(context),
                                      //     icon: const Icon(Icons.close),
                                      //     label: const Text('ปิด'),
                                      //   ),
                                      //   // ถ้าต้องการปุ่ม “ยืนยันชำระ” ใส่ตรงนี้ได้
                                      //   // ElevatedButton.icon(
                                      //   //   onPressed: () { ... },
                                      //   //   icon: const Icon(Icons.check_circle),
                                      //   //   label: const Text('ยืนยันชำระ'),
                                      //   // ),
                                      // ],
                                    );
                                  },
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 12),
                        ),
                        icon: const Icon(Icons.qr_code),
                        label: const Text(
                          'แสดง QR',
                          style: TextStyle(
                            fontFamily: Font_.Fonts_T,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
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

          SizedBox(
            height: 6,
          ),
          _buttonfool()
        ],
      ),
    );
  }

  Widget _buttonfool() {
    Future<void> _showBlockingLoader(BuildContext context) async {
      showDialog(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        barrierColor: Colors.black26,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
      // ให้ UI วาดเฟรมแรก
      await Future.delayed(const Duration(milliseconds: 16));
    }

    bool _isEnabled() {
      // if (ser_paymentMethodId == null) return false;
      if (ser_paymentMethodId == 2) return true; // เงินสด ไม่ต้องสลิป
      return (_stepProgressController.currentStep == 0)
          ? base64_Slip != null
          : Signature_user != null; // ช่องทางอื่น ต้องมีสลิป
    }

    Future<void> _navigateToResult(BuildContext context) async {
      final nav = Navigator.of(context, rootNavigator: true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.popOnSuccess) {
          if (nav.canPop()) nav.pop(true);
        } else {
          nav.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => AdminScafScreen(
                route: 'ใบอนุญาต',
                route_getdata: widget.uuid_Request.toString(),
              ),
            ),
            (r) => false,
          );
        }
      });
    }

    Future<void> _runUploadReceiptFlow(BuildContext context) async {
      final nav = Navigator.of(context, rootNavigator: true);
      await _showBlockingLoader(context);
      try {
        final result = await PaypickAndUpload_Receipt(
          context,
          '$uuid_postpayment',
          '${widget.uuid_Request}',
          document_uuid_receipt.toString(),
          'PDF',
          reviewDetail,
          expAutoModels,
          jsonDataReceipt,
          Signature_user,
          fullNameAdmin,
          positionAdmin,
        );
        if (nav.canPop()) nav.pop(); // ปิด loader
        if (result != null) {
          await _navigateToResult(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('❌ อัปโหลดใบเสร็จไม่สำเร็จ')),
          );
        }
      } catch (e) {
        if (nav.canPop()) nav.pop();
        // debugPrint('❌ Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ เกิดข้อผิดพลาด: $e')),
        );
      }
    }

    Future<void> _callPaymentAndGo(BuildContext context) async {
      // ส่งชำระ (เงินสด/พร้อมเพย์/โอน ฯลฯ)
      if (Form_payment1.text.isEmpty || Form_payment1.text == '0.00') {
        Dialog_error(context, 'กรุณากรอกจำนวนเงินรับมา');
        return;
      }
      if (Form_docnobill.text == null ||
          Form_docnobill.text == '' ||
          Form_docnobill.text == 'null') {
        print(uuid_postpayment);
        Dialog_error(context, 'กรุณาระบุเลขที่ใบเสร็จ');
        return;
      }
      // ช่องทางที่ไม่ใช่เงินสด ต้องมีสลิป
      if (ser_paymentMethodId != 2 && base64_Slip == null) {
        Dialog_error(context, 'กรุณาอัพโหลดหลักฐานการชำระ');
        return;
      }

      final nav = Navigator.of(context, rootNavigator: true);
      await _showBlockingLoader(context);

      try {
        final respAddon = await Post_GC_payment_addon(
          uuidPayment: uuid_postpayment.toString(),
          nobill: Form_Nobill.text.toString(),
          docnobill: Form_docnobill.text.toString(),
          billdate: Value_newDateY1_docbill.toString(),
        );
        if (respAddon?.statusCode == 200) {
          final resp = await PUT_GC_payment(
            requestUuid: valueBodyPost["requestUuid"] as String,
            paymentMethodId:
                int.parse(valueBodyPost["paymentMethodId"].toString()),
            bankaccountId: int.parse(valueBodyPost["bankaccountId"].toString()),
            paidat: valueBodyPost["paidat"].toString(),
            referencecode: valueBodyPost["referencecode"] as String,
            reference1: valueBodyPost["reference1"] as String,
            reference2: valueBodyPost["reference2"] as String,
            paymentAmount:
                double.parse(valueBodyPost["paymentAmount"].toString()),
            paymentReceived: double.tryParse(Form_payment1.text) ?? 0.00,
            uuidPayment: uuid_postpayment.toString(),
            slipDate: Value_newDateY1.toString(),
            slipPdate: Value_newDateY.toString(),
            slipTime: Form_time.text.toString(),
          );

          if (nav.canPop()) nav.pop(); // ปิด loader

          if (resp?.statusCode == 200) {
            final body = jsonDecode(resp!.body);
            final doc = body['data']?['document'];
            final meta = body['data']?['meta'];

            final documentUuid = doc?['uuid']?.toString() ?? '';
            final receiptDocno = doc?['document_no']?.toString() ?? '';
            final receiptDate = doc?['slip_pdate']?.toString() ?? '';

            final clientsName = meta?['client']?['scname']?.toString() ?? '';
            final znName = meta?['new_request']?['zn']?.toString() ?? '';
            final lnName = meta?['new_request']?['ln']?.toString() ?? '';

            setState(() {
              jsonDataReceipt = {
                "documentUuid": documentUuid,
                "clientsName": clientsName,
                "receiptDocno": receiptDocno,
                "receiptDate": receiptDate,
                "zn": znName,
                "receilnptDate": lnName,
              };
              if (documentUuid.isNotEmpty) {
                document_uuid_receipt = documentUuid;
              }
              // widget.uuid_Request = valueBodyPost["requestUuid"] as String;
            });

            await _navigateToResult(context);
          } else {
            Dialog_error(context, 'Error ${resp?.statusCode}');
          }
        } else {
          Dialog_error(context, 'Error ${respAddon?.statusCode}');
        }
      } catch (e) {
        if (nav.canPop()) nav.pop();
        //    debugPrint('❌ Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ เกิดข้อผิดพลาด: $e')),
        );
      }
    }

    Future<void> _handlePress(BuildContext context) async {
      // บังคับ validate เงื่อนไขก่อน
      if (!_isEnabled()) {
        if (ser_paymentMethodId == null) {
          Dialog_error(context, 'กรุณาเลือกรูปแบบชำระ');
        } else if (Form_docnobill.text == null ||
            Form_docnobill.text == '' ||
            Form_docnobill.text == 'null') {
          print(uuid_postpayment);
          Dialog_error(context, 'กรุณาระบุเลขที่ใบเสร็จ');
        } else if (ser_paymentMethodId != 2 && base64_Slip == null) {
          Dialog_error(context, 'กรุณาอัพโหลดหลักฐานการชำระ22');
        }
        return;
      }

      // โฟลว์ตาม step / ช่องทาง
      if (_stepProgressController.currentStep == 1) {
        await _runUploadReceiptFlow(context);
        return;
      }
      await _callPaymentAndGo(context);
    }

    final enabled = _isEnabled();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppbackgroundColor.Abg_Colors,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _loadingTranslated
            ? const SizedBox.shrink()
            : OtpTimerButton(
                height: 50,
                duration: 3,
                radius: 8,
                buttonType: ButtonType.elevated_button,
                loadingIndicator:
                    const CircularProgressIndicator(strokeWidth: 2),
                text: Text(
                  'รับชำระ ',
                  // '$enabled รับชำระ  ',
                  style: TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text1_,
                    fontWeight: FontWeight.bold,
                    fontFamily: FontWeight_.Fonts_T, // ← ของคุณเดิม
                  ),
                ),
                backgroundColor: (Form_docnobill.text == null ||
                        Form_docnobill.text == '' ||
                        Form_docnobill.text == 'null')
                    ? Colors.grey
                    : enabled
                        ? Colors.orange
                        : Colors.grey,
                textColor: Colors.black,
                onPressed: () => _handlePress(context),
              ),
      ),
    );
  }

  // Widget _buttonfool() {
  //   return Padding(
  //     padding: const EdgeInsets.all(4.0),
  //     child: Container(
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         color: AppbackgroundColor.Abg_Colors,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: _loadingTranslated
  //           ? const SizedBox()
  //           : OtpTimerButton(
  //               height: 50,
  //               text: Text(
  //                 'รับชำระ',
  //                 // snapshot.data ?? '',
  //                 style: TextStyle(
  //                   color: PeopleChaoScreen_Color.Colors_Text1_,
  //                   fontWeight: FontWeight.bold,
  //                   fontFamily: FontWeight_.Fonts_T,
  //                 ),
  //               ),
  //               duration: 3,
  //               radius: 8,
  //               backgroundColor: (ser_paymentMethodId == 2)
  //                   ? Colors.orange
  //                   : (base64_Slip != null && ser_paymentMethodId != null)
  //                       ? Colors.orange
  //                       : Colors.grey,
  //               textColor: Colors.black,
  //               buttonType: ButtonType.elevated_button,
  //               loadingIndicator: const CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 color: Colors.red,
  //               ),
  //               loadingIndicatorColor: Colors.red,
  //               onPressed:
  //                   //  (1 == 1)
  //                   //     ? () async {
  //                   //         _stepProgressController.nextStep();
  //                   //       }
  //                   //     :
  //                   (_stepProgressController.currentStep == 1)
  //                       ? () async {
  //                           Future<void> showBlockingLoader(
  //                               BuildContext context) async {
  //                             showDialog(
  //                               context: context,
  //                               useRootNavigator: true,
  //                               barrierDismissible: false,
  //                               barrierColor: Colors.black26,
  //                               builder: (_) => WillPopScope(
  //                                 onWillPop: () async => false, // ❌ ห้ามกด back
  //                                 child: const Center(
  //                                     child: CircularProgressIndicator()),
  //                               ),
  //                             );
  //                           }

  //                           final nav =
  //                               Navigator.of(context, rootNavigator: true);

  //                           await showBlockingLoader(
  //                               context); // แสดง loader ทันที
  //                           await Future.delayed(const Duration(
  //                               milliseconds: 16)); // ให้ UI วาดเฟรม

  //                           try {
  //                             // 2) ให้โอกาส UI วาดเฟรมของ dialog สัก 1 เฟรม
  //                             await Future.delayed(
  //                                 const Duration(milliseconds: 16));

  //                             final result = await PaypickAndUpload_Receipt(
  //                               context,
  //                               '$uuid_postpayment',
  //                               '${widget.uuid_Request}',
  //                               document_uuid_receipt.toString(),
  //                               'PDF',
  //                               reviewDetail,
  //                               expAutoModels,
  //                               jsonDataReceipt,
  //                               Signature_user,
  //                               fullNameAdmin,
  //                               positionAdmin,
  //                             );

  //                             // 3) ปิด loading อย่างปลอดภัย
  //                             if (nav.canPop()) nav.pop();

  //                             if (result != null) {
  //                               final prefs =
  //                                   await SharedPreferences.getInstance();
  //                               final _route = prefs.getString('route');

  //                               // ถ้าจะนำทางต่อ ให้ทำหลังปิด dialog แล้วเสมอ (เฟรมถัดไปยิ่งดี)
  //                               WidgetsBinding.instance
  //                                   .addPostFrameCallback((_) {
  //                                 nav.pushAndRemoveUntil(
  //                                   MaterialPageRoute(
  //                                     builder: (_) => AdminScafScreen(
  //                                       route: 'ใบอนุญาต',
  //                                       route_getdata:
  //                                           widget.uuid_Request.toString(),
  //                                     ),
  //                                   ),
  //                                   (r) => false,
  //                                 );
  //                               });
  //                             } else {
  //                               ScaffoldMessenger.of(context).showSnackBar(
  //                                 const SnackBar(
  //                                     content:
  //                                         Text('❌ อัปโหลดใบเสร็จไม่สำเร็จ')),
  //                               );
  //                             }
  //                           } catch (e) {
  //                             if (nav.canPop())
  //                               nav.pop(); // ปิด loading ถ้ายังเปิดอยู่
  //                             debugPrint('❌ Error: $e');
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               SnackBar(
  //                                   content: Text('⚠️ เกิดข้อผิดพลาด: $e')),
  //                             );
  //                           }
  //                         }
  //                       : (ser_paymentMethodId == null)
  //                           ? () async {
  //                               Dialog_error(context, 'กรุณาเลือกรูปแบบชำระ');
  //                             }
  //                           : (ser_paymentMethodId == 2)
  //                               ? () async {
  //                                   print('DartErro2');
  //                                   if (Form_payment1.text.isNotEmpty &&
  //                                       Form_payment1.text != '' &&
  //                                       Form_payment1.text != '0.00') {
  //                                     // print(valueBodyPost);
  //                                     PUT_GC_payment(
  //                                       requestUuid:
  //                                           valueBodyPost["requestUuid"]
  //                                               as String,
  //                                       paymentMethodId: int.parse(
  //                                           valueBodyPost["paymentMethodId"]
  //                                               .toString()),
  //                                       // paymentMethodCode: int.parse(
  //                                       //     valueBodyPost["paymentMethodCode"]
  //                                       //         .toString()),
  //                                       bankaccountId: int.parse(
  //                                           valueBodyPost["bankaccountId"]
  //                                               .toString()),
  //                                       paidat:
  //                                           valueBodyPost["paidat"].toString(),
  //                                       referencecode:
  //                                           valueBodyPost["referencecode"]
  //                                               as String,
  //                                       reference1: valueBodyPost["reference1"]
  //                                           as String,
  //                                       reference2: valueBodyPost["reference2"]
  //                                           as String,
  //                                       paymentAmount: double.parse(
  //                                           valueBodyPost["paymentAmount"]
  //                                               .toString()),
  //                                       paymentReceived: double.parse(
  //                                               Form_payment1.text
  //                                                   .toString()) ??
  //                                           0.00,
  //                                       uuidPayment:
  //                                           uuid_postpayment.toString(),
  //                                       slipDate: Value_newDateY1.toString(),
  //                                       slipPdate: Value_newDateY.toString(),
  //                                       slipTime: Form_time.text.toString(),
  //                                     ).then((value) async {
  //                                       if (value?.statusCode == 200) {
  //                                         final bodyStep1 =
  //                                             jsonDecode(value!.body);
  //                                         print(bodyStep1);
  //                                         final document =
  //                                             bodyStep1['data']?['document'];
  //                                         final meta =
  //                                             bodyStep1['data']?['meta'];

  //                                         final documentUuid =
  //                                             document?['uuid']?.toString() ??
  //                                                 '';
  //                                         final receiptDocno =
  //                                             document?['document_no']
  //                                                     ?.toString() ??
  //                                                 '';
  //                                         final receiptDate =
  //                                             document?['slip_pdate']
  //                                                     ?.toString() ??
  //                                                 '';

  //                                         final clientsName = meta?['client']
  //                                                     ?['scname']
  //                                                 ?.toString() ??
  //                                             '';
  //                                         final znName = meta?['new_request']
  //                                                     ?['zn']
  //                                                 ?.toString() ??
  //                                             '';
  //                                         final lnName = meta?['new_request']
  //                                                     ?['ln']
  //                                                 ?.toString() ??
  //                                             '';
  //                                         setState(() {
  //                                           jsonDataReceipt = {
  //                                             "documentUuid": documentUuid,
  //                                             "clientsName": clientsName,
  //                                             "receiptDocno": receiptDocno,
  //                                             "receiptDate": receiptDate,
  //                                             "nameTh": '',
  //                                             "zn": znName,
  //                                             "receilnptDate": lnName
  //                                           };
  //                                         });
  //                                         if (documentUuid.isNotEmpty) {
  //                                           // List<ReceiptModel> receiptmodel = [];
  //                                           setState(() =>
  //                                               document_uuid_receipt =
  //                                                   documentUuid);
  //                                         }
  //                                         Future.delayed(
  //                                             const Duration(milliseconds: 400),
  //                                             () async {
  //                                           SharedPreferences preferences =
  //                                               await SharedPreferences
  //                                                   .getInstance();
  //                                           String? _route =
  //                                               preferences.getString('route');
  //                                           MaterialPageRoute
  //                                               materialPageRoute =
  //                                               MaterialPageRoute(
  //                                                   builder: (BuildContext
  //                                                           context) =>
  //                                                       AdminScafScreen(
  //                                                           route: 'ใบอนุญาต',
  //                                                           route_getdata: widget
  //                                                               .uuid_Request
  //                                                               .toString()));
  //                                           Navigator.pushAndRemoveUntil(
  //                                               context,
  //                                               materialPageRoute,
  //                                               (route) => false);
  //                                         });
  //                                       } else {
  //                                         Dialog_error(context,
  //                                             'Error ${value?.statusCode}');
  //                                       }

  //                                       SharedPreferences preferences =
  //                                           await SharedPreferences
  //                                               .getInstance();
  //                                       String? _route =
  //                                           preferences.getString('route');
  //                                       MaterialPageRoute materialPageRoute =
  //                                           MaterialPageRoute(
  //                                               builder: (BuildContext
  //                                                       context) =>
  //                                                   AdminScafScreen(
  //                                                       route: 'ใบอนุญาต',
  //                                                       route_getdata: widget
  //                                                           .uuid_Request
  //                                                           .toString()));
  //                                       Navigator.pushAndRemoveUntil(
  //                                           context,
  //                                           materialPageRoute,
  //                                           (route) => false);
  //                                     });
  //                                   } else {
  //                                     Dialog_error(
  //                                         context, 'กรุณากรอกจำนวนเงินรับมา');
  //                                   }
  //                                 }
  //                               : () async {
  //                                   print('DartErro3');
  //                                   if (base64_Slip != null) {
  //                                     if (Form_payment1.text.isNotEmpty &&
  //                                             Form_payment1.text != '' &&
  //                                             Form_payment1.text != '0.00'
  //                                         //  &&
  //                                         // double.parse(
  //                                         //         Form_payment1.text ?? "0") <
  //                                         //     _totalSumpay!
  //                                         ) {
  //                                       print(valueBodyPost);
  //                                       PUT_GC_payment(
  //                                         requestUuid:
  //                                             valueBodyPost["requestUuid"]
  //                                                 as String,
  //                                         paymentMethodId: int.parse(
  //                                             valueBodyPost["paymentMethodId"]
  //                                                 .toString()),
  //                                         // paymentMethodCode: int.parse(
  //                                         //     valueBodyPost["paymentMethodCode"]
  //                                         //         .toString()),
  //                                         bankaccountId: int.parse(
  //                                             valueBodyPost["bankaccountId"]
  //                                                 .toString()),
  //                                         paidat: valueBodyPost["paidat"]
  //                                             .toString(),
  //                                         referencecode:
  //                                             valueBodyPost["referencecode"]
  //                                                 as String,
  //                                         reference1:
  //                                             valueBodyPost["reference1"]
  //                                                 as String,
  //                                         reference2:
  //                                             valueBodyPost["reference2"]
  //                                                 as String,
  //                                         paymentAmount: double.parse(
  //                                             valueBodyPost["paymentAmount"]
  //                                                 .toString()),
  //                                         paymentReceived: double.parse(
  //                                                 Form_payment1.text
  //                                                     .toString()) ??
  //                                             0.00,
  //                                         uuidPayment:
  //                                             uuid_postpayment.toString(),
  //                                         slipDate: Value_newDateY1.toString(),
  //                                         slipPdate: Value_newDateY.toString(),
  //                                         slipTime: Form_time.text.toString(),
  //                                       ).then((value) async {
  //                                         if (value?.statusCode == 200) {
  //                                           final bodyStep1 =
  //                                               jsonDecode(value!.body);
  //                                           print(bodyStep1);
  //                                           final document =
  //                                               bodyStep1['data']?['document'];
  //                                           final meta =
  //                                               bodyStep1['data']?['meta'];

  //                                           final documentUuid =
  //                                               document?['uuid']?.toString() ??
  //                                                   '';
  //                                           final receiptDocno =
  //                                               document?['document_no']
  //                                                       ?.toString() ??
  //                                                   '';
  //                                           final receiptDate =
  //                                               document?['slip_pdate']
  //                                                       ?.toString() ??
  //                                                   '';

  //                                           final clientsName = meta?['client']
  //                                                       ?['scname']
  //                                                   ?.toString() ??
  //                                               '';
  //                                           final znName = meta?['new_request']
  //                                                       ?['zn']
  //                                                   ?.toString() ??
  //                                               '';
  //                                           final lnName = meta?['new_request']
  //                                                       ?['ln']
  //                                                   ?.toString() ??
  //                                               '';
  //                                           setState(() {
  //                                             jsonDataReceipt = {
  //                                               "documentUuid": documentUuid,
  //                                               "clientsName": clientsName,
  //                                               "receiptDocno": receiptDocno,
  //                                               "receiptDate": receiptDate,
  //                                               "zn": znName,
  //                                               "receilnptDate": lnName
  //                                             };
  //                                           });
  //                                           if (documentUuid.isNotEmpty) {
  //                                             setState(() =>
  //                                                 document_uuid_receipt =
  //                                                     documentUuid);
  //                                           }
  //                                           Future.delayed(
  //                                               const Duration(
  //                                                   milliseconds: 400),
  //                                               () async {
  //                                             SharedPreferences preferences =
  //                                                 await SharedPreferences
  //                                                     .getInstance();
  //                                             String? _route = preferences
  //                                                 .getString('route');
  //                                             MaterialPageRoute
  //                                                 materialPageRoute =
  //                                                 MaterialPageRoute(
  //                                                     builder: (BuildContext
  //                                                             context) =>
  //                                                         AdminScafScreen(
  //                                                             route: 'ใบอนุญาต',
  //                                                             route_getdata:
  //                                                                 widget.uuid_Request ??
  //                                                                     ""));
  //                                             Navigator.pushAndRemoveUntil(
  //                                                 context,
  //                                                 materialPageRoute,
  //                                                 (route) => false);
  //                                           });
  //                                         } else {
  //                                           Dialog_error(context,
  //                                               'Error ${value?.statusCode}');
  //                                         }
  //                                         // Dia_log1(context);
  //                                       });
  //                                     } else {
  //                                       Dialog_error(
  //                                           context, 'กรุณากรอกจำนวนเงินรับมา');
  //                                     }
  //                                   } else {
  //                                     Dialog_error(context,
  //                                         'กรุณาอัพโหลดหลักฐานการชำระ');
  //                                   }
  //                                 },
  //             ),
  //     ),
  //   );
  // }
}
