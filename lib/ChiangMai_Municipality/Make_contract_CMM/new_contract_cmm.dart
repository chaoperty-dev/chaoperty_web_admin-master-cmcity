import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/Model/Get_easyslip_Model.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grouped_buttons_ns/grouped_buttons_ns.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../../AdminScaffold/AdminScaffold.dart';
import '../../Constant/Myconstant.dart';
import '../../Model/GetArea_Model.dart';
import '../../Model/GetC_Quot_Model.dart';
import '../../Model/GetC_Quot_Select_Model.dart';
import '../../Model/GetCustomer_Model.dart';
import '../../Model/GetExp_type_auto.dart';
import '../../Responsive/responsive.dart';
import '../../Style/Translate.dart';
import '../../Style/colors.dart';

import '../Model/Dataconfig_Model.dart';
import '../Model/Document_Model.dart';
import '../Model/Person&Shop_Model.dart';
import '../PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import '../cignaturepad_cmm.dart';
import '../unity/API_addfile.dart';
import '../unity/API_admin_requests.dart';
import '../unity/API_expauto.dart';
import '../unity/API_payment.dart';
import '../unity/Enum.dart';
import '../unity/FormatDate.dart';
import '../unity/ReusableSignaturePad.dart';
import '../unity/show_dialog_cmm.dart';
import 'payment_contract_cmm.dart';
import '../unity/Enum.dart';

class Newcontract_cmm extends StatefulWidget {
  final Get_Value_area_index;
  final Get_Value_area_ln;
  final Get_Value_area_sum;
  final Get_Value_rent_sum;
  final Get_Value_page;
  String Get_Value_uuid;
  String Get_Value_step;
  String Get_Value_payment_uuid;
  String Get_Value_payment_amount;
  List<Map<String, dynamic>> paymentjsonx;

  Newcontract_cmm(
      {super.key,
      this.Get_Value_area_index,
      this.Get_Value_area_ln,
      this.Get_Value_area_sum,
      this.Get_Value_rent_sum,
      this.Get_Value_page,
      required this.Get_Value_uuid,
      required this.Get_Value_step,
      required this.Get_Value_payment_uuid,
      required this.Get_Value_payment_amount,
      required this.paymentjsonx});

  @override
  State<Newcontract_cmm> createState() => _Newcontract_cmmState();
}

class _Newcontract_cmmState extends State<Newcontract_cmm> {
  var nFormat = NumberFormat("#,##0.00", "en_US");
  final GlobalKey<SfSignaturePadState> signatureKey1 = GlobalKey();
  DateTime _dateTime = DateTime.now();
  int ser_tap = 1;
  bool isLoading = false;
  bool isLoading_main = false;
  ////////////--------------------->
  List _selecteSer = [];
  List<String> _selecteSerbool = [];
  List<TextEditingController> _controllers_person = [];
  List<TextEditingController> _controllers_shop = [];
  List<TextEditingController> _controllers_shop_sub = [];
  final _formKey_person = GlobalKey<FormState>();
  ////////////--------------------->
  List<CQuotModel> cQuotModels = [];
  List<AreaModel> areaModels = [];
  List<AreaModel> _areaModels = <AreaModel>[];
  List<CustomerModel> customerModels = [];
  List<CustomerModel> _customerModels = <CustomerModel>[];
  List<QuotxSelectModel> quotxSelectModels = [];
  List<ExpAutoModel> expAutoModels = [];

  ///------------------------------------------------------------>
  List<PersonFieldModel> data_person = data_persons;
  List<ShopFieldModel> data_shop = data_shops;
  List<ClientModel> clientModels = [];
  List<DocumentModel> documentModels = [];
  List<AttachmentsModel> attachments = [];
  List<DetailsModel> detailsModel = [];
  Map<String, dynamic> fullData = {};
  List data_cid = [];
  List data_title_doc = [];
  List data_title_receipt = [];

  ///------------------------------------------------------------>(stepper)
  int activeStep = 0; // stepper
  ////////////--------------------->
  double _area_sum = 0, _area_rent_sum = 0;
  ////////////--------------------->

  String? Value_D_read;
  String? cxname_card,
      cxname_lease,
      cxname_other,
      cxname_card_ser,
      cxname_lease_ser,
      cxname_other_ser,
      Get_Value_cid,
      foder;
  ////////////--------------------->
  String Value_rental_type_3 = '';
  String Value_rental_count_ = '';
  String Value_rental_type_ = '';
  var uuid_user;
  String? uuid_Request;
  dynamic data_response_Post_GC_payment = {};
  bool read_Only = false;
  ////////////--------------------->
  @override
  void initState() {
    super.initState();
    select_customer();
    Value_D_read = DateFormat('yyyy-MM-dd').format(_dateTime);
    _controllers_person = List.generate(
      data_person.length,
      (i) => TextEditingController(text: data_person[i].detail ?? ''),
    );
    _controllers_shop = List.generate(
      data_shop.length,
      (i) => TextEditingController(text: data_shop[i].detail ?? ''),
    );
    _controllers_shop_sub = List.generate(
      data_shop[0].detailsub.length,
      (i) =>
          TextEditingController(text: data_shop[0].detailsub[i].detail ?? ''),
    );
    Loading_Data_Step3();
    Loading_Data_config();
  }

  ////////////--------------------->
  @override
  void dispose() {
    for (var c in _controllers_person) {
      c.dispose();
    }
    for (var c in _controllers_shop) {
      c.dispose();
    }
    for (var c in _controllers_shop_sub) {
      c.dispose();
    }
    super.dispose();
  }

  ///////////------------------------------------>
  String? zone_Subser, zone_Subname, zone_ser, zone_name;
  final Form_zone_name = TextEditingController();
  final Form_ln_name = TextEditingController();
  Loading_Data_config() async {
    final cid = await getContractInfo(); // รอให้โหลดเสร็จก่อน
    final doc = await getDocumentDisplayFields();
    final receipt = await getReceiptDisplayFields();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      uuid_Request = widget.Get_Value_uuid.toString();
      zone_ser = preferences.getString('zoneSer');
      zone_name = preferences.getString('zonesName');
      zone_Subser = preferences.getString('zoneSubSer');
      zone_Subname = preferences.getString('zonesSubName');
      Form_zone_name.text = preferences.getString('zonesName')!;
      Form_ln_name.text = widget.Get_Value_area_ln!;
    });
    setState(() {
      data_cid = cid;
      data_title_doc = doc;
      data_title_receipt = receipt;
    });
    if (widget.Get_Value_uuid != null &&
        widget.Get_Value_uuid.toString() != '' &&
        widget.Get_Value_uuid.toString() != 'null') {
      setState(() {
        // uuid_user = widget.Get_Value_uuid.toString();
        activeStep = (int.tryParse(widget.Get_Value_step ?? '0') ?? 0);
        read_Only = true;
      });
      Loading_Data_Step2();
    }
    print('uuid_Request');
    print(uuid_Request);
  }

  Loading_Data_config2() async {
    final cid = await getContractInfo(); // รอให้โหลดเสร็จก่อน
    final doc = await getDocumentDisplayFields();
    final receipt = await getReceiptDisplayFields();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      uuid_Request = widget.Get_Value_uuid.toString();
      zone_ser = preferences.getString('zoneSer');
      zone_name = preferences.getString('zonesName');
      zone_Subser = preferences.getString('zoneSubSer');
      zone_Subname = preferences.getString('zonesSubName');
      Form_zone_name.text = preferences.getString('zonesName')!;
      Form_ln_name.text = widget.Get_Value_area_ln!;
    });
    setState(() {
      data_cid = cid;
      data_title_doc = doc;
      data_title_receipt = receipt;
    });
    if (widget.Get_Value_uuid != null &&
        widget.Get_Value_uuid.toString() != '' &&
        widget.Get_Value_uuid.toString() != 'null') {
      setState(() {
        // uuid_user = widget.Get_Value_uuid.toString();
        // activeStep = activeStep;
        read_Only = true;
      });
      Loading_Data_Step2();
    }
    print('uuid_Request');
    print(uuid_Request);
  }

  ///////////------------------------------------>
  Future<void> Loading_Data_Step2() async {
    print('Loading_Data_Step2');
    setState(() {
      isLoading = true;
      isLoading_main = true;
      clientModels.clear();
      documentModels.clear();
      attachments.clear();
      detailsModel.clear();
    });

    try {
      await Set_data(uuid_Request!, OutputType.full);
      // await Set_data(uuid_user, OutputType.documents);
      // await Set_data(uuid_user, OutputType.attachments);
    } catch (e) {
      print('❌ Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
        isLoading_main = false;
      });
    }
  }

  List<Map<String, dynamic>> jsonx = [];
  Loading_Data_Step3() async {
    // var uuid_user = 'd87fec79-6020-449f-8b8b-724e4d6a0d4c';

    final result = await read_GC_ExpAuto();
    print('Loading_Data_Step3');

    setState(() {
      expAutoModels = result;

      jsonx = result.map((e) => e.toJson()).toList();
    });
  }

//////////////------------------------------------------------------>
  String headerText() {
    switch (activeStep) {
      case 0:
        return 'ผู้เช่า ';
      case 1:
        return 'ข้อมูลการเช่า';
      case 2:
        return 'ค่าบริการ';

      case 3:
        return 'การชำระ';

      // case 4:
      //   return 'สัญญาเช่า';

      default:
        return '';
    }
  }

  void _goToNextStep() {
    setState(() {
      activeStep += 1;
      clientModels.clear();
      documentModels.clear();
      fullData.clear();
      attachments.clear();
    });
  }

//////////////------------------------------------------------------>

  Future<void> select_customer() async {
    if (customerModels.isNotEmpty) {
      setState(() {
        customerModels.clear();
        _customerModels.clear();
      });
    }

    var url = Uri.parse('${MyConstant().domain_v2}/lookup/customers');
    // var request = http.get(Uri.parse(url));

    var request = http.Request('GET', url);

    // request.headers.addAll({
    //   'Content-Type': 'application/json',
    //   'Authorization':
    //       'Bearer YOUR_TOKEN',
    // });

    try {
      //  var result = json.decode(response.body);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String jsonString = await response.stream.bytesToString();
        var result = json.decode(jsonString);
        // print(result);

        // ตรวจสอบว่า result เป็น Map และมี key 'data' ที่เป็น List
        if (result != null && result['data'] is List) {
          for (var map in result['data']) {
            CustomerModel customerModel = CustomerModel.fromJson(map);

            setState(() {
              customerModels.add(customerModel);
            });
          }
        }
      } else {
        print('Error: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    // print('customerModels.length');
    // print(customerModels.length);
  }

  Future<void> Set_data(String uuid, OutputType type) async {
    print('🔄 เริ่มโหลดข้อมูล: uuid = xx, type = $type');

    try {
      await setDataHandler(
        uuid: uuid,
        type: type,
        clientModels: clientModels,
        documentModels: documentModels,
        attachments: attachments,
        fullDataTarget: fullData,
        detailsModel: detailsModel,
        onComplete: () {
          setState(() {
            isLoading = false;
          });
          print('✅ โหลดข้อมูลเสร็จสิ้น: type = $type');
          AddForm_requests_uuid(0);
        },
      );
    } catch (e, stack) {
      print('❌ เกิดข้อผิดพลาดขณะโหลดข้อมูล [type: $type]');
      print('🧾 ข้อความ: $e');
      print('📍 StackTrace:\n$stack');
      setState(() {
        isLoading = false;
      });
    }
  }

  void AddForm_requests_uuid(index) {
    // แปลง CustomerModel ให้เป็น JSON string เพื่อแสดง
    String jsonString = jsonEncode(clientModels[index].toJson());
    ClientModel model = clientModels[index]; // ดึง object ออกมาก่อน
    DetailsModel details = detailsModel[index];
    // print(jsonString);
    //  final model = ClientModel.fromJson(jsonData);
    // print(model.json?['province']); // → เชียงใหม่
    List<String> data_person_add = [
      model.scname ?? "",
      model.tax ?? "",
      "-",
      "-",
      model.json?['number'] ?? "",
      model.json?['moo'] ?? "",
      model.json?['soi'] ?? "",
      model.json?['road '] ?? "",
      model.json?['tambon'] ?? "",
      model.json?['amphoe '] ?? "",
      model.json?['province '] ?? "",
      model.tel ?? "",
      model.addr_1 ?? ""
    ];

    List<String> data_shop_add = [
      "-",
      widget.Get_Value_area_sum ?? "",
      model.stype ?? "",
      model.sname ?? ""
    ];
    List<String> data_shopsub_add = [
      '-',
      Form_zone_name.text ?? "",
      widget.Get_Value_area_ln ?? "",
    ];
    List<String> data_details_add = [
      details.sdate!,
      details.ldate!,
      details.type!,
      '1',
    ];
    // อัปเดตข้อมูลทั้งหมด
    _updateCustomerData(
        data_person_add, data_shop_add, data_shopsub_add, data_details_add);
    // Dia_log1(context);
    // Timer(Duration(milliseconds: 300), () {
    //   Navigator.of(context).pop();
    // });
  }

  ///////////----------------------->
  void _updateCustomerData(personData, shopData, shopSubData, detailsData) {
    setState(() {
      // อัปเดต person
      for (int i = 0; i < personData.length; i++) {
        data_person[i].detail = personData[i].toString();
      }

      // อัปเดต shop
      for (int i = 0; i < shopData.length; i++) {
        data_shop[i].detail = shopData[i].toString();
      }

      // อัปเดต shop.sub เฉพาะ data_shop[0]
      for (int i = 0; i < shopSubData.length; i++) {
        data_shop[0].detailsub[i].detail = shopSubData[i].toString();
      }

      // รีสร้าง controller ทั้งหมด
      _controllers_person = List.generate(
        data_person.length,
        (i) => TextEditingController(text: data_person[i].detail),
      );

      _controllers_shop = List.generate(
        data_shop.length,
        (i) => TextEditingController(text: data_shop[i].detail),
      );

      _controllers_shop_sub = List.generate(
        data_shop[0].detailsub.length,
        (i) => TextEditingController(
          text: data_shop[0].detailsub[i].detail,
        ),
      );
    });
  }

  Future<void> createRequestUuid() async {
    if (uuid_Request == null || uuid_Request!.trim().isEmpty) {
      print('⚠️ UUID ไม่ถูกต้อง หรือไม่มีข้อมูล [ UUID : $uuid_Request]');
      return;
    }

    // ข้อมูลที่ต้องส่งไปยัง API
    final uuidcreate = uuid_Request;
    int moduleId = 1;
    print('✅ UUID : $uuidcreate');
    // กำหนด header สำหรับ JSON request
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // ถ้ามี auth
    };

    // ✅ ใช้ Uri พร้อม http:// เสมอ
    final url = Uri.parse('${MyConstant().domain_v1}/admin/requests');

    if (zone_ser == null ||
        zone_ser!.trim().isEmpty ||
        zone_name == null ||
        zone_name!.trim().isEmpty ||
        widget.Get_Value_area_index == null ||
        Form_ln_name.text.trim().isEmpty ||
        widget.Get_Value_area_sum == null) {
      print('❌ ข้อมูลไม่ครบ กรุณาตรวจสอบ');
      return;
    }
    // zone_Subser = preferences.getString('zoneSubSer');
    //   zone_Subname = preferences.getString('zonesSubName');
    // กำหนดข้อมูลลงใน Map ก่อน เพื่อความชัดเจน
    final requestData = {
      "module_id": moduleId,
      "clients_uuid": uuidcreate,
      "subzoneser": (zone_Subser == null || zone_Subser.toString() == '')
          ? '0'
          : zone_Subser!.trim(),
      "zser": zone_ser!.trim(),
      "zn": zone_name!.trim(),
      "aser": widget.Get_Value_area_index,
      "ln": Form_ln_name.text.trim(),
      "sdate": "${data_cid[0]["detail"].toString()}", // ควรดึงจากตัวแปร ถ้ามี
      "ldate": "${data_cid[1]["detail"].toString()}", // เช่นเดียวกัน
      "sertype": "1",
      "type": "รายปี",
      "qty": widget.Get_Value_area_sum,
      "json": {
        "number": _controllers_person[4].text.trim() ?? "",
        "moo": _controllers_person[5].text.trim() ?? "",
        "soi": _controllers_person[6].text.trim() ?? "",
        "road": _controllers_person[7].text.trim() ?? "",
        "tambon": _controllers_person[8].text.trim() ?? "",
        "amphoe": _controllers_person[9].text.trim() ?? "",
        "province": _controllers_person[10].text.trim() ?? "",
        "raw": ''
      }
    };
// แสดงข้อมูลก่อนยิง API เพื่อ debug
    print('📤 Sending data: ${jsonEncode(requestData)}');

// แปลงเป็น JSON
    final body = jsonEncode(requestData);
    try {
      // 🔁 ส่ง POST request
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      // ✅ ตรวจสอบ response
      if (response.statusCode == 201) {
        var result = json.decode(response.body);

        int nextStep = activeStep + 1;
        setState(() {
          uuid_Request = result["data"]["uuid"].toString();
        });
        Dialog_success(context, '✅ Success');

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            activeStep = nextStep;
          });
          print('✅ Success: Step : $activeStep');
          setState(() {
            widget.Get_Value_uuid = uuid_Request.toString();
          });

          Loading_Data_config2();
        });
        // _goToNextStep();
      } else {
        try {
          var result = json.decode(response.body);

          print('❌ Failed [${response.statusCode}]: $result');
        } catch (e) {
          print('❌ Failed [${response.statusCode}]: ไม่สามารถแปลง JSON ได้');
          print('📦 Raw body: ${response.body}');
        }
      }
    } catch (e) {
      print('❌ Error sending request: $e');
    }
  }

  /////////////---------------------------------------->
  @override
  Widget build(BuildContext context) {
    return (ser_tap == 2)
        ? SignaturePad_CMM()
        : (activeStep == 1)
            ? Stepper_2(context)
            : (activeStep == 2)
                ? Stepper_3(context)
                : (activeStep == 3)
                    ? Stepper_4(context)
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                        child: SingleChildScrollView(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            // height: MediaQuery.of(context).size.height + 300,
                            child: Column(children: [
                              Header_Stepper(context),
                              SizedBox(
                                child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                    }),
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85,
                                            // height: MediaQuery.of(context).size.height * 0.8,
                                            decoration: const BoxDecoration(
                                              color: AppbackgroundColor
                                                  .Sub_Abg_Colors,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft:
                                                      Radius.circular(10),
                                                  bottomRight:
                                                      Radius.circular(10)),
                                              // border: Border.all(color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(4.0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      child: Form(
                                                        key: _formKey_person,
                                                        child:
                                                            Column(children: [
                                                          Form_Person(context),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                        ]),
                                                      ),
                                                    )),
                                                Expanded(
                                                  flex: 2,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Column(children: [
                                                      Form_Shop(context),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Form_Cid(context),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      ActiveStep_Stepper(
                                                          context)
                                                    ]),
                                                  ),
                                                ),
                                              ],
                                            )))),
                              )
                            ]),
                          ),
                        ));
  }

  ActiveStep_Stepper(context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (activeStep != 3)
            if (activeStep >= 1)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        (activeStep == 1)
                            ? const Color.fromARGB(255, 243, 131, 130)
                            : Colors.grey,
                      ),
                    ),
                    onPressed: (activeStep == 0)
                        ? null
                        : () async {
                            setState(() {
                              activeStep = activeStep - 1;
                            });
                            setState(() {
                              clientModels.clear();
                              documentModels.clear();
                              fullData.clear();
                              attachments.clear();
                            });

                            if (activeStep == 1) {
                              Loading_Data_Step2();
                            }

                            //     SharedPreferences preferences =
                            //     await SharedPreferences
                            //         .getInstance();
                            // String? _route = preferences
                            //     .getString('route');
                            // MaterialPageRoute
                            //     materialPageRoute =
                            //     MaterialPageRoute(
                            //         builder: (BuildContext
                            //                 context) =>
                            //             AdminScafScreen(
                            //                 route:
                            //                     'RequestDetails_CMM'));
                            // Navigator
                            //     .pushAndRemoveUntil(
                            //         context,
                            //         materialPageRoute,
                            //         (route) => false);

                            // setState(() {
                            //   ser_tap = 2;
                            // });
                          },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Translate.TranslateAndSet_TextAutoSize(
                          (activeStep == 1) ? 'ยกเลิก/ปฏิเสธ' : 'กลับ',
                          ChaoAreaScreen_Color.Colors_Text2_,
                          TextAlign.center,
                          null,
                          FontWeight_.Fonts_T,
                          12,
                          18,
                          1),
                    ),
                  ),
                ),
              ),
          if (activeStep != 3)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.grey,
                    ),
                  ),
                  onPressed: (activeStep == 3)
                      ? null
                      : () async {
                          switch (activeStep) {
                            case 0:
                              await createRequestUuid();
                              break;

                            case 1:
                              final response = await readSubmitError(
                                  requests_uuid: '$uuid_Request');

                              if (response == null) {
                                Dialog_error(context,
                                    'เกิดข้อผิดพลาดในการตรวจสอบข้อมูล');
                                return;
                              }

                              final result = json.decode(response.body);

                              if (response.statusCode != 200) {
                                Dialog_error(context, '${result['message']}');
                                return;
                              }

                              _goToNextStep();

                              break;

                            case 2:
                              final response = await Post_GC_payment(
                                  requestUuid: '$uuid_Request',
                                  paymentMethodId: 0,
                                  paymentMethodCode: 0,
                                  bankaccountId: 0,
                                  paidat: '-',
                                  referencecode: '-',
                                  reference1: '-',
                                  reference2: '-',
                                  paymentAmount: 500.00,
                                  paymentReceived: 0,
                                  jsonx: jsonx);

                              if (response != null &&
                                  (response.statusCode == 201 ||
                                      response.statusCode == 409)) {
                                final jsonRes = json.decode(response.body);
                                setState(() {
                                  data_response_Post_GC_payment = jsonRes;
                                  widget.Get_Value_payment_uuid =
                                      jsonRes['data']['uuid'];
                                  // widget.Get_Value_payment_uuid
                                });
                                _goToNextStep();
                              } else {
                                Dialog_error(context,
                                    'ไม่สามารถดำเนินการได้: การรับชำระซ้ำซ้อนหรือผิดพลาด');
                              }

                              break;

                            default:
                            // _goToNextStep();
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Translate.TranslateAndSet_TextAutoSize(
                        (activeStep == 3) ? 'รับชำระ' : 'ยืนยัน/ถัดไป',
                        ChaoAreaScreen_Color.Colors_Text2_,
                        TextAlign.center,
                        null,
                        FontWeight_.Fonts_T,
                        12,
                        18,
                        1),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Form_Person(context) {
    return SizedBox(
        child: Column(children: [
      // for (var person
      //     in data_person)
      for (int index = 0; index < data_person.length; index++)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: (index + 1 == data_person.length) ? null : 40,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      '${data_person[index].title}',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                      showCursor: !read_Only,
                      readOnly: read_Only,
                      controller: _controllers_person[index],
                      maxLines: (index + 1 == data_person.length) ? 3 : 1,
                      // validator:
                      //     (value) {
                      //   if (value ==
                      //           null ||
                      //       value
                      //           .isEmpty) {
                      //     return '';
                      //   }
                      //   return null;
                      // },
                      // initialValue:
                      //     '${person["detail"]}',
                      onFieldSubmitted: (value) async {},

                      decoration: InputDecoration(
                          fillColor: Colors.white.withOpacity(0.3),
                          filled: true,
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.black,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                              width: 1,
                              color: Colors.grey,
                              // color: (_controllers_person[index].text == null || _controllers_person[index].text.toString() == '')
                              //     ? Colors.red
                              //     : Colors.grey,
                            ),
                          ),
                          // labelText: 'ระบุชื่อร้านค้า',
                          labelStyle: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontFamily: Font_.Fonts_T)),
                      // inputFormatters: <TextInputFormatter>[
                      //   // for below version 2 use this
                      //   FilteringTextInputFormatter
                      //       .allow(RegExp(r'[0-9]')),
                      //   // for version 2 and greater youcan also use this
                      //   FilteringTextInputFormatter
                      //       .digitsOnly
                      // ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    ]));
  }

  Form_Shop(context) {
    return SizedBox(
        child: Column(children: [
      // for (var shop in data_shop)
      for (int shop = 0; shop < data_shop.length; shop++)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      '${data_shop[shop].title}*',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                (data_shop[shop].ser.toString() == '1')
                    ? Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            for (int shop_sub = 0;
                                shop_sub < data_shop[shop].detailsub.length;
                                shop_sub++)
                              // for (var shop_sub
                              //     in data_shop[shop]
                              //         [
                              //         "detailsub"])
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  child: TextFormField(
                                    textAlign: TextAlign.left,
                                    keyboardType: TextInputType.number,
                                    showCursor: !read_Only,
                                    readOnly: read_Only,
                                    controller: _controllers_shop_sub[shop_sub],
                                    // initialValue:
                                    //     '${shop_sub["detail"]}',
                                    onFieldSubmitted: (value) async {},

                                    decoration: InputDecoration(
                                        fillColor:
                                            Colors.white.withOpacity(0.3),
                                        filled: true,
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.black,
                                          ),
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide: BorderSide(
                                            width: 1,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        labelText:
                                            '${data_shop[shop].detailsub[shop_sub].titlesub}',
                                        labelStyle: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: Font_.Fonts_T)),
                                    // inputFormatters: <TextInputFormatter>[
                                    //   // for below version 2 use this
                                    //   FilteringTextInputFormatter
                                    //       .allow(RegExp(r'[0-9]')),
                                    //   // for version 2 and greater youcan also use this
                                    //   FilteringTextInputFormatter
                                    //       .digitsOnly
                                    // ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      )
                    : Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(2.0),
                          child: TextFormField(
                            textAlign: TextAlign.left,
                            keyboardType: TextInputType.number,
                            showCursor: !read_Only,
                            readOnly: read_Only,
                            controller: _controllers_shop[shop],
                            //   initialValue:

                            // '${shop["detail"]}',
                            onFieldSubmitted: (value) async {},

                            decoration: InputDecoration(
                                fillColor: Colors.white.withOpacity(0.3),
                                filled: true,
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.grey,
                                  ),
                                ),
                                // labelText: 'ระบุชื่อร้านค้า',
                                labelStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontFamily: Font_.Fonts_T)),
                            // inputFormatters: <TextInputFormatter>[
                            //   // for below version 2 use this
                            //   FilteringTextInputFormatter
                            //       .allow(RegExp(r'[0-9]')),
                            //   // for version 2 and greater youcan also use this
                            //   FilteringTextInputFormatter
                            //       .digitsOnly
                            // ],
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
    ]));
  }

  Form_Cid(context) {
    return SizedBox(
        child: Column(children: [
      for (var cid in data_cid)
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      '${cid["title"]}*',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: (activeStep != 0)
                        ? null
                        : (cid['ser'].toString() == '3' ||
                                cid['ser'].toString() == '4')
                            ? null
                            : () async {
                                DateTime? newDate = await showDatePicker(
                                  // locale: const Locale('th', 'TH'),
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now()
                                      .add(const Duration(days: -100)),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 400)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: AppBarColors
                                              .ABar_Colors, // header background color
                                          onPrimary:
                                              Colors.white, // header text color
                                          onSurface:
                                              Colors.black, // body text color
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            primary: Colors
                                                .black, // button text color
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                // Dialog_error(context,
                                //     'กรุณาเลือกวันที่สิ้นสุดให้มากกว่า 1 ปี');

                                if (newDate == null) {
                                  return;
                                } else {
                                  final index = data_cid.indexWhere(
                                    (element) => element['ser'] == cid['ser'],
                                  );

                                  if (cid['ser'].toString() == '1') {
                                    // เลือกวันที่เริ่มต้น
                                    setState(() {
                                      data_cid[index]["detail"] =
                                          DateFormat('yyyy-MM-dd')
                                              .format(newDate);
                                    });
                                  } else if (cid['ser'].toString() == '2') {
                                    // เลือกวันที่สิ้นสุด
                                    final startDateStr =
                                        data_cid[index - 1]["detail"];

                                    if (startDateStr != null &&
                                        startDateStr.toString().isNotEmpty) {
                                      final startDate =
                                          DateTime.parse(startDateStr);
                                      final endDate = newDate;

                                      final difference =
                                          endDate.difference(startDate).inDays;
                                      print(difference);
                                      if (difference < 365) {
                                        Dialog_error(context,
                                            'กรุณาเลือกวันที่สิ้นสุดให้มากกว่า 1 ปี');
                                        return;
                                      } else {
                                        setState(() {
                                          data_cid[index]['detail'] =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(newDate);
                                        });
                                      }
                                    } else {
                                      Dialog_error(context,
                                          'กรุณาเลือกวันที่เริ่มต้นก่อน');
                                    }
                                  }
                                }
                              },
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.green,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: AutoSizeText(
                        minFontSize: 12,
                        maxFontSize: 16,
                        maxLines: 1,
                        (cid["ser"].toString() == '3' ||
                                cid["ser"].toString() == '4')
                            ? '${cid["detail"]}'
                            : '${formatDate('${cid["detail"]}', type: DateFormatType.dmy)}',
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text2_,
                            fontFamily: Font_.Fonts_T),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
    ]));
  }

  Doc_Data(context) {
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final date = DateTime.parse(dateStr);
        return '${DateFormat('dd-MM').format(date)}-${date.year}';
      } catch (e) {
        print('❌ Invalid date format: $dateStr');
        return '';
      }
    }

    String getDisplayText(doc, Map<String, dynamic> titleDoc) {
      String displayText = '';

      switch (titleDoc["ser"].toString()) {
        case '1':
          displayText = doc.nameTh ?? '';
          break;

        case '2':
          if (doc.attachments != null && doc.attachments!.isNotEmpty) {
            displayText = formatDate(doc.attachments!.first.uploadedAt);
          }
          break;

        case '3':
          displayText = doc.uuid ?? '';
          break;

        case '4':
          if (doc.attachments != null && doc.attachments!.isNotEmpty) {
            displayText = doc.attachments!.first.status_label ?? '';
          }
          break;

        default:
          if (doc.attachments != null && doc.attachments!.isNotEmpty) {
            displayText = formatDate(doc.attachments!.first.reviewAt);
          }
          break;
      }

      return displayText; // ✅ อย่าลืม return
    }

    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(0)),
                // border: Border.all(color: Colors.grey, width: 1),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              // padding:
              //     const EdgeInsets.symmetric(
              //         vertical: 5,
              //         horizontal: 16),
              child: Column(
                children: [
                  AutoSizeText(
                    minFontSize: 12,
                    maxFontSize: 16,
                    maxLines: 1,
                    'เอกสารแนบ (${attachments.length}เอกสาร) ${isLoading}',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T),
                  ),
                  Container(
                    color: Colors.brown[200],
                    child: Row(children: [
                      for (var title_doc in data_title_doc)
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              '${title_doc["title"]}',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: PeopleChaoScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T),
                            ),
                          ),
                        ),
                    ]),
                  ),
                ],
              ),
            ),
            (isLoading || documentModels.isEmpty)
                ? SizedBox(height: 100, child: Widget_Loading(context))
                : SizedBox(
                    child: Column(children: [
                      for (var doc in documentModels)
                        Row(children: [
                          for (var title_doc in data_title_doc)
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: ('${title_doc["title"]}' == 'ไฟล์เอกสาร')
                                    ? Row(
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                        Color>(
                                                  (doc.attachments != null &&
                                                          doc.attachments!
                                                              .isNotEmpty)
                                                      ? Colors.lime.shade800
                                                      : Colors.black,
                                                ),
                                              ),
                                              onPressed: (doc.attachments !=
                                                          null &&
                                                      doc.attachments!
                                                          .isNotEmpty)
                                                  ? () async {
                                                      final matched =
                                                          findAttachmentByDocId(
                                                              doc.attachments ??
                                                                  [],
                                                              doc.id);
                                                      final file_Uuid =
                                                          matched?.uuid ?? '';
                                                      final file_Path =
                                                          matched?.filePath ??
                                                              '';
                                                      final file_Type =
                                                          matched?.fileType ??
                                                              '';
                                                      final RequestUuid =
                                                          matched?.requestUuid ??
                                                              '';
                                                      // print(
                                                      //     'doc.id : ${doc.id}');
                                                      // print(matched);
                                                      print(
                                                          'file_Uuid : $file_Uuid');
                                                      print(
                                                          'file_Path : $file_Path');
                                                      print(
                                                          'file_Type : $file_Type');
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PreviewPdf_ordit_CMM(
                                                                    id: doc.id,
                                                                    uuid:
                                                                        file_Uuid,
                                                                    Request_Uuid:
                                                                        RequestUuid,
                                                                    code: doc
                                                                        .code,
                                                                    file_path:
                                                                        file_Path,
                                                                    file_type:
                                                                        file_Type,
                                                                    title:
                                                                        '${doc.nameTh}'),
                                                          ));
                                                      // final matched =
                                                      //     findAttachmentByDocId(
                                                      //         attachments,
                                                      //         doc.id);
                                                      // final filePath = matched
                                                      //         ?.filePath
                                                      //         ?.toString() ??
                                                      //     '';

                                                      // if (filePath.isEmpty) {
                                                      //   final response =
                                                      //       await pickAndUpload(
                                                      //           uuid_Request
                                                      //               .toString(),
                                                      //           doc.id);

                                                      //   if (response.body !=
                                                      //       null) {
                                                      //     print(
                                                      //         '✅ อัปโหลดสำเร็จ');
                                                      //     print(response.body);
                                                      //     Dialog_success(
                                                      //         context,
                                                      //         'อัปโหลดสำเร็จ');
                                                      //   } else {
                                                      //     print(
                                                      //         '⚠️ ไม่มีไฟล์ถูกอัปโหลด ${response.body}');
                                                      //     Dialog_error(context,
                                                      //         'ไม่มีไฟล์ถูกอัปโหลด');
                                                      //   }
                                                      // } else {
                                                      //   final matched =
                                                      //       findAttachmentByDocId(
                                                      //           doc.attachments ??
                                                      //               [],
                                                      //           doc.id);
                                                      //   final file_Uuid =
                                                      //       matched?.uuid ?? '';
                                                      //   final file_Path =
                                                      //       matched?.filePath ??
                                                      //           '';
                                                      //   final file_Type =
                                                      //       matched?.fileType ??
                                                      //           '';
                                                      //   Navigator.push(
                                                      //       context,
                                                      //       MaterialPageRoute(
                                                      //         builder: (context) => PreviewPdf_ordit_CMM(
                                                      //             id: doc.id,
                                                      //             uuid:
                                                      //                 file_Uuid,
                                                      //             code:
                                                      //                 doc.code,
                                                      //             file_path:
                                                      //                 file_Path,
                                                      //             file_type:
                                                      //                 file_Type,
                                                      //             title:
                                                      //                 '${doc.nameTh}'),
                                                      //       ));
                                                      // }
                                                    }
                                                  : null,
                                              child: Translate
                                                  .TranslateAndSet_TextAutoSize(
                                                      'เรียกดู',
                                                      (doc.active != 1)
                                                          ? CustomerScreen_Color
                                                              .Colors_Text2_
                                                          : CustomerScreen_Color
                                                              .Colors_Text3_,
                                                      TextAlign.center,
                                                      null,
                                                      Font_.Fonts_T,
                                                      10,
                                                      14,
                                                      1),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(
                                        padding: const EdgeInsets.all(0.0),
                                        child: AutoSizeText(
                                          getDisplayText(doc, title_doc),
                                          minFontSize: 12,
                                          maxFontSize: 16,
                                          maxLines: 1,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: CustomerScreen_Color
                                                .Colors_Text2_,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: InkWell(
                                onTap: () async {
                                  // final response = await pickAndUpload(
                                  //     uuid_Request.toString(), doc.id);

                                  // if (response.body != null) {
                                  //   print('✅ อัปโหลดสำเร็จ');
                                  //   print(response.body);
                                  //   Dialog_success(context, 'อัปโหลดสำเร็จ');
                                  // } else {
                                  //   print(
                                  //       '⚠️ ไม่มีไฟล์ถูกอัปโหลด ${response.body}');
                                  //   Dialog_error(
                                  //       context, 'ไม่มีไฟล์ถูกอัปโหลด');
                                  // }

                                  final matched = findAttachmentByDocId(
                                      attachments, doc.id);
                                  int filePath = matched?.id ?? 0;

                                  final response = await pickAndUpload(
                                      uuid_Request.toString(), doc.id);

                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    final Map<String, dynamic> result =
                                        json.decode(response.body);
                                    final data = result['data'];
                                    final updatedAttachment =
                                        AttachmentsModel.fromJson(data);

                                    setState(() {
                                      final index = documentModels.indexWhere(
                                        (element) =>
                                            element.id ==
                                            data['client_document_id'],
                                      );

                                      if (index != -1) {
                                        final old = documentModels[
                                            index]; // ลบของเก่า (โดยการ assign ใหม่)
                                        documentModels[index].attachments = [];

// เพิ่มใหม่
                                        documentModels[index]
                                            .attachments!
                                            .add(updatedAttachment);
                                      }
                                      print(
                                          '📌 attachments ใหม่: ${documentModels[index].attachments!.first.filePath}');
                                    });
                                    Dialog_success(context, 'อัปโหลดสำเร็จ');
                                  } else {
                                    print(
                                        '❌ การอัปโหลดล้มเหลว: ${response.statusCode}');
                                    Dialog_error(
                                        context, 'ไม่มีไฟล์ถูกอัปโหลด');
                                  }
                                },
                                child: Icon(
                                  Icons.upload_file,
                                  color: Colors.blue,
                                ),
                              )
                              //  (doc.attachments != null &&
                              //         doc.attachments!.isNotEmpty)
                              //     ? Icon(
                              //         Icons.delete_outline,
                              //         color: Colors.red,
                              //       )
                              //     : Icon(
                              //         Icons.upload_file,
                              //         color: Colors.blue,
                              //       ),
                              )
                        ])
                    ]),
                  ),
          ],
        ),
      ),
      // SizedBox(
      //   height: 40,
      // ),
      // SizedBox(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       Container(
      //         decoration: BoxDecoration(
      //           color: AppbackgroundColor.TiTile_Colors.withOpacity(0.8),
      //           borderRadius: BorderRadius.only(
      //               topLeft: Radius.circular(10),
      //               topRight: Radius.circular(15),
      //               bottomLeft: Radius.circular(0),
      //               bottomRight: Radius.circular(0)),
      //           // border: Border.all(color: Colors.grey, width: 1),
      //         ),
      //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      //         // padding:
      //         //     const EdgeInsets.symmetric(
      //         //         vertical: 5,
      //         //         horizontal: 16),
      //         child: Column(
      //           children: [
      //             AutoSizeText(
      //               minFontSize: 12,
      //               maxFontSize: 16,
      //               maxLines: 1,
      //               'รายการชำระ( ${attachments.length})',
      //               textAlign: TextAlign.center,
      //               overflow: TextOverflow.ellipsis,
      //               style: TextStyle(
      //                   color: PeopleChaoScreen_Color.Colors_Text2_,
      //                   fontFamily: Font_.Fonts_T),
      //             ),
      //             Container(
      //               color: Colors.brown[200],
      //               child: Row(children: [
      //                 for (var title_receipt in data_title_receipt)
      //                   Expanded(
      //                     flex: '${title_receipt["title"]}' == 'สถานะ' ? 2 : 1,
      //                     child: Container(
      //                       padding: const EdgeInsets.all(2.0),
      //                       child: AutoSizeText(
      //                         minFontSize: 12,
      //                         maxFontSize: 16,
      //                         maxLines: 1,
      //                         '${title_receipt["title"]}',
      //                         textAlign: TextAlign.left,
      //                         overflow: TextOverflow.ellipsis,
      //                         style: TextStyle(
      //                             color: PeopleChaoScreen_Color.Colors_Text2_,
      //                             fontFamily: Font_.Fonts_T),
      //                       ),
      //                     ),
      //                   ),
      //               ]),
      //             ),
      //           ],
      //         ),
      //       ),
      //       (isLoading || attachments.isEmpty)
      //           ? Widget_Loading(context)
      //           : SizedBox(
      //               child: Column(children: [
      //                 for (var receipt in attachments)
      //                   Row(children: [
      //                     for (var title_receipt in data_title_receipt)
      //                       Expanded(
      //                         flex: '${title_receipt["title"]}' == 'สถานะ'
      //                             ? 2
      //                             : 1,
      //                         child: Container(
      //                           padding: const EdgeInsets.all(2.0),
      //                           child: AutoSizeText(
      //                             minFontSize: 12,
      //                             maxFontSize: 16,
      //                             maxLines: 1,
      //                             //  '-',
      //                             ('${title_receipt["ser"]}' == '1')
      //                                 ? '${receipt.id}'
      //                                 : ('${title_receipt["ser"]}' == '2')
      //                                     ? (receipt.createdAt == null)
      //                                         ? ''
      //                                         : DateFormat('dd-MM')
      //                                                 .format(DateTime.parse(
      //                                                     receipt.createdAt))
      //                                                 .toString() +
      //                                             '-${DateTime.parse(receipt.createdAt).year}'
      //                                     : ('${title_receipt["ser"]}' == '3')
      //                                         ? '${receipt.uuid}'
      //                                         : '${receipt.active}',
      //                             textAlign: TextAlign.left,
      //                             overflow: TextOverflow.ellipsis,
      //                             style: TextStyle(
      //                                 color:
      //                                     PeopleChaoScreen_Color.Colors_Text2_,
      //                                 fontFamily: Font_.Fonts_T),
      //                           ),
      //                         ),
      //                       ),
      //                   ]),
      //               ]),
      //             ),
      //       Padding(
      //         padding: const EdgeInsets.all(0.0),
      //         child: Row(
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Icon(
      //                 Icons.info,
      //                 size: 18,
      //               ),
      //             ),
      //             Expanded(
      //               child: AutoSizeText(
      //                 minFontSize: 12,
      //                 maxFontSize: 16,
      //                 maxLines: 1,
      //                 'โปรดเรียกดูเอกสารแนบเพื่อตรวจสอบความถูกต้องของเอกสารหลักฐานก่อนดำเนินการยืนยันเอกสารถูกต้อง',
      //                 textAlign: TextAlign.left,
      //                 overflow: TextOverflow.ellipsis,
      //                 style: TextStyle(
      //                     color: PeopleChaoScreen_Color.Colors_Text2_,
      //                     fontFamily: Font_.Fonts_T),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(
                minFontSize: 12,
                maxFontSize: 16,
                maxLines: 1,
                'หมายเหตุ',
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: TextFormField(
                readOnly: false,
                keyboardType: TextInputType.number,
                // controller: Formbecause_,
                initialValue: '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ใส่ข้อมูลให้ครบถ้วน ';
                  }
                  // if (int.parse(value.toString()) < 13) {
                  //   return '< 13';
                  // }
                  return null;
                },
                onChanged: (value) {
                  // setState(() {
                  //   Formbecause_.text =
                  //       value.toString();
                  // });
                },
                maxLines: 3,
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
                    // labelText: 'คำอธิบาย',
                    labelStyle: const TextStyle(
                      color: ManageScreen_Color.Colors_Text2_,
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
          ],
        ),
      ),
    ]));
  }

  Header_Stepper(context) {
    return SizedBox(
      child: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Center(
            child: Text(headerText(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 25,
                  color: PeopleChaoScreen_Color.Colors_Text1_,
                  // fontWeight: FontWeight.bold,
                  fontFamily: FontWeight_.Fonts_T,
                  fontWeight: FontWeight.bold,
                )),
          ),
          const SizedBox(
            height: 10,
          ),
          IconStepper(
            enableNextPreviousButtons: false,
            enableStepTapping: false,
            icons: const [
              Icon(Icons.filter_1),
              Icon(Icons.filter_2),
              Icon(Icons.filter_3),
              Icon(Icons.filter_4),
              // Icon(Icons.filter_5),
            ],

            // activeStep property set to activeStep variable defined above.
            activeStep: activeStep,

            // This ensures step-tapping updates the activeStep.
            onStepReached: (index) {
              setState(() {
                activeStep = index;
              });
            },
          ),
          if (activeStep == 0)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        'โซน ${widget.Get_Value_area_ln}: ',
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                      Container(
                        width: 200,
                        height: 35,
                        decoration: const BoxDecoration(
                          // color: Colors.green,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          // border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          showCursor: !read_Only, //add this line
                          readOnly: read_Only,
                          controller: Form_zone_name,
                          cursorColor: Colors.green,
                          decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.3),
                              filled: true,
                              // prefixIcon:
                              //     const Icon(Icons.person, color: Colors.black),
                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  topLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  topLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              labelStyle: const TextStyle(
                                  color: Colors.black54,

                                  // fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T
                                  //fontSize: 10.0
                                  )),
                        ),
                      ),
                      const AutoSizeText(
                        minFontSize: 10,
                        maxFontSize: 15,
                        'รหัสพื้นที่ ',
                        style: TextStyle(
                            color: PeopleChaoScreen_Color.Colors_Text1_,
                            fontWeight: FontWeight.bold,
                            fontFamily: FontWeight_.Fonts_T),
                      ),
                      Container(
                        width: 200,
                        height: 35,
                        decoration: const BoxDecoration(
                          // color: Colors.green,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                          // border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.all(2.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          showCursor: !read_Only, //add this line
                          readOnly: read_Only,
                          controller: Form_ln_name,
                          cursorColor: Colors.green,
                          decoration: InputDecoration(
                              fillColor: Colors.white.withOpacity(0.3),
                              filled: true,
                              // prefixIcon:
                              //     const Icon(Icons.person, color: Colors.black),
                              // suffixIcon: Icon(Icons.clear, color: Colors.black),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  topLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(6),
                                  topLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                  bottomLeft: Radius.circular(6),
                                ),
                                borderSide: BorderSide(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              labelStyle: const TextStyle(
                                  color: Colors.black54,

                                  // fontWeight: FontWeight.bold,
                                  fontFamily: Font_.Fonts_T
                                  //fontSize: 10.0
                                  )),
                        ),
                      ),
                      // InkWell(
                      //   child: Container(
                      //     width: 100,
                      //     decoration: BoxDecoration(
                      //       color: AppbackgroundColor.TiTile_Colors,
                      //       borderRadius: const BorderRadius.only(
                      //           topLeft: Radius.circular(10),
                      //           topRight: Radius.circular(10),
                      //           bottomLeft: Radius.circular(10),
                      //           bottomRight: Radius.circular(10)),
                      //       border: Border.all(color: Colors.black, width: 1),
                      //     ),
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: AutoSizeText(
                      //       minFontSize: 10,
                      //       maxFontSize: 15,
                      //       maxLines: 3,
                      //       _selecteSer.length == 0
                      //           ? 'เลือก'
                      //           : '${_selecteSerbool.map((e) => e).toString().substring(1, _selecteSerbool.map((e) => e).toString().length - 1)}',
                      //       style: const TextStyle(
                      //           color: PeopleChaoScreen_Color.Colors_Text1_,
                      //           fontWeight: FontWeight.bold,
                      //           fontFamily: FontWeight_.Fonts_T),
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     showDialog<String>(
                      //       barrierDismissible: false,
                      //       context: context,
                      //       builder: (BuildContext context) => AlertDialog(
                      //         shape: const RoundedRectangleBorder(
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(20.0))),
                      //         title: const Center(
                      //             child: Text(
                      //           'เลือกพื้นที่',
                      //           style: TextStyle(
                      //               color: PeopleChaoScreen_Color.Colors_Text1_,
                      //               fontWeight: FontWeight.bold,
                      //               fontFamily: FontWeight_.Fonts_T),
                      //         )),
                      //         content: SingleChildScrollView(
                      //           child: ListBody(
                      //             children: <Widget>[
                      //               StreamBuilder(
                      //                   stream: Stream.periodic(
                      //                       const Duration(seconds: 0)),
                      //                   builder: (context, snapshot) {
                      //                     return CheckboxGroup(
                      //                         checked: _selecteSerbool,
                      //                         activeColor: Colors.red,
                      //                         checkColor: Colors.white,
                      //                         labels: <String>[
                      //                           for (var i = 0;
                      //                               i < areaModels.length;
                      //                               i++)
                      //                             '${areaModels[i].lncode}',
                      //                         ],
                      //                         labelStyle: const TextStyle(
                      //                           color: PeopleChaoScreen_Color
                      //                               .Colors_Text2_,
                      //                           // fontWeight: FontWeight.bold,
                      //                           fontFamily: Font_.Fonts_T,
                      //                         ),
                      //                         onChange:
                      //                             (isChecked, label, index) {
                      //                           if (isChecked == false) {
                      //                             _selecteSer.remove(
                      //                                 areaModels[index].ser);

                      //                             double areax = double.parse(
                      //                                 areaModels[index].area!);
                      //                             double rentx = double.parse(
                      //                                 areaModels[index].rent!);
                      //                             _area_sum = _area_sum - areax;
                      //                             _area_rent_sum =
                      //                                 _area_rent_sum - rentx;

                      //                             if (isChecked == true) {
                      //                               setState(() {
                      //                                 _area_sum =
                      //                                     _area_sum + areax;
                      //                                 _area_rent_sum =
                      //                                     _area_rent_sum +
                      //                                         rentx;
                      //                                 _selecteSer.add(
                      //                                     areaModels[index]
                      //                                         .ser);
                      //                               });
                      //                             }
                      //                           } else {
                      //                             double areax = double.parse(
                      //                                 areaModels[index].area!);
                      //                             double rentx = double.parse(
                      //                                 areaModels[index].rent!);
                      //                             if (isChecked == true) {
                      //                               setState(() {
                      //                                 _area_sum =
                      //                                     _area_sum + areax;
                      //                                 _area_rent_sum =
                      //                                     _area_rent_sum +
                      //                                         rentx;
                      //                                 _selecteSer.add(
                      //                                     areaModels[index]
                      //                                         .ser);
                      //                               });
                      //                             }
                      //                           }
                      //                           print(
                      //                               'เลือกพื้นที่ :  ${_selecteSer.map((e) => e)}  : _area_sum = $_area_sum _area_rent_sum = $_area_rent_sum ');
                      //                         },
                      //                         onSelected:
                      //                             (List<String> selected) {
                      //                           setState(() {
                      //                             _selecteSerbool = selected;
                      //                           });
                      //                           print(
                      //                               'SerGetBankModels_ : ${_selecteSerbool}');
                      //                         });
                      //                   })
                      //             ],
                      //           ),
                      //         ),
                      //         actions: <Widget>[
                      //           Padding(
                      //             padding: const EdgeInsets.all(8.0),
                      //             child: Row(
                      //               mainAxisAlignment: MainAxisAlignment.end,
                      //               children: [
                      //                 Padding(
                      //                   padding: const EdgeInsets.all(8.0),
                      //                   child: Row(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.center,
                      //                     children: [
                      //                       Container(
                      //                         width: 100,
                      //                         decoration: const BoxDecoration(
                      //                           color: Colors.green,
                      //                           borderRadius: BorderRadius.only(
                      //                               topLeft:
                      //                                   Radius.circular(10),
                      //                               topRight:
                      //                                   Radius.circular(10),
                      //                               bottomLeft:
                      //                                   Radius.circular(10),
                      //                               bottomRight:
                      //                                   Radius.circular(10)),
                      //                         ),
                      //                         padding:
                      //                             const EdgeInsets.all(8.0),
                      //                         child: TextButton(
                      //                           onPressed: () {
                      //                             setState(() {
                      //                               // read_GC_areaSelectSer();
                      //                             });
                      //                             Navigator.pop(context, 'OK');
                      //                           },
                      //                           child: const Text(
                      //                             'บันทึก',
                      //                             style: TextStyle(
                      //                               color: Colors.white,
                      //                               fontWeight: FontWeight.bold,
                      //                               fontFamily:
                      //                                   FontWeight_.Fonts_T,
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ),
                      //                 Container(
                      //                   width: 100,
                      //                   decoration: const BoxDecoration(
                      //                     color: Colors.black,
                      //                     borderRadius: BorderRadius.only(
                      //                         topLeft: Radius.circular(10),
                      //                         topRight: Radius.circular(10),
                      //                         bottomLeft: Radius.circular(10),
                      //                         bottomRight: Radius.circular(10)),
                      //                   ),
                      //                   padding: const EdgeInsets.all(8.0),
                      //                   child: TextButton(
                      //                     onPressed: () {
                      //                       Navigator.pop(context);
                      //                       setState(() {
                      //                         cQuotModels.clear();
                      //                         _selecteSer.clear();
                      //                         _selecteSerbool.clear();
                      //                       });
                      //                     },
                      //                     child: const Text(
                      //                       'ยกเลิก',
                      //                       style: TextStyle(
                      //                         color: Colors.white,
                      //                         fontWeight: FontWeight.bold,
                      //                         fontFamily: FontWeight_.Fonts_T,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     );
                      //   },
                      // ),
                      // if (Responsive.isDesktop(context))
                      //   Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: InkWell(
                      //       onTap: () {
                      //         Set_data('d87fec79-6020-449f-8b8b-724e4d6a0d4c',
                      //             OutputType.client);
                      //         // Dia_log1(context);
                      //         // Timer(Duration(milliseconds: 300), () {
                      //         //   Dialog_Customer(context);
                      //         // });
                      //         // Dia_log3(context);
                      //         // select_customer().then((value) {
                      //         //   Navigator.of(context).pop();
                      //         //   Timer(Duration(milliseconds: 150), () {
                      //         //     Dialog_Customer(context);
                      //         //   });
                      //         // });
                      //       },
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           color: Colors.grey,
                      //           borderRadius: const BorderRadius.only(
                      //             topLeft: Radius.circular(10),
                      //             topRight: Radius.circular(10),
                      //             bottomLeft: Radius.circular(10),
                      //             bottomRight: Radius.circular(10),
                      //           ),
                      //           border:
                      //               Border.all(color: Colors.black, width: 1),
                      //         ),
                      //         padding: const EdgeInsets.all(8.0),
                      //         child: const Text(
                      //           'ค้นจากใบเสนอราคา',
                      //           maxLines: 5,
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //             // PeopleChaoScreen_Color
                      //             //     .Colors_Text1_
                      //             // fontWeight: FontWeight.bold,
                      //             fontFamily: FontWeight_.Fonts_T,
                      //             fontWeight: FontWeight.bold,
                      //             //fontSize: 10.0
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            Dia_log1(context);
                            Timer(Duration(milliseconds: 300), () {
                              Dialog_Customer(context);
                            });
                            // Dia_log3(context);
                            // select_customer().then((value) {
                            //   Navigator.of(context).pop();
                            //   Timer(Duration(milliseconds: 150), () {
                            //     Dialog_Customer(context);
                            //   });
                            // });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              'ค้นจากทะเบียน',
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                // PeopleChaoScreen_Color
                                //     .Colors_Text1_
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                                fontWeight: FontWeight.bold,
                                //fontSize: 10.0
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            // red_card().then((value) {
                            //   if (read_card != null) {
                            //     ScaffoldMessenger.of(context)
                            //         .showSnackBar(
                            //       SnackBar(
                            //           content: Text('$read_card',
                            //               style: TextStyle(
                            //                   color: Colors.white,
                            //                   fontFamily:
                            //                       Font_.Fonts_T))),
                            //     );
                            //   }
                            // });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              'ค้นจากบัตรประชาชน',
                              maxLines: 5,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: PeopleChaoScreen_Color.Colors_Text1_,
                                // fontWeight: FontWeight.bold,
                                fontFamily: FontWeight_.Fonts_T,
                                fontWeight: FontWeight.bold,
                                //fontSize: 10.0
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
          // ช่องค้นหา
          Container(
              width: MediaQuery.of(context).size.width,
              // height: 50,
              decoration: BoxDecoration(
                color: AppbackgroundColor.TiTile_Box,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(color: Colors.white, width: 2),
              ),
              // padding: const EdgeInsets.all(5.0),
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Translate.TranslateAndSetText(
                        (activeStep == 0)
                            ? 'ข้อมูลผู้เช่า '
                            : (activeStep == 1)
                                ? 'ข้อมูลสำหรับทำสัญญา'
                                : (activeStep == 2)
                                    ? 'รายละเอียดค่าบริการ'
                                    : 'ชำระค่าบริการ',
                        ChaoAreaScreen_Color.Colors_Text1_,
                        TextAlign.left,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        2),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Translate.TranslateAndSetText(
                        (activeStep == 0)
                            ? 'ข้อมูลร้านค้า '
                            : (activeStep == 1)
                                ? 'รายละเอียดเอกสารสำหรับทำสัญญา'
                                : (activeStep == 2)
                                    ? ''
                                    : '',
                        // (activeStep == 0)
                        //     ? 'ข้อมูลร้านค้า '
                        //     : (activeStep == 0)
                        //         ? 'รายละเอียดเอกสารสำหรับทำสัญญา'
                        //         : 'ชำระค่าบริการ ',
                        ChaoAreaScreen_Color.Colors_Text1_,
                        TextAlign.left,
                        FontWeight.bold,
                        FontWeight_.Fonts_T,
                        14,
                        2),
                  ),
                ),
              ])),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Stepper_2(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height + 300,
            child: Column(children: [
              Header_Stepper(context),
              SizedBox(
                child: ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    }),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            // height: MediaQuery.of(context).size.height * 0.8,
                            decoration: const BoxDecoration(
                              color: AppbackgroundColor.Sub_Abg_Colors,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              // border: Border.all(color: Colors.grey, width: 1),
                            ),
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: Form(
                                        key: _formKey_person,
                                        child: Column(children: [
                                          Form_Person(context),
                                          SizedBox(
                                            height: 20,
                                          ), // for (var shop in data_shop)
                                          Form_Shop(context),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
                                              child:
                                                  Translate.TranslateAndSetText(
                                                      'ลายมือชื่อ*',
                                                      ChaoAreaScreen_Color
                                                          .Colors_Text1_,
                                                      TextAlign.left,
                                                      null,
                                                      // FontWeight.bold,
                                                      Font_.Fonts_T,
                                                      14,
                                                      2),
                                            ),
                                          ),
                                          ReusableSignaturePad(
                                            height: 120,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            signatureKey: signatureKey1,
                                            onUp: () async {
                                              final matched =
                                                  finddocumentByDocCode(
                                                      documentModels,
                                                      'users_signature');
                                              int filePath = matched?.id ?? 0;

                                              final response = await handleSave(
                                                  uuid_Request.toString(),
                                                  filePath,
                                                  signatureKey1,
                                                  SignatureActionType
                                                      .upload_user);

                                              if (response.statusCode == 200 ||
                                                  response.statusCode == 201) {
                                                final Map<String, dynamic>
                                                    result =
                                                    json.decode(response.body);
                                                final data = result['data'];
                                                final updatedAttachment =
                                                    AttachmentsModel.fromJson(
                                                        data);

                                                setState(() {
                                                  final index =
                                                      documentModels.indexWhere(
                                                    (element) =>
                                                        element.id ==
                                                        data[
                                                            'client_document_id'],
                                                  );

                                                  if (index != -1) {
                                                    final old = documentModels[
                                                        index]; // ลบของเก่า (โดยการ assign ใหม่)
                                                    documentModels[index]
                                                        .attachments = [];

// เพิ่มใหม่
                                                    documentModels[index]
                                                        .attachments!
                                                        .add(updatedAttachment);
                                                  }
                                                  print(
                                                      '📌 attachments ใหม่: ${documentModels[index].attachments!.first.filePath}');
                                                  Dialog_success(
                                                      context, 'อัปโหลดสำเร็จ');
                                                });
                                              } else {
                                                print(
                                                    '❌ การอัปโหลดล้มเหลว: ${response.statusCode}');
                                                Dialog_error(context,
                                                    'ไม่มีไฟล์ถูกอัปโหลด');
                                              }
                                            },
                                            onSave: () async {
                                              handleSave(
                                                  uuid_Request.toString(),
                                                  0,
                                                  signatureKey1,
                                                  SignatureActionType
                                                      .saveToFile);
                                            },
                                            onClear: () => signatureKey1
                                                .currentState
                                                ?.clear(),
                                          ),
                                          SizedBox(
                                            height: 60,
                                          ),
                                          // Form_Cid(context),
                                        ]),
                                      ),
                                    )),
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(children: [
                                      Form_Cid(context),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      Doc_Data(context),
                                      SizedBox(
                                        height: 50,
                                      ),
                                      ActiveStep_Stepper(context)
                                    ]),
                                  ),
                                ),
                              ],
                            )))),
              )
            ]),
          ),
        ));
  }

  ScrollController _scrollController_Stepper_3 = ScrollController();
  _moveUp_Stepper3() {
    // ตารางสรุปค่าบริการ
    _scrollController_Stepper_3.animateTo(
        _scrollController_Stepper_3.offset - 220,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 500));
  }

  _moveDown_Stepper3() {
    // ตารางสรุปค่าบริการ
    _scrollController_Stepper_3.animateTo(
        _scrollController_Stepper_3.offset + 220,
        curve: Curves.linear,
        duration: const Duration(milliseconds: 500));
  }

  Stepper_3(context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            // height: MediaQuery.of(context).size.height + 300,
            child: Column(children: [
              Header_Stepper(context),
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
                            Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                    child: Container(
                                        width: (!Responsive.isDesktop(context))
                                            ? 1200
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.825,
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'งวด',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    //fontSize: 10.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'วันที่',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    //fontSize: 10.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'รายการ',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    //fontSize: 10.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'ยอด/งวด',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    //fontSize: 10.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  'ยอด',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color:
                                                        PeopleChaoScreen_Color
                                                            .Colors_Text1_,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        FontWeight_.Fonts_T,
                                                    //fontSize: 10.0
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 250,
                                          width:
                                              (!Responsive.isDesktop(context))
                                                  ? 1200
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.825,
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
                                          child: ListView.builder(
                                            controller:
                                                _scrollController_Stepper_3,
                                            // itemExtent: 50,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(), //NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: expAutoModels.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Material(
                                                color: AppbackgroundColor
                                                    .Sub_Abg_Colors,
                                                child: Container(
                                                    // color: Strp3_tappedIndex6 ==
                                                    //         index.toString()
                                                    //     ? tappedIndex_Color
                                                    //         .tappedIndex_Colors
                                                    //         .withOpacity(0.5)
                                                    //     : null,
                                                    child: ListTile(
                                                        onTap: () {
                                                          // setState(() {
                                                          //   Strp3_tappedIndex6 =
                                                          //       index
                                                          //           .toString();
                                                          // });
                                                        },
                                                        title: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              flex: 1,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        AutoSizeText(
                                                                      maxLines:
                                                                          2,
                                                                      minFontSize:
                                                                          8,
                                                                      // maxFontSize: 15,
                                                                      '${expAutoModels[index].unit}/${expAutoModels[index].sday}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        // fontWeight:
                                                                        //     FontWeight
                                                                        //         .bold,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,

                                                                        //fontSize: 10.0
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  maxLines: 2,
                                                                  minFontSize:
                                                                      8,
                                                                  '',
                                                                  // maxFontSize: 15,
                                                                  // '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${quotxSelectModels[index].ldate!} 00:00:00'))}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,

                                                                    //fontSize: 10.0
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 1,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    AutoSizeText(
                                                                  maxLines: 2,
                                                                  minFontSize:
                                                                      8,
                                                                  // maxFontSize: 15,
                                                                  '${expAutoModels[index].expname} ',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,

                                                                    //fontSize: 10.0
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 1,
                                                                child:
                                                                    AutoSizeText(
                                                                  maxLines: 2,
                                                                  minFontSize:
                                                                      8,
                                                                  // maxFontSize: 15,
                                                                  '${expAutoModels[index].pri_auto} / งวด',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .right,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: PeopleChaoScreen_Color
                                                                        .Colors_Text2_,
                                                                    // fontWeight: FontWeight.bold,
                                                                    fontFamily:
                                                                        Font_
                                                                            .Fonts_T,

                                                                    //fontSize: 10.0
                                                                  ),
                                                                )),
                                                            Expanded(
                                                              flex: 1,
                                                              child:
                                                                  AutoSizeText(
                                                                maxLines: 2,
                                                                minFontSize: 8,
                                                                // maxFontSize: 15,

                                                                '${nFormat.format(int.parse(expAutoModels[index].sday!) * double.parse(expAutoModels[index].pri_auto!))}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                                style:
                                                                    const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T,

                                                                  //fontSize: 10.0
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ))),
                                              );
                                            },
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
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Container(
                          width: (!Responsive.isDesktop(context))
                              ? MediaQuery.of(context).size.width
                              : MediaQuery.of(context).size.width * 0.83,
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
                                          _scrollController_Stepper_3.animateTo(
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
                                                  color: Colors.grey, width: 1),
                                            ),
                                            padding: const EdgeInsets.all(3.0),
                                            child: const Text(
                                              'Top',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 10.0,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            )),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (_scrollController_Stepper_3
                                            .hasClients) {
                                          final position =
                                              _scrollController_Stepper_3
                                                  .position.maxScrollExtent;
                                          _scrollController_Stepper_3.animateTo(
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
                                            'Down',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10.0,
                                              fontFamily: FontWeight_.Fonts_T,
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
                                      onTap: _moveUp_Stepper3,
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
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                              bottomRight: Radius.circular(6)),
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                        ),
                                        padding: const EdgeInsets.all(3.0),
                                        child: const Text(
                                          'Scroll',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10.0,
                                            fontFamily: FontWeight_.Fonts_T,
                                          ),
                                        )),
                                    InkWell(
                                      onTap: _moveDown_Stepper3,
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ActiveStep_Stepper(context)
            ]),
          ),
        ));
  }

//////////////////////-------->
  Widget Stepper_4(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

// // ปรับขนาดตามจอ
//     final double baseMinWidth =
//         screenWidth > 1800 ? 1800.0 : screenWidth * 0.98;
    final double maxAllowedWidth = screenWidth * 0.85;
    // final double safeMinWidth =
    //     baseMinWidth.clamp(300.0, maxAllowedWidth); // ป้องกันจอเล็กเกินไป

    double maxH = screenHeight * 0.75;
    double minH = 700;
    if (minH > maxH) minH = maxH;
    // print('Stepper_4');
    // // print(widget.Get_Value_payment_uuid);
    // print("Stepper_4 widget.payment_jsonx");
    // print(widget.paymentjsonx);
    // print("Stepper_4 widget.payment_jsonx");
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Text('$maxAllowedWidth'),
            Header_Stepper(context),

            // ใส่ ScrollConfiguration สำหรับแนวนอน
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (maxAllowedWidth < 1300) ? 1400 : maxAllowedWidth,

                    maxHeight: (maxH < 560) ? 620 : maxH,

                    // minWidth: safeMinWidth,
                    // maxWidth: maxAllowedWidth,
                    // minHeight: minH,
                    // maxHeight: maxH,
                  ),
                  child: BillPaymentScreen(
                      uuid_Request: uuid_Request,
                      response_Post_payment: data_response_Post_GC_payment,
                      payment_uuid: widget.Get_Value_payment_uuid,
                      payment_amount: widget.Get_Value_payment_amount,
                      payment_jsonx: widget.paymentjsonx.isNotEmpty
                          ? widget.paymentjsonx
                          : jsonx),

                  // widget.paymentjsonx
                ),
              ),
            ),
            // SizedBox(
            //   height: 30,
            // ),
            // ActiveStep_Stepper(context),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  Dialog_Customer(context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
          // stream: Stream.periodic(const Duration(seconds: 0)),
          builder: (context, snapshot) {
        return AlertDialog(
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(10.0),
          actionsPadding: const EdgeInsets.all(6.0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'เลือกรายชื่อจากทะเบียน',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
          content: SingleChildScrollView(
              child: ListBody(children: <Widget>[
            (!Responsive.isDesktop(context))
                ? Container(
                    width: (Responsive.isDesktop(context))
                        ? MediaQuery.of(context).size.width * 0.85
                        : 1000,
                    decoration: BoxDecoration(
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      // border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                          ),
                          padding: const EdgeInsets.all(0.0),
                          child: Column(
                            children: [
                              // Container(
                              //   // padding: EdgeInsets.all(10),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: Container(
                              //             height: 40,
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey.shade600,
                              //               borderRadius: const BorderRadius
                              //                       .only(
                              //                   topLeft: Radius.circular(15),
                              //                   topRight: Radius.circular(15),
                              //                   bottomLeft: Radius.circular(0),
                              //                   bottomRight:
                              //                       Radius.circular(0)),
                              //             ),
                              //             padding: const EdgeInsets.all(4.0),
                              //             child: _searchBar()),
                              //       ),
                              //     ],
                              //   ),
                              // ),
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
                                        width: 800,
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade600,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(0),
                                                        topRight:
                                                            Radius.circular(0),
                                                        bottomLeft:
                                                            Radius.circular(0),
                                                        bottomRight:
                                                            Radius.circular(0)),
                                              ),
                                              child: Row(
                                                children: const [
                                                  Expanded(
                                                    flex: 2,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      '...',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      'Img',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily:
                                                            FontWeight_.Fonts_T,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      'รหัสสมาชิก',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      'Tax',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      'ชื่อร้าน',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      'ชื่อผู่เช่า/บริษัท',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      'ประเภท',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: AutoSizeText(
                                                      minFontSize: 10,
                                                      maxFontSize: 18,
                                                      'Select',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              FontWeight_
                                                                  .Fonts_T),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                                width: (Responsive.isDesktop(
                                                        context))
                                                    ? MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.85
                                                    : 1000,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                child: StreamBuilder(
                                                    stream: Stream.periodic(
                                                        const Duration(
                                                            seconds: 0)),
                                                    builder:
                                                        (context, snapshot) {
                                                      return ListView.builder(
                                                          physics:
                                                              const AlwaysScrollableScrollPhysics(),
                                                          shrinkWrap: true,
                                                          itemCount:
                                                              customerModels
                                                                  .length,
                                                          itemBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return Container(
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
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(0),
                                                              child: ListTile(
                                                                onTap: () {
                                                                  // แปลง CustomerModel ให้เป็น JSON string เพื่อแสดง
                                                                  String
                                                                      jsonString =
                                                                      jsonEncode(
                                                                          customerModels[index]
                                                                              .toJson());
                                                                  CustomerModel
                                                                      model =
                                                                      customerModels[
                                                                          index]; // ดึง object ออกมาก่อน
                                                                  // print(jsonString);

                                                                  List<String>
                                                                      data_person_add =
                                                                      [
                                                                    model.scname ??
                                                                        "",
                                                                    model.tax ??
                                                                        "",
                                                                    "",
                                                                    "",
                                                                    model.address!
                                                                            .number ??
                                                                        "",
                                                                    model.address!
                                                                            .moo ??
                                                                        "",
                                                                    model.address!
                                                                            .soi ??
                                                                        "",
                                                                    model.address!
                                                                            .road ??
                                                                        "",
                                                                    model.address!
                                                                            .tambon ??
                                                                        "",
                                                                    model.address!
                                                                            .amphoe ??
                                                                        "",
                                                                    model.address!
                                                                            .province ??
                                                                        "",
                                                                    model.tel ??
                                                                        "",
                                                                    model.addr1 ??
                                                                        ""
                                                                  ];
                                                                  List<String>
                                                                      data_shop_add =
                                                                      [
                                                                    "",
                                                                    "${widget.Get_Value_area_sum!}",
                                                                    model.stype ??
                                                                        "",
                                                                    model.sname ??
                                                                        "",
                                                                  ];
                                                                  List<String>
                                                                      data_shopsub_add =
                                                                      [
                                                                    '-',
                                                                    '${Form_zone_name.text}',
                                                                    '${widget.Get_Value_area_ln!}'
                                                                  ];
                                                                  // อัปเดตข้อมูลทั้งหมด
                                                                  _updateCustomerData(
                                                                      data_person_add,
                                                                      data_shop_add,
                                                                      data_shopsub_add,
                                                                      '');
                                                                  Dia_log1(
                                                                      context);
                                                                  Timer(
                                                                      Duration(
                                                                          milliseconds:
                                                                              300),
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  });
                                                                  // setState(() {
                                                                  //   Form_nameshop
                                                                  //           .text =
                                                                  //       '${customerModels[index].scname}';
                                                                  //   Form_typeshop
                                                                  //           .text =
                                                                  //       '${customerModels[index].stype}';
                                                                  //   Form_bussshop
                                                                  //           .text =
                                                                  //       '${customerModels[index].cname}';
                                                                  //   Form_bussscontact
                                                                  //           .text =
                                                                  //       '${customerModels[index].attn}';
                                                                  //   Form_address
                                                                  //           .text =
                                                                  //       '${customerModels[index].addr1}';
                                                                  //   Form_tel.text =
                                                                  //       '${customerModels[index].tel}';
                                                                  //   Form_email
                                                                  //           .text =
                                                                  //       '${customerModels[index].email}';
                                                                  //   Form_tax
                                                                  //       .text = customerModels[index].tax ==
                                                                  //           'null'
                                                                  //       ? "-"
                                                                  //       : '${customerModels[index].tax}';

                                                                  //   Value_AreaSer_ =
                                                                  //       int.parse(customerModels[index].typeser!) -
                                                                  //           1; // ser ประเภท
                                                                  //   _verticalGroupValue =
                                                                  //       '${customerModels[index].type}'; // ประเภท

                                                                  //   _Form_nameshop =
                                                                  //       '${customerModels[index].scname}';
                                                                  //   _Form_typeshop =
                                                                  //       '${customerModels[index].stype}';
                                                                  //   _Form_bussshop =
                                                                  //       '${customerModels[index].cname}';
                                                                  //   _Form_bussscontact =
                                                                  //       '${customerModels[index].attn}';
                                                                  //   _Form_address =
                                                                  //       '${customerModels[index].addr1}';
                                                                  //   _Form_tel =
                                                                  //       '${customerModels[index].tel}';
                                                                  //   _Form_email =
                                                                  //       '${customerModels[index].email}';
                                                                  //   _Form_tax = customerModels[index].tax ==
                                                                  //           'null'
                                                                  //       ? "-"
                                                                  //       : '${customerModels[index].tax}';

                                                                  //   number_custno = customerModels[
                                                                  //           index]
                                                                  //       .custno
                                                                  //       .toString();
                                                                  // });

                                                                  // Navigator.pop(
                                                                  //     context);
                                                                },
                                                                title: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            18,
                                                                        '${index + 1}',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              PeopleChaoScreen_Color.Colors_Text2_,
                                                                          // fontWeight: FontWeight.bold,
                                                                          fontFamily:
                                                                              Font_.Fonts_T,
                                                                          // fontWeight: FontWeight.bold,
                                                                          // fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: (customerModels[index].addr2 == null ||
                                                                              customerModels[index].addr2 == '')
                                                                          ? Container(
                                                                              // padding:
                                                                              //     const EdgeInsets
                                                                              //             .all(
                                                                              //         2.0),
                                                                              // decoration: BoxDecoration(
                                                                              //     color: Colors
                                                                              //             .grey[
                                                                              //         200],
                                                                              //     borderRadius:
                                                                              //         BorderRadius.all(
                                                                              //             Radius.circular(100))),
                                                                              child: const Center(
                                                                                child: Icon(Icons.image_not_supported_rounded),
                                                                              ),
                                                                            )
                                                                          : InkWell(
                                                                              child: Container(
                                                                                  // color: Colors
                                                                                  //     .black,
                                                                                  child: Image(width: 30, height: 30, image: NetworkImage('${MyConstant().domain}/files/$foder/contract/${customerModels[index].addr2}'))
                                                                                  // CircleAvatar(
                                                                                  //   radius: 30.0,
                                                                                  //   backgroundImage: NetworkImage('${MyConstant().domain}/files/$foder/contract/${customerModels[index].addr2}', scale: 10),
                                                                                  //   backgroundColor: Colors.transparent,
                                                                                  // ),
                                                                                  ),
                                                                              onTap: () {
                                                                                // setState(() {
                                                                                //   tappedIndex_ = index.toString();
                                                                                // });
                                                                                showDialog<String>(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) => AlertDialog(
                                                                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                                                                                    // title: Container(
                                                                                    //     width: MediaQuery.of(context).size.width * 0.25,
                                                                                    //     height: MediaQuery.of(context).size.width * 0.35,
                                                                                    //     child: Image.network(
                                                                                    //       '${MyConstant().domain}/files/$foder/contract/${customer_Models[index].addr2}',
                                                                                    //       fit: BoxFit.contain,
                                                                                    //     )),
                                                                                    content: Container(
                                                                                      // width: MediaQuery.of(context).size.width * 0.25,
                                                                                      // height: MediaQuery.of(context).size.width * 0.32,
                                                                                      child: SingleChildScrollView(
                                                                                        child: ListBody(
                                                                                          children: <Widget>[
                                                                                            Container(
                                                                                              width: MediaQuery.of(context).size.width * 0.25,
                                                                                              height: MediaQuery.of(context).size.width * 0.32,
                                                                                              child: Image.network(
                                                                                                '${MyConstant().domain}/files/$foder/contract/${customerModels[index].addr2}',
                                                                                                fit: BoxFit.contain,
                                                                                              ),
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
                                                                                                    color: Colors.redAccent,
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
                                                                                              ],
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
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            18,
                                                                        customerModels[index].tax ==
                                                                                null
                                                                            ? ''
                                                                            : '${customerModels[index].tax}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            18,
                                                                        customerModels[index].custno ==
                                                                                null
                                                                            ? ''
                                                                            : '${customerModels[index].custno}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            18,
                                                                        '${customerModels[index].scname}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,

                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            18,
                                                                        '${customerModels[index].cname}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child:
                                                                          AutoSizeText(
                                                                        minFontSize:
                                                                            10,
                                                                        maxFontSize:
                                                                            18,
                                                                        '${customerModels[index].type}',
                                                                        textAlign:
                                                                            TextAlign.start,
                                                                        style: const TextStyle(
                                                                            color: PeopleChaoScreen_Color.Colors_Text2_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily: Font_.Fonts_T),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 1,
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.grey[500],
                                                                          borderRadius: BorderRadius.only(
                                                                              topLeft: Radius.circular(10),
                                                                              topRight: Radius.circular(10),
                                                                              bottomLeft: Radius.circular(10),
                                                                              bottomRight: Radius.circular(10)),
                                                                        ),
                                                                        padding:
                                                                            const EdgeInsets.all(4.0),
                                                                        child:
                                                                            AutoSizeText(
                                                                          minFontSize:
                                                                              10,
                                                                          maxFontSize:
                                                                              18,
                                                                          'Select',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            // fontWeight: FontWeight.bold,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                            // fontWeight: FontWeight.bold,
                                                                            // fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    })),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ),
                  )
                : Container(
                    width: (Responsive.isDesktop(context))
                        ? MediaQuery.of(context).size.width * 0.85
                        : 1000,
                    decoration: BoxDecoration(
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      // border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Container(
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15)),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              // Container(
                              //   // padding: EdgeInsets.all(10),
                              //   child: Row(
                              //     children: [
                              //       Expanded(
                              //         child: Container(
                              //             height: 40,
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey.shade600,
                              //               borderRadius: const BorderRadius
                              //                       .only(
                              //                   topLeft: Radius.circular(15),
                              //                   topRight: Radius.circular(15),
                              //                   bottomLeft: Radius.circular(0),
                              //                   bottomRight:
                              //                       Radius.circular(0)),
                              //             ),
                              //             padding: const EdgeInsets.all(4.0),
                              //             child: _searchBar()),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade600,
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(0),
                                      topRight: Radius.circular(0),
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(0)),
                                ),
                                child: Row(
                                  children: const [
                                    Expanded(
                                      flex: 2,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 18,
                                        '...',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 18,
                                        'Img',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FontWeight_.Fonts_T,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 18,
                                        'รหัสสมาชิก',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 18,
                                        'ชื่อร้าน',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 18,
                                        'ชื่อผู่เช่า/บริษัท',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 18,
                                        'ประเภท',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: AutoSizeText(
                                        minFontSize: 10,
                                        maxFontSize: 18,
                                        'Select',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: FontWeight_.Fonts_T),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                  width: (Responsive.isDesktop(context))
                                      ? MediaQuery.of(context).size.width * 0.85
                                      : 1000,
                                  height:
                                      MediaQuery.of(context).size.height * 0.8,
                                  child: StreamBuilder(
                                      stream: Stream.periodic(
                                          const Duration(seconds: 0)),
                                      builder: (context, snapshot) {
                                        return ListView.builder(
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: customerModels.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return Container(
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
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: ListTile(
                                                  onTap: () {
                                                    // แปลง CustomerModel ให้เป็น JSON string เพื่อแสดง
                                                    String jsonString =
                                                        jsonEncode(
                                                            customerModels[
                                                                    index]
                                                                .toJson());
                                                    CustomerModel model =
                                                        customerModels[
                                                            index]; // ดึง object ออกมาก่อน
                                                    print(
                                                        model.address!.amphoe);
                                                    setState(() {
                                                      uuid_Request =
                                                          model.uuid.toString();
                                                    });
                                                    List<String>
                                                        data_person_add = [
                                                      model.scname ?? "",
                                                      model.tax ?? "",
                                                      "",
                                                      "",
                                                      model.address!.number ??
                                                          "",
                                                      model.address!.moo ?? "",
                                                      model.address!.soi ?? "",
                                                      model.address!.road ?? "",
                                                      model.address!.tambon ??
                                                          "",
                                                      model.address!.amphoe ??
                                                          "",
                                                      model.address!.province ??
                                                          "",
                                                      model.tel ?? "",
                                                      model.addr1 ?? ""
                                                    ];
                                                    List<String> data_shop_add =
                                                        [
                                                      "",
                                                      "${widget.Get_Value_area_sum!}",
                                                      model.stype ?? "",
                                                      model.sname ?? "",
                                                    ];
                                                    List<String>
                                                        data_shopsub_add = [
                                                      '-',
                                                      '${Form_zone_name.text}',
                                                      '${widget.Get_Value_area_ln!}'
                                                    ];
                                                    // อัปเดตข้อมูลทั้งหมด
                                                    _updateCustomerData(
                                                        data_person_add,
                                                        data_shop_add,
                                                        data_shopsub_add,
                                                        '');
                                                    Dia_log1(context);
                                                    Timer(
                                                        Duration(
                                                            milliseconds: 300),
                                                        () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    });
                                                    // setState(() {
                                                    //   Form_nameshop.text =
                                                    //       '${customerModels[index].scname}';
                                                    //   Form_typeshop.text =
                                                    //       '${customerModels[index].stype}';
                                                    //   Form_bussshop.text =
                                                    //       '${customerModels[index].cname}';
                                                    //   Form_bussscontact.text =
                                                    //       '${customerModels[index].attn}';
                                                    //   Form_address.text =
                                                    //       '${customerModels[index].addr1}';
                                                    //   Form_tel.text =
                                                    //       '${customerModels[index].tel}';
                                                    //   Form_email.text =
                                                    //       '${customerModels[index].email}';
                                                    //   Form_tax
                                                    //       .text = customerModels[
                                                    //                   index]
                                                    //               .tax ==
                                                    //           'null'
                                                    //       ? "-"
                                                    //       : '${customerModels[index].tax}';

                                                    //   Value_AreaSer_ = int.parse(
                                                    //           customerModels[
                                                    //                   index]
                                                    //               .typeser!) -
                                                    //       1; // ser ประเภท
                                                    //   _verticalGroupValue =
                                                    //       '${customerModels[index].type}'; // ประเภท

                                                    //   _Form_nameshop =
                                                    //       '${customerModels[index].scname}';
                                                    //   _Form_typeshop =
                                                    //       '${customerModels[index].stype}';
                                                    //   _Form_bussshop =
                                                    //       '${customerModels[index].cname}';
                                                    //   _Form_bussscontact =
                                                    //       '${customerModels[index].attn}';
                                                    //   _Form_address =
                                                    //       '${customerModels[index].addr1}';
                                                    //   _Form_tel =
                                                    //       '${customerModels[index].tel}';
                                                    //   _Form_email =
                                                    //       '${customerModels[index].email}';
                                                    //   _Form_tax = customerModels[
                                                    //                   index]
                                                    //               .tax ==
                                                    //           'null'
                                                    //       ? "-"
                                                    //       : '${customerModels[index].tax}';

                                                    //   number_custno =
                                                    //       customerModels[index]
                                                    //           .custno
                                                    //           .toString();
                                                    // });

                                                    // Navigator.pop(context);
                                                  },
                                                  title: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 18,
                                                          '${index + 1}',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style:
                                                              const TextStyle(
                                                            color: PeopleChaoScreen_Color
                                                                .Colors_Text2_,
                                                            // fontWeight: FontWeight.bold,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            // fontWeight: FontWeight.bold,
                                                            // fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: (customerModels[
                                                                            index]
                                                                        .addr2 ==
                                                                    null ||
                                                                customerModels[
                                                                            index]
                                                                        .addr2 ==
                                                                    '')
                                                            ? Container(
                                                                // padding:
                                                                //     const EdgeInsets
                                                                //             .all(
                                                                //         2.0),
                                                                // decoration: BoxDecoration(
                                                                //     color: Colors
                                                                //             .grey[
                                                                //         200],
                                                                //     borderRadius:
                                                                //         BorderRadius.all(
                                                                //             Radius.circular(100))),
                                                                child:
                                                                    const Center(
                                                                  child: Icon(Icons
                                                                      .image_not_supported_rounded),
                                                                ),
                                                              )
                                                            : InkWell(
                                                                child:
                                                                    Container(
                                                                  // color: Colors
                                                                  //     .black,
                                                                  child:
                                                                      CircleAvatar(
                                                                    radius:
                                                                        30.0,
                                                                    backgroundImage:
                                                                        NetworkImage(
                                                                      '${MyConstant().domain}/files/$foder/contract/${customerModels[index].addr2}',
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  // setState(() {
                                                                  //   tappedIndex_ = index.toString();
                                                                  // });
                                                                  showDialog<
                                                                      String>(
                                                                    context:
                                                                        context,
                                                                    builder: (BuildContext
                                                                            context) =>
                                                                        AlertDialog(
                                                                      shape: const RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(20.0))),
                                                                      // title: Container(
                                                                      //     width: MediaQuery.of(context).size.width * 0.25,
                                                                      //     height: MediaQuery.of(context).size.width * 0.35,
                                                                      //     child: Image.network(
                                                                      //       '${MyConstant().domain}/files/$foder/contract/${customer_Models[index].addr2}',
                                                                      //       fit: BoxFit.contain,
                                                                      //     )),
                                                                      content:
                                                                          Container(
                                                                        // width: MediaQuery.of(context).size.width * 0.25,
                                                                        // height: MediaQuery.of(context).size.width * 0.32,
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              ListBody(
                                                                            children: <Widget>[
                                                                              Container(
                                                                                width: MediaQuery.of(context).size.width * 0.25,
                                                                                height: MediaQuery.of(context).size.width * 0.32,
                                                                                child: Image.network(
                                                                                  '${MyConstant().domain}/files/$foder/contract/${customerModels[index].addr2}',
                                                                                  fit: BoxFit.contain,
                                                                                ),
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
                                                                                      color: Colors.redAccent,
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
                                                                                ],
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
                                                      Expanded(
                                                        flex: 2,
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 18,
                                                          customerModels[index]
                                                                      .custno ==
                                                                  null
                                                              ? ''
                                                              : '${customerModels[index].custno}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 18,
                                                          '${customerModels[index].scname}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 18,
                                                          '${customerModels[index].cname}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 3,
                                                        child: AutoSizeText(
                                                          minFontSize: 10,
                                                          maxFontSize: 18,
                                                          '${customerModels[index].type}',
                                                          textAlign:
                                                              TextAlign.start,
                                                          style:
                                                              const TextStyle(
                                                                  color: PeopleChaoScreen_Color
                                                                      .Colors_Text2_,
                                                                  // fontWeight: FontWeight.bold,
                                                                  fontFamily: Font_
                                                                      .Fonts_T),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey[500],
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
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: AutoSizeText(
                                                            minFontSize: 10,
                                                            maxFontSize: 18,
                                                            'Select',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                              // fontWeight: FontWeight.bold,
                                                              fontFamily:
                                                                  Font_.Fonts_T,
                                                              // fontWeight: FontWeight.bold,
                                                              // fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      })),
                            ],
                          )),
                    ),
                  ),
          ])),
          actions: <Widget>[
            Column(
              children: [
                const Divider(),
              ],
            ),
          ],
        );
      }),
    );
  }
}
