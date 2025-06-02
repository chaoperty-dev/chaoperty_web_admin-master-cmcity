import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../AdminScaffold/AdminScaffold.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Model/Document_Model.dart';
import 'Model/Person&Shop_Model.dart';
import 'Model/ReviewUuid_Model.dart';
import 'Model/Review_Model.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import 'cignaturepad_cmm.dart';
import 'unity/API_admin_requests.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/Enum.dart';
import 'unity/FormatDate.dart';
import 'unity/SecurePrefs_helper.dart';
import 'unity/show_dialog_cmm.dart';

class RequestExaminer1_CMM extends StatefulWidget {
  const RequestExaminer1_CMM({super.key});

  @override
  State<RequestExaminer1_CMM> createState() => _RequestExaminer1_CMMState();
}

class _RequestExaminer1_CMMState extends State<RequestExaminer1_CMM> {
  int ser_tap = 1;
  List<TextEditingController> _controllers_person = [];
  List<TextEditingController> _controllers_shop = [];
  List<TextEditingController> _controllers_shop_sub = [];
  ////////////--------------------->
  List<PersonFieldModel> data_person = data_persons;
  List<ShopFieldModel> data_shop = data_shops;
  List<AttachmentsModel> attachments = [];
  List data_cid = [];
  List data_title_doc = [];
  List data_title_receipt = [];
  ////////////--------------------->
  @override
  void initState() {
    super.initState();
    loadClientReviewsUuid();
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
  }

  List<ReviewDetail> reviewDetail = [];

  Future<void> loadClientReviewsUuid() async {
    String? value = await SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest);
    print('🔓 UUID Request: $value');
    print('loadClientReviewsUuid');

    final response = await read_GC_ReviewsUuid(value);

    if (response != null && response.statusCode == 200) {
      final result = json.decode(response.body);
      final reviewDetailModel = ReviewDetail.fromJson(result['data']);
      // final attachmentx =
      //     AttachmentsModel.fromJson(result['data']['attachments']);

      print(reviewDetailModel);

      setState(() {
        reviewDetail.add(reviewDetailModel);
        // attachments.add(attachmentx);
      });
    } else {
      print('error');
    }

    Set_data();
  }

  Future<void> Set_data() async {
    print('🔄 เริ่มโหลดข้อมูล: uuid = xx, type = type');

    try {
      AddForm_requests_uuid(0);
    } catch (e, stack) {
      // print('❌ เกิดข้อผิดพลาดขณะโหลดข้อมูล [type: $type]');
      print('🧾 ข้อความ: $e');
      print('📍 StackTrace:\n$stack');
      setState(() {
        // isLoading = false;
      });
    }
  }

  void AddForm_requests_uuid(index) {
    final details = reviewDetail[index];
    // print(jsonString);
    //  final model = ClientModel.fromJson(jsonData);
    // print(model.json?['province']); // → เชียงใหม่
    List<String> data_person_add = [
      details.client.scname ?? "",
      details.client.tax ?? "",
      "-",
      "-",
      details.client.json.number ?? "",
      details.client.json.moo ?? "",
      details.client.json.soi ?? "",
      details.client.json.road ?? "",
      details.client.json.tambon ?? "",
      details.client.json.amphoe ?? "",
      details.client.json.province ?? "",
      details.client.tel ?? "",
      details.client.addr1 ?? ""
    ];

    List<String> data_shop_add = [
      "-",
      details.newRequest.qty.toString() ?? "",
      details.client.stype ?? "",
      details.client.sname ?? ""
    ];
    List<String> data_shopsub_add = [
      '-',
      details.newRequest.zn ?? "",
      details.newRequest.ln ?? "",
    ];
    List<String> data_details_add = [
      details.newRequest.sdate!,
      details.newRequest.ldate!,
      details.newRequest.type!,
      '1',
    ];
    // อัปเดตข้อมูลทั้งหมด
    _updateCustomerData(
        data_person_add, data_shop_add, data_shopsub_add, data_details_add);
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

  ////////////--------------------->
  // List data_person = [
  //   {"ser": "1", "title": "ชื่อ-นามสกุล", "detail": "นายเชียงใหม่ สุเทพ"},
  //   {"ser": "2", "title": "เลขบัตรประจำตัวประชาชน", "detail": "0123456789101"},
  //   {"ser": "3", "title": "อายุ", "detail": "ไทย"},
  //   {"ser": "4", "title": "บ้านเลขที่", "detail": "123/4 ม.5"},
  //   {"ser": "5", "title": "หมู่ที่", "detail": "สุเทพ"},
  //   {"ser": "6", "title": "ตรอก/ซอย", "detail": "-"},
  //   {"ser": "7", "title": "ถนน", "detail": "-"},
  //   {"ser": "8", "title": "ตำบล/แขวง", "detail": "สุเทพ"},
  //   {"ser": "9", "title": "อำเภอ/เขต", "detail": "เมือง"},
  //   {"ser": "10", "title": "จังหวัด", "detail": "เชียงใหม่"},
  // ];
  // List<Map<String, dynamic>> data_shop = [
  //   {
  //     "ser": "1",
  //     "title": "พื้นที่เช่า (ตร.ม.)",
  //     "detail": "",
  //     "detailsub": [
  //       {"ser": "1", "titlesub": "บริเวณ", "detail": "A"},
  //       {"ser": "2", "titlesub": "โซน", "detail": "B"},
  //       {"ser": "3", "titlesub": "ล็อกที่", "detail": "1"},
  //     ]
  //   },
  //   {
  //     "ser": "2",
  //     "title": "ขนาดพื้นที่เช่า (ตร.ม.)",
  //     "detail": "20",
  //     "detailsub": []
  //   },
  //   {"ser": "3", "title": "ประเภทสินค้า", "detail": "อาหาร", "detailsub": []},
  //   {"ser": "4", "title": "ชื่อร้าน", "detail": "ไทย", "detailsub": []},
  // ];
  // List data_cid = [
  //   {"ser": "1", "title": "วันที่เริ่มต้น", "detail": "01-06-2568"},
  //   {"ser": "2", "title": "วันที่สิ้นสุด", "detail": "01-06-2569"},
  // ];
  // List data_title_doc = [
  //   {
  //     "ser": "1",
  //     "title": "ชื่อเอกสาร ",
  //     "data": "title",
  //   },
  //   {
  //     "ser": "2",
  //     "title": "วันที่ทำรายการ",
  //     "data": "datex",
  //   },
  //   {
  //     "ser": "3",
  //     "title": "ไฟล์เอกสาร",
  //     "data": "file",
  //   },
  //   {
  //     "ser": "4",
  //     "title": "สถานะ",
  //     "data": "status",
  //   },
  //   {
  //     "ser": "5",
  //     "title": "วันที่ตรวจสอบ",
  //     "data": "verify",
  //   },
  // ];
  // List data_doc = [
  //   {
  //     "ser": "1",
  //     "title": "รูปถ่าย ",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "เอกสารถูกต้อง",
  //     "verify": "-",
  //   },
  //   {
  //     "ser": "2",
  //     "title": "รูปถ่ายคู่กับร้านค้าและสิ้นค้า",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "รอตรวจสอบ",
  //     "verify": "-",
  //   },
  //   {
  //     "ser": "3",
  //     "title": "ใบรับรองแพทย์",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "เอกสารถูกต้อง",
  //     "verify": "-",
  //   },
  //   {
  //     "ser": "4",
  //     "title": "ใบอนุญาติจำหน่ายสินค้า",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "รอแก้ไข",
  //     "verify": "-",
  //   },
  //   {
  //     "ser": "5",
  //     "title": "บัตรประจำตัวผู้ค้า",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "รอแก้ไข",
  //     "verify": "-",
  //   },
  //   {
  //     "ser": "6",
  //     "title": "ใบรับรองการผ่านการอบรม",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "รอตรวจสอบ",
  //     "verify": "-",
  //   },
  //   {
  //     "ser": "7",
  //     "title": "เอกสารแนบอื่นๆ",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "รอตรวจสอบ",
  //     "verify": "-",
  //   },
  //   {
  //     "ser": "8",
  //     "title": "หลักฐานการชำระ",
  //     "datex": "21-04-2025",
  //     "file": "xxxx.png",
  //     "status": "ไม่ผ่านเกณฑ์",
  //     "verify": "-",
  //   },
  // ];
  // List data_title_receipt = [
  //   {
  //     "ser": "1",
  //     "title": "เลขที่ใบเสร็จ ",
  //     "data": "title",
  //   },
  //   {
  //     "ser": "2",
  //     "title": "วันที่รับชำระ",
  //     "data": "datex",
  //   },
  //   {
  //     "ser": "3",
  //     "title": "สถานะ",
  //     "data": "status",
  //   },
  //   {
  //     "ser": "4",
  //     "title": "วันที่ตรวจสอบ",
  //     "data": "verify",
  //   },
  // ];
  // List data_receipt = [
  //   {
  //     "ser": "1",
  //     "title": "R68-04-000001",
  //     "datex": "21-04-2025",
  //     "status": "รอตรวจสอบ",
  //     "verify": "-",
  //   },
  // ];
  @override
  Widget build(BuildContext context) {
    return (ser_tap == 2)
        ? SignaturePad_CMM()
        : Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height + 300,
                child: Column(children: [
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
                                'คำขอต่อสัญญา ',
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
                                'รายละเอียดเอกสารสำหรับต่อสัญญา ',
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
                                          child: Column(children: [
                                            Form_Person(context),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Form_Shop(context),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Form_Cid(context),
                                            SizedBox(
                                              height: 30,
                                            ),
                                            // for (int index = 0;
                                            //     index < data_person.length;
                                            //     index++)
                                            //   // for (var person in data_person)
                                            //   Padding(
                                            //     padding:
                                            //         const EdgeInsets.all(2.0),
                                            //     child: SizedBox(
                                            //       height: 40,
                                            //       child: Row(
                                            //         children: [
                                            //           Expanded(
                                            //             flex: 1,
                                            //             child: Container(
                                            //               padding:
                                            //                   const EdgeInsets
                                            //                       .all(2.0),
                                            //               child: AutoSizeText(
                                            //                 minFontSize: 12,
                                            //                 maxFontSize: 16,
                                            //                 maxLines: 1,
                                            //                 '${data_person[index].title}',
                                            //                 // '${person["title"]}*',
                                            //                 textAlign:
                                            //                     TextAlign.left,
                                            //                 overflow:
                                            //                     TextOverflow
                                            //                         .ellipsis,
                                            //                 style: TextStyle(
                                            //                     color: PeopleChaoScreen_Color
                                            //                         .Colors_Text2_,
                                            //                     fontFamily: Font_
                                            //                         .Fonts_T),
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           Expanded(
                                            //             flex: 2,
                                            //             child: Container(
                                            //               padding:
                                            //                   const EdgeInsets
                                            //                       .all(2.0),
                                            //               child: TextFormField(
                                            //                 textAlign:
                                            //                     TextAlign.left,
                                            //                 keyboardType:
                                            //                     TextInputType
                                            //                         .number,
                                            //                 showCursor: false,
                                            //                 readOnly: true,
                                            //                 controller:
                                            //                     _controllers_person[
                                            //                         index],
                                            //                 // initialValue:
                                            //                 //     '${person["detail"]}',
                                            //                 onFieldSubmitted:
                                            //                     (value) async {},

                                            //                 decoration:
                                            //                     InputDecoration(
                                            //                         fillColor: Colors
                                            //                             .white
                                            //                             .withOpacity(
                                            //                                 0.3),
                                            //                         filled:
                                            //                             true,
                                            //                         focusedBorder:
                                            //                             const OutlineInputBorder(
                                            //                           borderRadius:
                                            //                               BorderRadius.all(
                                            //                                   Radius.circular(6)),
                                            //                           borderSide:
                                            //                               BorderSide(
                                            //                             width:
                                            //                                 1,
                                            //                             color: Colors
                                            //                                 .black,
                                            //                           ),
                                            //                         ),
                                            //                         enabledBorder:
                                            //                             const OutlineInputBorder(
                                            //                           borderRadius:
                                            //                               BorderRadius.all(
                                            //                                   Radius.circular(6)),
                                            //                           borderSide:
                                            //                               BorderSide(
                                            //                             width:
                                            //                                 1,
                                            //                             color: Colors
                                            //                                 .grey,
                                            //                           ),
                                            //                         ),
                                            //                         // labelText: 'ระบุชื่อร้านค้า',
                                            //                         labelStyle: const TextStyle(
                                            //                             fontSize:
                                            //                                 14,
                                            //                             color: Colors
                                            //                                 .black54,
                                            //                             fontFamily:
                                            //                                 Font_.Fonts_T)),
                                            //                 // inputFormatters: <TextInputFormatter>[
                                            //                 //   // for below version 2 use this
                                            //                 //   FilteringTextInputFormatter
                                            //                 //       .allow(RegExp(r'[0-9]')),
                                            //                 //   // for version 2 and greater youcan also use this
                                            //                 //   FilteringTextInputFormatter
                                            //                 //       .digitsOnly
                                            //                 // ],
                                            //               ),
                                            //             ),
                                            //           )
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ),
                                            // SizedBox(
                                            //   height: 20,
                                            // ),
                                            // for (var shop in data_shop)
                                            //   Padding(
                                            //     padding:
                                            //         const EdgeInsets.all(2.0),
                                            //     child: SizedBox(
                                            //       height: 40,
                                            //       child: Row(
                                            //         children: [
                                            //           Expanded(
                                            //             flex: 1,
                                            //             child: Container(
                                            //               padding:
                                            //                   const EdgeInsets
                                            //                       .all(2.0),
                                            //               child: AutoSizeText(
                                            //                 minFontSize: 12,
                                            //                 maxFontSize: 16,
                                            //                 maxLines: 1,
                                            //                 '${shop["title"]}*',
                                            //                 textAlign:
                                            //                     TextAlign.left,
                                            //                 overflow:
                                            //                     TextOverflow
                                            //                         .ellipsis,
                                            //                 style: TextStyle(
                                            //                     color: PeopleChaoScreen_Color
                                            //                         .Colors_Text2_,
                                            //                     fontFamily: Font_
                                            //                         .Fonts_T),
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           (shop["ser"].toString() ==
                                            //                   '1')
                                            //               ? Expanded(
                                            //                   flex: 2,
                                            //                   child: Row(
                                            //                     children: [
                                            //                       for (var shop
                                            //                           in shop[
                                            //                               "detailsub"])
                                            //                         Expanded(
                                            //                           flex: 1,
                                            //                           child:
                                            //                               Container(
                                            //                             padding:
                                            //                                 const EdgeInsets.all(2.0),
                                            //                             child:
                                            //                                 TextFormField(
                                            //                               textAlign:
                                            //                                   TextAlign.left,
                                            //                               keyboardType:
                                            //                                   TextInputType.number,
                                            //                               showCursor:
                                            //                                   false,
                                            //                               readOnly:
                                            //                                   true,
                                            //                               initialValue:
                                            //                                   '${shop["detail"]}',
                                            //                               onFieldSubmitted:
                                            //                                   (value) async {},

                                            //                               decoration: InputDecoration(
                                            //                                   fillColor: Colors.white.withOpacity(0.3),
                                            //                                   filled: true,
                                            //                                   focusedBorder: const OutlineInputBorder(
                                            //                                     borderRadius: BorderRadius.all(Radius.circular(6)),
                                            //                                     borderSide: BorderSide(
                                            //                                       width: 1,
                                            //                                       color: Colors.black,
                                            //                                     ),
                                            //                                   ),
                                            //                                   enabledBorder: const OutlineInputBorder(
                                            //                                     borderRadius: BorderRadius.all(Radius.circular(6)),
                                            //                                     borderSide: BorderSide(
                                            //                                       width: 1,
                                            //                                       color: Colors.grey,
                                            //                                     ),
                                            //                                   ),
                                            //                                   labelText: '${shop["titlesub"]}',
                                            //                                   labelStyle: const TextStyle(fontSize: 16, color: Colors.black, fontFamily: Font_.Fonts_T)),
                                            //                               // inputFormatters: <TextInputFormatter>[
                                            //                               //   // for below version 2 use this
                                            //                               //   FilteringTextInputFormatter
                                            //                               //       .allow(RegExp(r'[0-9]')),
                                            //                               //   // for version 2 and greater youcan also use this
                                            //                               //   FilteringTextInputFormatter
                                            //                               //       .digitsOnly
                                            //                               // ],
                                            //                             ),
                                            //                           ),
                                            //                         )
                                            //                     ],
                                            //                   ),
                                            //                 )
                                            //               : Expanded(
                                            //                   flex: 2,
                                            //                   child: Container(
                                            //                     padding:
                                            //                         const EdgeInsets
                                            //                                 .all(
                                            //                             2.0),
                                            //                     child:
                                            //                         TextFormField(
                                            //                       textAlign:
                                            //                           TextAlign
                                            //                               .left,
                                            //                       keyboardType:
                                            //                           TextInputType
                                            //                               .number,
                                            //                       showCursor:
                                            //                           false,
                                            //                       readOnly:
                                            //                           true,
                                            //                       initialValue:
                                            //                           '${shop["detail"]}',
                                            //                       onFieldSubmitted:
                                            //                           (value) async {},

                                            //                       decoration:
                                            //                           InputDecoration(
                                            //                               fillColor: Colors.white.withOpacity(
                                            //                                   0.3),
                                            //                               filled:
                                            //                                   true,
                                            //                               focusedBorder:
                                            //                                   const OutlineInputBorder(
                                            //                                 borderRadius:
                                            //                                     BorderRadius.all(Radius.circular(6)),
                                            //                                 borderSide:
                                            //                                     BorderSide(
                                            //                                   width: 1,
                                            //                                   color: Colors.black,
                                            //                                 ),
                                            //                               ),
                                            //                               enabledBorder:
                                            //                                   const OutlineInputBorder(
                                            //                                 borderRadius:
                                            //                                     BorderRadius.all(Radius.circular(6)),
                                            //                                 borderSide:
                                            //                                     BorderSide(
                                            //                                   width: 1,
                                            //                                   color: Colors.grey,
                                            //                                 ),
                                            //                               ),
                                            //                               // labelText: 'ระบุชื่อร้านค้า',
                                            //                               labelStyle: const TextStyle(
                                            //                                   fontSize: 14,
                                            //                                   color: Colors.black54,
                                            //                                   fontFamily: Font_.Fonts_T)),
                                            //                       // inputFormatters: <TextInputFormatter>[
                                            //                       //   // for below version 2 use this
                                            //                       //   FilteringTextInputFormatter
                                            //                       //       .allow(RegExp(r'[0-9]')),
                                            //                       //   // for version 2 and greater youcan also use this
                                            //                       //   FilteringTextInputFormatter
                                            //                       //       .digitsOnly
                                            //                       // ],
                                            //                     ),
                                            //                   ),
                                            //                 )
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ),
                                            // SizedBox(
                                            //   height: 20,
                                            // ),
                                            // for (var cid in data_cid)
                                            //   Padding(
                                            //     padding:
                                            //         const EdgeInsets.all(2.0),
                                            //     child: SizedBox(
                                            //       height: 40,
                                            //       child: Row(
                                            //         children: [
                                            //           Expanded(
                                            //             flex: 1,
                                            //             child: Container(
                                            //               padding:
                                            //                   const EdgeInsets
                                            //                       .all(2.0),
                                            //               child: AutoSizeText(
                                            //                 minFontSize: 12,
                                            //                 maxFontSize: 16,
                                            //                 maxLines: 1,
                                            //                 '${cid["title"]}*',
                                            //                 textAlign:
                                            //                     TextAlign.left,
                                            //                 overflow:
                                            //                     TextOverflow
                                            //                         .ellipsis,
                                            //                 style: TextStyle(
                                            //                     color: PeopleChaoScreen_Color
                                            //                         .Colors_Text2_,
                                            //                     fontFamily: Font_
                                            //                         .Fonts_T),
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           Expanded(
                                            //             flex: 2,
                                            //             child: Container(
                                            //               padding:
                                            //                   const EdgeInsets
                                            //                       .all(2.0),
                                            //               child: TextFormField(
                                            //                 textAlign:
                                            //                     TextAlign.left,
                                            //                 keyboardType:
                                            //                     TextInputType
                                            //                         .number,
                                            //                 showCursor: false,
                                            //                 readOnly: true,
                                            //                 initialValue:
                                            //                     '${cid["detail"]}',
                                            //                 onFieldSubmitted:
                                            //                     (value) async {},

                                            //                 decoration:
                                            //                     InputDecoration(
                                            //                         fillColor: Colors
                                            //                             .white
                                            //                             .withOpacity(
                                            //                                 0.3),
                                            //                         filled:
                                            //                             true,
                                            //                         focusedBorder:
                                            //                             const OutlineInputBorder(
                                            //                           borderRadius:
                                            //                               BorderRadius.all(
                                            //                                   Radius.circular(6)),
                                            //                           borderSide:
                                            //                               BorderSide(
                                            //                             width:
                                            //                                 1,
                                            //                             color: Colors
                                            //                                 .black,
                                            //                           ),
                                            //                         ),
                                            //                         enabledBorder:
                                            //                             const OutlineInputBorder(
                                            //                           borderRadius:
                                            //                               BorderRadius.all(
                                            //                                   Radius.circular(6)),
                                            //                           borderSide:
                                            //                               BorderSide(
                                            //                             width:
                                            //                                 1,
                                            //                             color: Colors
                                            //                                 .grey,
                                            //                           ),
                                            //                         ),
                                            //                         // labelText: 'ระบุชื่อร้านค้า',
                                            //                         labelStyle: const TextStyle(
                                            //                             fontSize:
                                            //                                 14,
                                            //                             color: Colors
                                            //                                 .black54,
                                            //                             fontFamily:
                                            //                                 Font_.Fonts_T)),
                                            //                 // inputFormatters: <TextInputFormatter>[
                                            //                 //   // for below version 2 use this
                                            //                 //   FilteringTextInputFormatter
                                            //                 //       .allow(RegExp(r'[0-9]')),
                                            //                 //   // for version 2 and greater youcan also use this
                                            //                 //   FilteringTextInputFormatter
                                            //                 //       .digitsOnly
                                            //                 // ],
                                            //               ),
                                            //             ),
                                            //           )
                                            //         ],
                                            //       ),
                                            //     ),
                                            //   ),
                                          ]),
                                        )),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                            children: [Doc_Data(context)]),
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 2,
                                    //   child:
                                    // Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: Column(children: [
                                    //       SizedBox(
                                    //         child: Column(
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment.start,
                                    //           children: [
                                    //             Container(
                                    //               decoration: BoxDecoration(
                                    //                 color: AppbackgroundColor
                                    //                         .TiTile_Colors
                                    //                     .withOpacity(0.8),
                                    //                 borderRadius:
                                    //                     BorderRadius.only(
                                    //                         topLeft:
                                    //                             Radius.circular(
                                    //                                 10),
                                    //                         topRight:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         bottomLeft:
                                    //                             Radius.circular(
                                    //                                 0),
                                    //                         bottomRight:
                                    //                             Radius.circular(
                                    //                                 0)),
                                    //                 // border: Border.all(color: Colors.grey, width: 1),
                                    //               ),
                                    //               padding:
                                    //                   const EdgeInsets.fromLTRB(
                                    //                       0, 0, 0, 0),
                                    //               // padding:
                                    //               //     const EdgeInsets.symmetric(
                                    //               //         vertical: 5,
                                    //               //         horizontal: 16),
                                    //               child: Column(
                                    //                 children: [
                                    //                   AutoSizeText(
                                    //                     minFontSize: 12,
                                    //                     maxFontSize: 16,
                                    //                     maxLines: 1,
                                    //                     'เอกสารแนบ (8เอกสาร)',
                                    //                     textAlign:
                                    //                         TextAlign.center,
                                    //                     overflow: TextOverflow
                                    //                         .ellipsis,
                                    //                     style: TextStyle(
                                    //                         color: PeopleChaoScreen_Color
                                    //                             .Colors_Text2_,
                                    //                         fontFamily:
                                    //                             Font_.Fonts_T),
                                    //                   ),
                                    //                   Container(
                                    //                     color:
                                    //                         Colors.brown[200],
                                    //                     child: Row(children: [
                                    //                       for (var title_doc
                                    //                           in data_title_doc)
                                    //                         Expanded(
                                    //                           flex: 1,
                                    //                           child: Container(
                                    //                             padding:
                                    //                                 const EdgeInsets
                                    //                                         .all(
                                    //                                     2.0),
                                    //                             child:
                                    //                                 AutoSizeText(
                                    //                               minFontSize:
                                    //                                   12,
                                    //                               maxFontSize:
                                    //                                   16,
                                    //                               maxLines: 1,
                                    //                               '${title_doc["title"]}',
                                    //                               textAlign:
                                    //                                   TextAlign
                                    //                                       .left,
                                    //                               overflow:
                                    //                                   TextOverflow
                                    //                                       .ellipsis,
                                    //                               style: TextStyle(
                                    //                                   color: PeopleChaoScreen_Color
                                    //                                       .Colors_Text2_,
                                    //                                   fontFamily:
                                    //                                       Font_
                                    //                                           .Fonts_T),
                                    //                             ),
                                    //                           ),
                                    //                         ),
                                    //                     ]),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //             for (var doc in data_doc)
                                    //               Row(children: [
                                    //                 for (var title_doc
                                    //                     in data_title_doc)
                                    //                   Expanded(
                                    //                     flex: 1,
                                    //                     child: Padding(
                                    //                       padding:
                                    //                           const EdgeInsets
                                    //                               .all(2.0),
                                    //                       child:
                                    //                           ('${title_doc["title"]}' ==
                                    //                                   'ไฟล์เอกสาร')
                                    //                               ? Row(
                                    //                                   children: [
                                    //                                     SizedBox(
                                    //                                       width:
                                    //                                           120,
                                    //                                       child:
                                    //                                           ElevatedButton(
                                    //                                         style:
                                    //                                             ButtonStyle(
                                    //                                           backgroundColor: MaterialStateProperty.all<Color>(
                                    //                                             (doc["status"]! != 'รอตรวจสอบ') ? Colors.lime.shade800 : Colors.black,
                                    //                                           ),
                                    //                                         ),
                                    //                                         onPressed:
                                    //                                             () async {
                                    //                                           Navigator.push(
                                    //                                               context,
                                    //                                               MaterialPageRoute(
                                    //                                                 builder: (context) => PreviewPdf_ordit_CMM(title: '${doc["title"]}'),
                                    //                                               ));
                                    //                                         },
                                    //                                         child: Translate.TranslateAndSet_TextAutoSize(
                                    //                                             'เรียกดู',
                                    //                                             (doc["status"]! != 'รอตรวจสอบ') ? CustomerScreen_Color.Colors_Text2_ : CustomerScreen_Color.Colors_Text3_,
                                    //                                             TextAlign.center,
                                    //                                             null,
                                    //                                             Font_.Fonts_T,
                                    //                                             10,
                                    //                                             14,
                                    //                                             1),
                                    //                                       ),
                                    //                                     ),
                                    //                                   ],
                                    //                                 )
                                    //                               : Container(
                                    //                                   padding:
                                    //                                       const EdgeInsets.all(
                                    //                                           0.0),
                                    //                                   child:
                                    //                                       AutoSizeText(
                                    //                                     minFontSize:
                                    //                                         12,
                                    //                                     maxFontSize:
                                    //                                         16,
                                    //                                     maxLines:
                                    //                                         1,
                                    //                                     '${doc["${title_doc["data"]}"]}',
                                    //                                     textAlign:
                                    //                                         TextAlign.left,
                                    //                                     overflow:
                                    //                                         TextOverflow.ellipsis,
                                    //                                     style: TextStyle(
                                    //                                         color: ('${title_doc["title"]}' == 'สถานะ')
                                    //                                             ? (doc["status"]! == 'เอกสารถูกต้อง')
                                    //                                                 ? Colors.green
                                    //                                                 : (doc["status"]! == 'รอแก้ไข')
                                    //                                                     ? Colors.orange
                                    //                                                     : (doc["status"]! == 'ไม่ผ่านเกณฑ์')
                                    //                                                         ? Colors.red
                                    //                                                         : CustomerScreen_Color.Colors_Text2_
                                    //                                             : CustomerScreen_Color.Colors_Text2_,
                                    //                                         fontFamily: Font_.Fonts_T),
                                    //                                   ),
                                    //                                 ),
                                    //                     ),
                                    //                   ),
                                    //                 Padding(
                                    //                   padding:
                                    //                       const EdgeInsets.all(
                                    //                           2.0),
                                    //                   child: Icon(
                                    //                     Icons.delete_outline,
                                    //                     color: Colors.red,
                                    //                   ),
                                    //                 )
                                    //               ])
                                    //           ],
                                    //         ),
                                    //       ),
                                    //       SizedBox(
                                    //         height: 20,
                                    //       ),
                                    //       SizedBox(
                                    //         child: Column(
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment.start,
                                    //           children: [
                                    //             Container(
                                    //               decoration: BoxDecoration(
                                    //                 color: AppbackgroundColor
                                    //                         .TiTile_Colors
                                    //                     .withOpacity(0.8),
                                    //                 borderRadius:
                                    //                     BorderRadius.only(
                                    //                         topLeft:
                                    //                             Radius.circular(
                                    //                                 10),
                                    //                         topRight:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         bottomLeft:
                                    //                             Radius.circular(
                                    //                                 0),
                                    //                         bottomRight:
                                    //                             Radius.circular(
                                    //                                 0)),
                                    //                 // border: Border.all(color: Colors.grey, width: 1),
                                    //               ),
                                    //               padding:
                                    //                   const EdgeInsets.fromLTRB(
                                    //                       0, 0, 0, 0),
                                    //               // padding:
                                    //               //     const EdgeInsets.symmetric(
                                    //               //         vertical: 5,
                                    //               //         horizontal: 16),
                                    //               child: Column(
                                    //                 children: [
                                    //                   AutoSizeText(
                                    //                     minFontSize: 12,
                                    //                     maxFontSize: 16,
                                    //                     maxLines: 1,
                                    //                     'รายการชำระ',
                                    //                     textAlign:
                                    //                         TextAlign.center,
                                    //                     overflow: TextOverflow
                                    //                         .ellipsis,
                                    //                     style: TextStyle(
                                    //                         color: PeopleChaoScreen_Color
                                    //                             .Colors_Text2_,
                                    //                         fontFamily:
                                    //                             Font_.Fonts_T),
                                    //                   ),
                                    //                   Container(
                                    //                     color:
                                    //                         Colors.brown[200],
                                    //                     child: Row(children: [
                                    //                       for (var title_receipt
                                    //                           in data_title_receipt)
                                    //                         Expanded(
                                    //                           flex:
                                    //                               '${title_receipt["title"]}' ==
                                    //                                       'สถานะ'
                                    //                                   ? 2
                                    //                                   : 1,
                                    //                           child: Container(
                                    //                             padding:
                                    //                                 const EdgeInsets
                                    //                                         .all(
                                    //                                     2.0),
                                    //                             child:
                                    //                                 AutoSizeText(
                                    //                               minFontSize:
                                    //                                   12,
                                    //                               maxFontSize:
                                    //                                   16,
                                    //                               maxLines: 1,
                                    //                               '${title_receipt["title"]}',
                                    //                               textAlign:
                                    //                                   TextAlign
                                    //                                       .left,
                                    //                               overflow:
                                    //                                   TextOverflow
                                    //                                       .ellipsis,
                                    //                               style: TextStyle(
                                    //                                   color: PeopleChaoScreen_Color
                                    //                                       .Colors_Text2_,
                                    //                                   fontFamily:
                                    //                                       Font_
                                    //                                           .Fonts_T),
                                    //                             ),
                                    //                           ),
                                    //                         ),
                                    //                     ]),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //             for (var receipt
                                    //                 in data_receipt)
                                    //               Row(children: [
                                    //                 for (var title_receipt
                                    //                     in data_title_receipt)
                                    //                   Expanded(
                                    //                     flex:
                                    //                         '${title_receipt["title"]}' ==
                                    //                                 'สถานะ'
                                    //                             ? 2
                                    //                             : 1,
                                    //                     child: Container(
                                    //                       padding:
                                    //                           const EdgeInsets
                                    //                               .all(2.0),
                                    //                       child: AutoSizeText(
                                    //                         minFontSize: 12,
                                    //                         maxFontSize: 16,
                                    //                         maxLines: 1,
                                    //                         '${receipt["${title_receipt["data"]}"]}',
                                    //                         textAlign:
                                    //                             TextAlign.left,
                                    //                         overflow:
                                    //                             TextOverflow
                                    //                                 .ellipsis,
                                    //                         style: TextStyle(
                                    //                             color: PeopleChaoScreen_Color
                                    //                                 .Colors_Text2_,
                                    //                             fontFamily: Font_
                                    //                                 .Fonts_T),
                                    //                       ),
                                    //                     ),
                                    //                   ),
                                    //               ]),
                                    //             Padding(
                                    //               padding:
                                    //                   const EdgeInsets.all(0.0),
                                    //               child: Row(
                                    //                 crossAxisAlignment:
                                    //                     CrossAxisAlignment
                                    //                         .center,
                                    //                 children: [
                                    //                   Padding(
                                    //                     padding:
                                    //                         const EdgeInsets
                                    //                             .all(8.0),
                                    //                     child: Icon(
                                    //                       Icons.info,
                                    //                       size: 18,
                                    //                     ),
                                    //                   ),
                                    //                   Expanded(
                                    //                     child: AutoSizeText(
                                    //                       minFontSize: 12,
                                    //                       maxFontSize: 16,
                                    //                       maxLines: 1,
                                    //                       'โปรดเรียกดูเอกสารแนบเพื่อตรวจสอบความถูกต้องของเอกสารหลักฐานก่อนดำเนินการยืนยันเอกสารถูกต้อง',
                                    //                       textAlign:
                                    //                           TextAlign.left,
                                    //                       overflow: TextOverflow
                                    //                           .ellipsis,
                                    //                       style: TextStyle(
                                    //                           color: PeopleChaoScreen_Color
                                    //                               .Colors_Text2_,
                                    //                           fontFamily: Font_
                                    //                               .Fonts_T),
                                    //                     ),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //       SizedBox(
                                    //         height: 20,
                                    //       ),
                                    //       SizedBox(
                                    //         child: Column(
                                    //           crossAxisAlignment:
                                    //               CrossAxisAlignment.start,
                                    //           children: [
                                    //             Padding(
                                    //               padding:
                                    //                   const EdgeInsets.all(8.0),
                                    //               child: AutoSizeText(
                                    //                 minFontSize: 12,
                                    //                 maxFontSize: 16,
                                    //                 maxLines: 1,
                                    //                 'หมายเหตุ',
                                    //                 textAlign: TextAlign.left,
                                    //                 overflow:
                                    //                     TextOverflow.ellipsis,
                                    //                 style: TextStyle(
                                    //                     color:
                                    //                         PeopleChaoScreen_Color
                                    //                             .Colors_Text2_,
                                    //                     fontFamily:
                                    //                         Font_.Fonts_T),
                                    //               ),
                                    //             ),
                                    //             Padding(
                                    //               padding:
                                    //                   const EdgeInsets.all(2.0),
                                    //               child: TextFormField(
                                    //                 readOnly: false,
                                    //                 keyboardType:
                                    //                     TextInputType.number,
                                    //                 // controller: Formbecause_,
                                    //                 initialValue: '',
                                    //                 validator: (value) {
                                    //                   if (value == null ||
                                    //                       value.isEmpty) {
                                    //                     return 'ใส่ข้อมูลให้ครบถ้วน ';
                                    //                   }
                                    //                   // if (int.parse(value.toString()) < 13) {
                                    //                   //   return '< 13';
                                    //                   // }
                                    //                   return null;
                                    //                 },
                                    //                 onChanged: (value) {
                                    //                   // setState(() {
                                    //                   //   Formbecause_.text =
                                    //                   //       value.toString();
                                    //                   // });
                                    //                 },
                                    //                 maxLines: 3,
                                    //                 cursorColor: Colors.green,
                                    //                 decoration: InputDecoration(
                                    //                     fillColor: Colors.white
                                    //                         .withOpacity(0.3),
                                    //                     filled: true,
                                    //                     // prefixIcon: const Icon(Icons.water,
                                    //                     //     color: Colors.blue),
                                    //                     // suffixIcon: Icon(Icons.clear, color: Colors.black),
                                    //                     focusedBorder:
                                    //                         const OutlineInputBorder(
                                    //                       borderRadius:
                                    //                           BorderRadius.only(
                                    //                         topRight:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         topLeft:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         bottomRight:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         bottomLeft:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                       ),
                                    //                       borderSide:
                                    //                           BorderSide(
                                    //                         width: 1,
                                    //                         color: Colors.black,
                                    //                       ),
                                    //                     ),
                                    //                     enabledBorder:
                                    //                         const OutlineInputBorder(
                                    //                       borderRadius:
                                    //                           BorderRadius.only(
                                    //                         topRight:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         topLeft:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         bottomRight:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                         bottomLeft:
                                    //                             Radius.circular(
                                    //                                 15),
                                    //                       ),
                                    //                       borderSide:
                                    //                           BorderSide(
                                    //                         width: 1,
                                    //                         color: Colors.grey,
                                    //                       ),
                                    //                     ),
                                    //                     // labelText: 'คำอธิบาย',
                                    //                     labelStyle:
                                    //                         const TextStyle(
                                    //                       color:
                                    //                           ManageScreen_Color
                                    //                               .Colors_Text2_,
                                    //                       // fontWeight:
                                    //                       //     FontWeight.bold,
                                    //                       fontFamily:
                                    //                           Font_.Fonts_T,
                                    //                     )),
                                    //                 // inputFormatters: <TextInputFormatter>[
                                    //                 //   // for below version 2 use this
                                    //                 //   FilteringTextInputFormatter.allow(
                                    //                 //       RegExp(r'[0-9]')),
                                    //                 //   // for version 2 and greater youcan also use this
                                    //                 //   FilteringTextInputFormatter.digitsOnly
                                    //                 // ],
                                    //               ),
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //       SizedBox(
                                    //         height: 20,
                                    //       ),
                                    //       Row(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.spaceBetween,
                                    //         children: [
                                    //           SizedBox(
                                    //             width: 200,
                                    //             child: ElevatedButton(
                                    //               style: ButtonStyle(
                                    //                 backgroundColor:
                                    //                     MaterialStateProperty
                                    //                         .all<Color>(
                                    //                   const Color.fromARGB(
                                    //                       255, 243, 131, 130),
                                    //                 ),
                                    //               ),
                                    //               onPressed: () async {
                                    //                 generateRandomString();
                                    //                 Cancel_showDialog();
                                    //               },
                                    //               child: Padding(
                                    //                 padding:
                                    //                     const EdgeInsets.all(
                                    //                         8.0),
                                    //                 child: Translate
                                    //                     .TranslateAndSet_TextAutoSize(
                                    //                         'ปฏิเสธคำร้อง/แจ้งการแก้ไข',
                                    //                         ChaoAreaScreen_Color
                                    //                             .Colors_Text2_,
                                    //                         TextAlign.center,
                                    //                         null,
                                    //                         FontWeight_.Fonts_T,
                                    //                         12,
                                    //                         18,
                                    //                         1),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //           SizedBox(
                                    //             width: 200,
                                    //             child: ElevatedButton(
                                    //               style: ButtonStyle(
                                    //                 backgroundColor:
                                    //                     MaterialStateProperty
                                    //                         .all<Color>(
                                    //                   Colors.black,
                                    //                 ),
                                    //               ),
                                    //               onPressed: () async {
                                    //                 //     SharedPreferences preferences =
                                    //                 //     await SharedPreferences
                                    //                 //         .getInstance();
                                    //                 // String? _route = preferences
                                    //                 //     .getString('route');
                                    //                 // MaterialPageRoute
                                    //                 //     materialPageRoute =
                                    //                 //     MaterialPageRoute(
                                    //                 //         builder: (BuildContext
                                    //                 //                 context) =>
                                    //                 //             AdminScafScreen(
                                    //                 //                 route:
                                    //                 //                     'RequestDetails_CMM'));
                                    //                 // Navigator
                                    //                 //     .pushAndRemoveUntil(
                                    //                 //         context,
                                    //                 //         materialPageRoute,
                                    //                 //         (route) => false);

                                    //                 setState(() {
                                    //                   ser_tap = 2;
                                    //                 });
                                    //               },
                                    //               child: Padding(
                                    //                 padding:
                                    //                     const EdgeInsets.all(
                                    //                         8.0),
                                    //                 child: Translate
                                    //                     .TranslateAndSet_TextAutoSize(
                                    //                         'ยืนยัน/ถัดไป',
                                    //                         ChaoAreaScreen_Color
                                    //                             .Colors_Text3_,
                                    //                         TextAlign.center,
                                    //                         null,
                                    //                         FontWeight_.Fonts_T,
                                    //                         12,
                                    //                         18,
                                    //                         1),
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ],
                                    //       )
                                    //     ]),
                                    //   ),
                                    // ),
                                  ],
                                )))),
                  )
                ]),
              ),
            ));
  }

  String randomString = '';
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

  Future<Null> Cancel_showDialog() async {
    List<Map<String, dynamic>> data_user_cancel = [
      {
        "ser": "1",
        "title": "วันที่ตรวจสอบ",
        "detail": "04-05-2025",
      },
      {
        "ser": "2",
        "title": "ชื่อเอกสาร",
        "detail": "รูปถ่าย",
      },
      {
        "ser": "3",
        "title": "ชื่อผู้ตรวจสอบ",
        "detail": "นางสาวเชียงราย พะเยา",
      },
    ];
    return showDialog(
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
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                for (int index = 0; index < data_user_cancel.length; index++)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      width: 300,
                      height: 80,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Translate.TranslateAndSet_TextAutoSize(
                                '${data_user_cancel[index]["title"]}',
                                ChaoAreaScreen_Color.Colors_Text2_,
                                TextAlign.center,
                                null,
                                FontWeight_.Fonts_T,
                                12,
                                18,
                                1),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                            child: Container(
                              height: 33,
                              child: TextFormField(
                                // scrollPadding: const EdgeInsets.all(1.0),
                                autofocus: true,
                                readOnly: true,
                                // focusNode: myFocusNode,
                                textAlign: TextAlign.left,
                                keyboardType: TextInputType.number,
                                // controller: FormMeter_text,
                                // validator: (value) {
                                //   try {
                                //     if (value == null || value.isEmpty) {
                                //       return 'กรุณากรอกค่า';
                                //     }

                                //     final input = int.parse(value);
                                //     final indexx = int.parse(row['index'].toString());
                                //     final oldValue = int.parse(
                                //         transMeterModels[indexx].ovalue.toString());

                                //     if (input < oldValue) {
                                //       return 'ค่าต้องไม่น้อยกว่า $oldValue';
                                //     }
                                //   } catch (e) {
                                //     return 'รูปแบบไม่ถูกต้อง';
                                //   }

                                //   return null;
                                // },
                                // maxLength: 13,
                                initialValue:
                                    '${data_user_cancel[index]["detail"]}',
                                onChanged: (value) {},

                                cursorColor: Colors.green,
                                decoration: InputDecoration(
                                    fillColor: Colors.white.withOpacity(0.3),
                                    filled: true,
                                    // prefixIcon: const Icon(
                                    //     Icons
                                    //         .electrical_services,
                                    //     color: Colors.red),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: Colors.green.shade800,
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
                                    // labelText: 'เลขมิเตอร์',
                                    labelStyle: const TextStyle(
                                      color: ManageScreen_Color.Colors_Text2_,
                                      // fontWeight:
                                      //     FontWeight.bold,
                                      fontFamily: Font_.Fonts_T,
                                    )),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.deny(
                                      RegExp("[' ']")),
                                  // for below version 2 use this
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9 .]')),
                                  // for version 2 and greater youcan also use this
                                  // FilteringTextInputFormatter
                                  //     .digitsOnly
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 0)),
                    builder: (context, snapshot) {
                      return Column(
                        children: [
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
                                        color:
                                            Color.fromARGB(255, 179, 177, 170),
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
                        ],
                      );
                    }),
              ],
            ),
          ),
          actions: [
            Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: SizedBox(
                  //     width: 200,
                  //     child: ElevatedButton(
                  //       style: ButtonStyle(
                  //         backgroundColor: MaterialStateProperty.all<Color>(
                  //           const Color.fromARGB(255, 243, 131, 130),
                  //         ),
                  //       ),
                  //       onPressed: () async {
                  //         Cancel_showDialog();
                  //         SharedPreferences preferences =
                  //             await SharedPreferences.getInstance();
                  //         String? _route = preferences.getString('route');
                  //         MaterialPageRoute materialPageRoute =
                  //             MaterialPageRoute(
                  //                 builder: (BuildContext context) =>
                  //                     AdminScafScreen(route: 'ใบอนุญาต'));
                  //         Navigator.pushAndRemoveUntil(
                  //             context, materialPageRoute, (route) => false);
                  //       },
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Translate.TranslateAndSet_TextAutoSize(
                  //             'ปฏิเสธคำร้อง/แจ้งการแก้ไข',
                  //             ChaoAreaScreen_Color.Colors_Text2_,
                  //             TextAlign.center,
                  //             null,
                  //             FontWeight_.Fonts_T,
                  //             12,
                  //             18,
                  //             1),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            (Pincontroller.text != "$randomString")
                                ? Colors.grey
                                : Colors.black,
                            // Colors.black,
                          ),
                        ),
                        onPressed: () async {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          String? _route = preferences.getString('route');
                          MaterialPageRoute materialPageRoute =
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AdminScafScreen(route: 'ใบอนุญาต'));
                          Navigator.pushAndRemoveUntil(
                              context, materialPageRoute, (route) => false);

                          // setState(() {
                          //   ser_tap = 2;
                          // });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Translate.TranslateAndSet_TextAutoSize(
                              'ยืนยัน',
                              ChaoAreaScreen_Color.Colors_Text3_,
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
            )
          ],
        ),
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
                      showCursor: false,
                      readOnly: true,
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
                                    showCursor: false,
                                    readOnly: true,
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
                            showCursor: false,
                            readOnly: true,
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
                    onTap: (cid['ser'].toString() == '3' ||
                            cid['ser'].toString() == '4')
                        ? null
                        : () async {
                            DateTime? newDate = await showDatePicker(
                              // locale: const Locale('th', 'TH'),
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now()
                                  .add(const Duration(days: -100)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 400)),
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
                                        primary:
                                            Colors.black, // button text color
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
                                      DateFormat('yyyy-MM-dd').format(newDate);
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
                                  Dialog_error(
                                      context, 'กรุณาเลือกวันที่เริ่มต้นก่อน');
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
                    'เอกสารแนบ (${reviewDetail.first.attachments.length}เอกสาร)',
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
            (reviewDetail.first.attachments.isEmpty)
                ? SizedBox(height: 100, child: Widget_Loading(context))
                : SizedBox(
                    child: Column(
                    children: reviewDetail.first.attachments.map((doc) {
                      return SizedBox(
                        child: Row(
                          children: [
                            // for (var title_doc in data_title_doc)
                            Container(
                              padding: const EdgeInsets.all(0.0),
                              child: AutoSizeText(
                                doc.fileName.toString(),
                                // getDisplayText(doc, doc.fileName.toString()),
                                minFontSize: 12,
                                maxFontSize: 16,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: CustomerScreen_Color.Colors_Text2_,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  )

                    // Column(children: [
                    //   // for (var doc in reviewDetail.first.attachments.toList())
                    //     Row(children: [
                    //       for (var title_doc in data_title_doc)
                    //         Expanded(
                    //           flex: 1,
                    //           child: Padding(
                    //             padding: const EdgeInsets.all(2.0),
                    //             child: ('${title_doc["title"]}' == 'ไฟล์เอกสาร')
                    //                 ? Row(
                    //                     children: [
                    //                       SizedBox(
                    //                         width: 120,
                    //                         child: ElevatedButton(
                    //                           style: ButtonStyle(
                    //                             backgroundColor:
                    //                                 MaterialStateProperty.all<
                    //                                     Color>(
                    //                               (attachments.isNotEmpty)
                    //                                   ? Colors.lime.shade800
                    //                                   : Colors.black,
                    //                             ),
                    //                           ),
                    //                           onPressed: (attachments != null &&
                    //                                   attachments!.isNotEmpty)
                    //                               ? () async {
                    //                                   final matched =
                    //                                       findAttachmentByDocId(
                    //                                           attachments ?? [],
                    //                                           doc.id);
                    //                                   final file_Uuid =
                    //                                       matched?.uuid ?? '';
                    //                                   final file_Path =
                    //                                       matched?.filePath ??
                    //                                           '';
                    //                                   final file_Type =
                    //                                       matched?.fileType ??
                    //                                           '';
                    //                                   final RequestUuid =
                    //                                       matched?.requestUuid ??
                    //                                           '';
                    //                                   // print(
                    //                                   //     'doc.id : ${doc.id}');
                    //                                   // print(matched);
                    //                                   print(
                    //                                       'file_Uuid : $file_Uuid');
                    //                                   print(
                    //                                       'file_Path : $file_Path');
                    //                                   print(
                    //                                       'file_Type : $file_Type');
                    //                                   Navigator.push(
                    //                                       context,
                    //                                       MaterialPageRoute(
                    //                                         builder: (context) => PreviewPdf_ordit_CMM(
                    //                                             id: doc.id,
                    //                                             uuid: file_Uuid,
                    //                                             Request_Uuid:
                    //                                                 RequestUuid,
                    //                                             code:
                    //                                                 'attachments  .code',
                    //                                             file_path:
                    //                                                 file_Path,
                    //                                             file_type:
                    //                                                 file_Type,
                    //                                             title:
                    //                                                 'docnameTh'),
                    //                                       ));
                    //                                 }
                    //                               : null,
                    //                           child: Translate
                    //                               .TranslateAndSet_TextAutoSize(
                    //                                   'เรียกดู',
                    //                                   CustomerScreen_Color
                    //                                       .Colors_Text3_,
                    //                                   TextAlign.center,
                    //                                   null,
                    //                                   Font_.Fonts_T,
                    //                                   10,
                    //                                   14,
                    //                                   1),
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   )
                    //                 : Container(
                    //                     padding: const EdgeInsets.all(0.0),
                    //                     child: AutoSizeText(
                    //                       getDisplayText(doc, title_doc),
                    //                       minFontSize: 12,
                    //                       maxFontSize: 16,
                    //                       maxLines: 1,
                    //                       textAlign: TextAlign.left,
                    //                       overflow: TextOverflow.ellipsis,
                    //                       style: TextStyle(
                    //                         color: CustomerScreen_Color
                    //                             .Colors_Text2_,
                    //                         fontFamily: Font_.Fonts_T,
                    //                       ),
                    //                     ),
                    //                   ),
                    //           ),
                    //         ),
                    //     ])
                    // ]),
                    ),
          ],
        ),
      ),
      SizedBox(
        height: 40,
      ),
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
                    'รายการชำระ( ${attachments.length})',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T),
                  ),
                  Container(
                    color: Colors.brown[200],
                    child: Row(children: [
                      for (var title_receipt in data_title_receipt)
                        Expanded(
                          flex: '${title_receipt["title"]}' == 'สถานะ' ? 2 : 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              '${title_receipt["title"]}',
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
            (attachments.isEmpty)
                ? Widget_Loading(context)
                : SizedBox(
                    child: Column(children: [
                      for (var receipt in attachments)
                        Row(children: [
                          for (var title_receipt in data_title_receipt)
                            Expanded(
                              flex: '${title_receipt["title"]}' == 'สถานะ'
                                  ? 2
                                  : 1,
                              child: Container(
                                padding: const EdgeInsets.all(2.0),
                                child: AutoSizeText(
                                  minFontSize: 12,
                                  maxFontSize: 16,
                                  maxLines: 1,
                                  //  '-',
                                  ('${title_receipt["ser"]}' == '1')
                                      ? '${receipt.id}'
                                      : ('${title_receipt["ser"]}' == '2')
                                          ? (receipt.createdAt == null)
                                              ? ''
                                              : DateFormat('dd-MM')
                                                      .format(DateTime.parse(
                                                          receipt.createdAt))
                                                      .toString() +
                                                  '-${DateTime.parse(receipt.createdAt).year}'
                                          : ('${title_receipt["ser"]}' == '3')
                                              ? '${receipt.uuid}'
                                              : '${receipt.active}',
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            ),
                        ]),
                    ]),
                  ),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.info,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'โปรดเรียกดูเอกสารแนบเพื่อตรวจสอบความถูกต้องของเอกสารหลักฐานก่อนดำเนินการยืนยันเอกสารถูกต้อง',
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
}
