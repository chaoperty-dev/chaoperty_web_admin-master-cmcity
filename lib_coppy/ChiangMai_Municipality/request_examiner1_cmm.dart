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
import 'Make_contract_CMM/repayment_contract_cmm.dart';
import 'Model/Dataconfig_Model.dart';
import 'Model/Document_Model.dart';
import 'Model/Person&Shop_Model.dart';
import 'Model/ReviewUuid_Model.dart';
import 'Model/Review_Model.dart';
import 'PDF_CMM/checklist_form_cmm.dart';
import 'PDF_CMM/receipt_cmm.dart';
import 'PDF_CMM/receipt_view_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf_ordit_cmm2.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdfchecklist_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdfchecklist_cmm2.dart';
import 'cignaturepad_cmm.dart';
import 'unity/API_admin_reject.dart';
import 'unity/API_admin_requests.dart';
import 'unity/API_admin_signature.dart';
import 'unity/API_payment.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/API_requests_reviewsflow.dart';
import 'unity/Enum.dart';
import 'unity/FormatDate.dart';
import 'unity/SecurePrefs_helper.dart';
import 'unity/show_dialog_cmm.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math' as math;
import 'dart:html' as html;
import 'unity/plugin_signal.dart';

class RequestExaminer1_CMM extends StatefulWidget {
  final bool viewver;
  final bool plugin;
  const RequestExaminer1_CMM(
      {super.key, required this.viewver, required this.plugin});

  @override
  State<RequestExaminer1_CMM> createState() => _RequestExaminer1_CMMState();
}

class _RequestExaminer1_CMMState extends State<RequestExaminer1_CMM> {
  int ser_tap = 1, MobieTap = 2;
  List<TextEditingController> _controllers_person = [];
  List<TextEditingController> _controllers_shop = [];
  List<TextEditingController> _controllers_shop_sub = [];
  List<TextEditingController> _controllers_cid = [];
  final TextEditingController Formbecause_ = TextEditingController();
  final TextEditingController _noteNumberController =
      TextEditingController(text: '');
  final TextEditingController _noteDateController =
      TextEditingController(text: '');
  final TextEditingController _feeNumberController =
      TextEditingController(text: '');
  final TextEditingController _feeDateController =
      TextEditingController(text: '');
  final TextEditingController _feeBookNoController =
      TextEditingController(text: '');
  final TextEditingController _fineNumberController =
      TextEditingController(text: '');
  final TextEditingController _fineDateController =
      TextEditingController(text: '');
  final TextEditingController _fineBookNoController =
      TextEditingController(text: '');
  ////////////--------------------->
  List<PersonFieldModel> data_person = data_persons;
  List<ShopFieldModel> data_shop = data_shops;
  List<AttachmentsModel> attachments = [];
  List data_cid = [];
  List data_title_doc = [];
  List data_title_receipt = [];
  List submitteddoc_checklist = [];
  ////////////--------------------->
  @override
  void initState() {
    super.initState();
    Loading_Data_config();
    loadClientReviewsUuid();
    // ฟังสัญญาณอัปโหลดจาก plugin
    pluginUploadSignal.addListener(_onPluginUpload);
    _controllers_person = List.generate(
      data_person.length,
      (i) => TextEditingController(text: data_person[i].detail ?? ''),
    );
    _controllers_shop = List.generate(
      data_shop.length,
      (i) => TextEditingController(text: data_shop[i].detail ?? ''),
    );
    _controllers_shop_sub = (data_shop.isNotEmpty)
        ? List.generate(
            data_shop[0].detailsub.length,
            (i) => TextEditingController(
                text: data_shop[0].detailsub[i].detail ?? ''),
          )
        : [];

    _controllers_cid = List.generate(
      data_cid.length,
      (i) => TextEditingController(text: data_cid[i]['detail'] ?? ''),
    );
  }

  void _onPluginUpload() {
    loadClientReviewsUuid();
  }

  Loading_Data_config() async {
    final cid = await getContractInfo(); // รอให้โหลดเสร็จก่อน
    final doc = await getDocumentDisplayFields();
    final receipt = await getReceiptDisplayFields();
    final checklist = await getSubmittedDocumentsDisplayFields();
    setState(() {
      data_cid = cid;
      data_title_doc = doc;
      data_title_receipt = receipt;
      submitteddoc_checklist = checklist;
    });
  }

  List<ReviewDetail> reviewDetail = [];
  bool isOpenApproved = false;
  String? requestUuid, FlowUuid;
  Future<void> loadClientReviewsUuid() async {
    setState(() {
      reviewDetail.clear();
    });
    String? value = await SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest);
    String? valueFlowUuid =
        await SecurePrefs.getDecrypted(SecurePrefsType.flowUuid);
    //print('🔓 UUID Request: $value');
    //print('loadClientReviewsUuid');
    setState(() {
      requestUuid = value;
      FlowUuid = valueFlowUuid;
    });

    final response = await read_GC_ReviewsUuid(value);

    if (response != null && response.statusCode == 200) {
      final result = json.decode(response.body);
      print('🔍 [REVIEW RAW] payment field = ${result['data']?['payment']}');
      final reviewDetailModel = ReviewDetail.fromJson(result['data']);
      print(
          '🔍 [REVIEW PARSED] payment.uuid="${reviewDetailModel.payment.uuid}" requestUuid="${reviewDetailModel.payment.requestUuid}" status="${reviewDetailModel.payment.status}"');
      dynamic is_open_approved = result['is_open_approved'];

      setState(() {
        isOpenApproved = is_open_approved;
        reviewDetail.add(reviewDetailModel);
      });
    } else {
      //print('error');
    }

    if (reviewDetail.isNotEmpty) {
      Set_data();
      await read_Addon_Data();
    }
  }

  Future<void> read_Addon_Data() async {
    String _parseDate(String raw) {
      if (raw.isEmpty || raw == '0000-00-00' || raw == 'null') return '';
      try {
        return DateFormat('dd-MM-yyyy')
            .format(DateFormat('yyyy-MM-dd').parse(raw));
      } catch (_) {
        return raw;
      }
    }

    // GET บันทึกข้อความ → /admin/requests/{requestUuid}/addon
    if (requestUuid != null && requestUuid!.isNotEmpty) {
      try {
        final noteResp = await get_ReviewsAddon(requestUuid: requestUuid!);
        if (noteResp != null && noteResp.body.isNotEmpty) {
          // ตรวจสอบก่อนว่า response เป็น JSON หรือไม่ (ป้องกัน HTML error page)
          if (!noteResp.body.trim().startsWith('{') &&
              !noteResp.body.trim().startsWith('[')) {
            print('⚠️ Note addon response is not JSON, skipping');
          } else {
            final result = json.decode(noteResp.body);
            if (result is Map && result['data'] is Map) {
              final data = result['data'] as Map;
              setState(() {
                _noteNumberController.text = (data['book_no'] ?? '').toString();
                _noteDateController.text =
                    _parseDate((data['book_date'] ?? '').toString());
              });
            }
          }
        }
      } catch (e) {
        print('Error read note addon: $e');
      }
    }

    // GET ใบเสร็จชำระ/ค่าปรับ → /payments/{paymentUuid}/addon
    if (reviewDetail.isEmpty) return;
    final paymentUuid = reviewDetail.first.payment.uuid;
    if (paymentUuid == null || paymentUuid.isEmpty) return;
    try {
      final response = await Get_GC_payment_addon(uuidPayment: paymentUuid);
      if (response == null || response.body.isEmpty) return;
      // ตรวจสอบก่อนว่า response เป็น JSON หรือไม่ (ป้องกัน HTML error page)
      if (!response.body.trim().startsWith('{') &&
          !response.body.trim().startsWith('[')) {
        print('⚠️ Payment addon response is not JSON, skipping');
        return;
      }
      final result = json.decode(response.body);
      final List items = (result is Map && result['data'] is List)
          ? result['data'] as List
          : (result is List ? result : []);

      for (final item in items) {
        if (item is! Map) continue;
        final payType = (item['pay_type'] ?? '').toString();
        final no = (item['no'] ?? '').toString();
        final bookNo = (item['book_no'] ?? '').toString();
        final date = _parseDate((item['book_date'] ?? '').toString());
        setState(() {
          if (payType == 'fee') {
            _feeNumberController.text = no;
            _feeDateController.text = date;
            _feeBookNoController.text = bookNo;
          } else if (payType == 'fine') {
            _fineNumberController.text = no;
            _fineDateController.text = date;
            _fineBookNoController.text = bookNo;
          }
        });
      }
    } catch (e) {
      print('Error read payment addon: $e');
    }
  }

  Future<void> Set_data() async {
    //print('🔄 เริ่มโหลดข้อมูล: uuid = xx, type = type');

    try {
      if (reviewDetail.isNotEmpty) {
        AddForm_requests_uuid(0);
      }
    } catch (e, stack) {
      // //print('❌ เกิดข้อผิดพลาดขณะโหลดข้อมูล [type: $type]');
      //print('🧾 ข้อความ: $e');
      //print('📍 StackTrace:\n$stack');
      setState(() {
        // isLoading = false;
      });
    }
  }

  void AddForm_requests_uuid(index) {
    if (reviewDetail.isEmpty || index < 0 || index >= reviewDetail.length)
      return;
    final details = reviewDetail[index];
    // //print(jsonString);
    //  final model = ClientModel.fromJson(jsonData);
    // //print(model.json?['province']); // → เชียงใหม่
    List<String> data_person_add = [
      details.client?.cname ?? "",
      details.client?.tax ?? "",
      details.client?.age?.toString() ?? "0",
      details.client?.national ?? "",
      details.client?.json?.number ?? "",
      details.client?.json?.moo ?? "",
      details.client?.json?.soi ?? "",
      details.client?.json?.road ?? "",
      details.client?.json?.tambon ?? "",
      details.client?.json?.amphoe ?? "",
      details.client?.json?.province ?? "",
      details.client?.tel ?? "",
      details.client?.addr1 ?? ""
    ];

    List<String> data_shop_add = [
      "-",
      details.newRequest?.qty?.toString() ?? "0",
      details.client?.stype ?? "",
      details.client?.scname ?? ""
    ];
    List<String> data_shopsub_add = [
      details.newRequest?.subzone?.toString() ?? "",
      details.newRequest?.zn ?? "",
      details.newRequest?.ln ?? "",
    ];
    List<String> data_details_add = [
      details.newRequest?.sdate ?? '',
      details.newRequest?.ldate ?? '',
      details.newRequest?.type ?? '',
      '1',
    ];
    List<String> data_cid_add = [
      details.newRequest?.sdate ?? '',
      details.newRequest?.ldate ?? '',
      details.newRequest?.type ?? '',
      details.newRequest?.leaseTermMonths?.toString() ?? '0',
    ];
    // อัปเดตข้อมูลทั้งหมด
    _updateCustomerData(data_person_add, data_shop_add, data_shopsub_add,
        data_details_add, data_cid_add);
  }

  ///////////----------------------->
  void _updateCustomerData(
      personData, shopData, shopSubData, detailsData, cidData) {
    setState(() {
      // อัปเดต person
      for (int i = 0; i < personData.length && i < data_person.length; i++) {
        data_person[i].detail = personData[i].toString();
      }

      // อัปเดต shop
      for (int i = 0; i < shopData.length && i < data_shop.length; i++) {
        data_shop[i].detail = shopData[i].toString();
      }

      // อัปเดต shop.sub เฉพาะ data_shop[0]
      if (data_shop.isNotEmpty) {
        for (int i = 0;
            i < shopSubData.length && i < data_shop[0].detailsub.length;
            i++) {
          data_shop[0].detailsub[i].detail = shopSubData[i].toString();
        }
      }
      // อัปเดต cid
      for (int i = 0; i < cidData.length && i < data_cid.length; i++) {
        data_cid[i]['detail'] = cidData[i].toString();
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
      _controllers_cid = List.generate(
        data_cid.length,
        (i) => TextEditingController(text: data_cid[i]['detail']),
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cts) {
      final screenW = cts.maxWidth - 20;
      final tableMinW = Responsive.isDesktop(context) ? screenW : 980.0;
      // double screenW = MediaQuery.of(context).size.width;

      // ✅ ปรับความกว้าง: ถ้าเป็น Desktop บังคับกว้าง 1400 เป็นขั้นต่ำ
      // ถ้าเป็น Tablet/Mobile ให้บังคับกว้าง 800 เป็นขั้นต่ำ เพื่อให้เลื่อนซ้ายขวาได้และตารางไม่บีบจนเกินไป
      double contentW = Responsive.isDesktop(context)
          ? math.max(screenW, 1400)
          : math.max(screenW, 600);

      return (ser_tap == 2)
          ? SignaturePad_CMM(
              requestUuid: '$requestUuid', triggeredUuid: '$FlowUuid')
          : ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),

                    // ✅ บังคับ width ให้ชัดเจน (สำคัญมาก)
                    child: SizedBox(
                      width: contentW,
                      height: cts.maxHeight - 16, // ✅ ให้สูงพอดีพื้นที่
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: cts.maxHeight - 16, // ✅ อย่างน้อยพอดีจอ
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ช่องค้นหา
                              if (widget.viewver == false &&
                                  widget.plugin == false)
                                Container(
                                  width: (Responsive.isDesktop(context))
                                      ? MediaQuery.of(context).size.width * 0.85
                                      : MediaQuery.of(context).size.width *
                                          0.98,
                                  decoration: BoxDecoration(
                                    color: AppbackgroundColor.TiTile_Box,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Translate.TranslateAndSetText(
                                              'รายละเอียดคำขอใบอนุญาตฯ ',
                                              ChaoAreaScreen_Color
                                                  .Colors_Text1_,
                                              TextAlign.left,
                                              FontWeight.bold,
                                              FontWeight_.Fonts_T,
                                              14,
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: SizedBox(
                                          width: 150,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(
                                                Colors.black,
                                              ),
                                            ),
                                            onPressed: () async {
                                              SharedPreferences preferences =
                                                  await SharedPreferences
                                                      .getInstance();
                                              String? _route = preferences
                                                  .getString('route');

                                              MaterialPageRoute
                                                  materialPageRoute =
                                                  MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        AdminScafScreen(
                                                  route: 'ใบอนุญาต',
                                                  route_getdata: "",
                                                ),
                                              );

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                materialPageRoute,
                                                (route) => false,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.arrow_back_ios,
                                                    color: ChaoAreaScreen_Color
                                                        .Colors_Text3_,
                                                  ),
                                                  Expanded(
                                                    child: Translate
                                                        .TranslateAndSet_TextAutoSize(
                                                      ' ย้อนกลับ ',
                                                      ChaoAreaScreen_Color
                                                          .Colors_Text3_,
                                                      TextAlign.center,
                                                      null,
                                                      FontWeight_.Fonts_T,
                                                      12,
                                                      14,
                                                      1,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              // Translate
                                              //     .TranslateAndSet_TextAutoSize(
                                              //   '<< ย้อนกลับ ',
                                              //   ChaoAreaScreen_Color
                                              //       .Colors_Text3_,
                                              //   TextAlign.center,
                                              //   null,
                                              //   FontWeight_.Fonts_T,
                                              //   12,
                                              //   18,
                                              //   1,
                                              // ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 20),

                              if (!Responsive.isDesktop(context) ||
                                  MediaQuery.of(context).size.width < 1400) ...[
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 2, 2, 2),
                                      child: ElevatedButton(
                                        style: (MobieTap == 1 || MobieTap == 0)
                                            ? ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade800,
                                              )
                                            : ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade400,
                                              ),
                                        onPressed: () async {
                                          setState(() {
                                            MobieTap = 1;
                                          });
                                        },
                                        child: Text(
                                          'ข้อมูลส่วนตัว',
                                          style: TextStyle(
                                            color: CustomerScreen_Color
                                                .Colors_Text3_,
                                            fontSize: 12,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: ElevatedButton(
                                        style: MobieTap == 2
                                            ? ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade800,
                                              )
                                            : ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade400,
                                              ),
                                        onPressed: () async {
                                          setState(() {
                                            MobieTap = 2;
                                          });
                                        },
                                        child: Text(
                                          'เอกสารแนบ',
                                          style: TextStyle(
                                            color: CustomerScreen_Color
                                                .Colors_Text3_,
                                            fontSize: 12,
                                            fontFamily: Font_.Fonts_T,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],

                              const SizedBox(height: 5),

                              // ✅ ห้ามใส่ height เต็มจอใน scroll (นี่คือต้นเหตุจอเทา)
                              Container(
                                decoration: const BoxDecoration(
                                  color: AppbackgroundColor.Sub_Abg_Colors,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                ),
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (Responsive.isDesktop(context) ||
                                        MediaQuery.of(context).size.width >=
                                            1400) ...[
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.person),
                                                Text(
                                                  'ข้อมูลผู้เช่า',
                                                  style: TextStyle(
                                                    color: CustomerScreen_Color
                                                        .Colors_Text1_,
                                                    fontSize: 12,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Form_Person(context),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Icon(Icons.store),
                                                Text(
                                                  'ข้อมูลร้านค้า',
                                                  style: TextStyle(
                                                    color: CustomerScreen_Color
                                                        .Colors_Text1_,
                                                    fontSize: 12,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Form_Shop(context),
                                            const SizedBox(height: 20),
                                            Row(
                                              children: [
                                                Icon(Icons.receipt_long),
                                                Text(
                                                  'ข้อมูลสัญญา',
                                                  style: TextStyle(
                                                    color: CustomerScreen_Color
                                                        .Colors_Text1_,
                                                    fontSize: 12,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Form_Cid(context),
                                            const SizedBox(height: 30),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      if (MobieTap == 1 || MobieTap == 0)
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.person),
                                                  Text(
                                                    'ข้อมูลผู้เช่า',
                                                    style: TextStyle(
                                                      color:
                                                          CustomerScreen_Color
                                                              .Colors_Text1_,
                                                      fontSize: 12,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Form_Person(context),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(Icons.store),
                                                  Text(
                                                    'ข้อมูลร้านค้า',
                                                    style: TextStyle(
                                                      color:
                                                          CustomerScreen_Color
                                                              .Colors_Text1_,
                                                      fontSize: 12,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Form_Shop(context),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Icon(Icons.receipt_long),
                                                  Text(
                                                    'ข้อมูลสัญญา',
                                                    style: TextStyle(
                                                      color:
                                                          CustomerScreen_Color
                                                              .Colors_Text1_,
                                                      fontSize: 12,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Form_Cid(context),
                                              const SizedBox(height: 5),
                                            ],
                                          ),
                                        ),
                                    ],
                                    if (Responsive.isDesktop(context) ||
                                        MediaQuery.of(context).size.width >=
                                            1400) ...[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              // Row(
                                              //   mainAxisAlignment:
                                              //       MainAxisAlignment
                                              //           .center,
                                              //   children: [
                                              //     const Text(
                                              //       'รายการเอกสาร',
                                              //       style: TextStyle(
                                              //           fontWeight:
                                              //               FontWeight.bold),
                                              //     ),
                                              //     // ElevatedButton.icon(
                                              //     //   onPressed:
                                              //     //       _showQRUploadDialog,
                                              //     //   icon: const Icon(
                                              //     //       Icons.qr_code_scanner,
                                              //     //       size: 18),
                                              //     //   label: const Text(
                                              //     //       'อัพโหลดผ่านมือถือ'),
                                              //     //   style: ElevatedButton
                                              //     //       .styleFrom(
                                              //     //     backgroundColor:
                                              //     //         Colors.blue[700],
                                              //     //     foregroundColor:
                                              //     //         Colors.white,
                                              //     //   ),
                                              //     // ),
                                              //   ],
                                              // ),
                                              // const SizedBox(height: 10),
                                              Doc_Data(context),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      if (MobieTap == 2)
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Doc_Data(context),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
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

  String comment = '';

  bool _busy = false;

  Future<void> onRejectTap() async {
    if (_busy) return; // กันกดซ้ำ
    _busy = true;
    Dia_log1(context);
    try {
      // 1) โหลดลายเซ็นผู้อนุมัติ
      final respSig = await read_AdminSignature();
      if (respSig == null || respSig.statusCode != 200) {
        _toast('โหลดข้อมูลลายเซ็นไม่สำเร็จ');
        return;
      }

      final sigJson = jsonDecode(respSig.body);
      if (sigJson is! Map || sigJson['data'] is! Map) {
        _toast('รูปแบบข้อมูลลายเซ็นไม่ถูกต้อง');
        return;
      }
      final sigData = sigJson['data'] as Map;
      final profileId = sigData['profile_uuid']?.toString();
      final profileName = sigData['profile']?.toString();
      final sigUuid = sigData['signature_uuid']?.toString();
      final positionName = sigData['position_name']?.toString();
      //print(profileId);
      //print(sigUuid);

      if (profileId == null || sigUuid == null) {
        _toast('ข้อมูลผู้ลงนามไม่ครบ');
        return;
      }
      Future.delayed(const Duration(seconds: 1), () async {
        // 2) โหลด Reviews Flow
        final respFlow =
            await read_GC_ReviewsFlowUuid(UuidRequest: '$requestUuid');
        if (respFlow == null || respFlow.statusCode != 200) {
          _toast('โหลดข้อมูลการอนุมัติไม่สำเร็จ');
          return;
        }

        final flowJson = jsonDecode(respFlow.body);
        if (flowJson is! Map || flowJson['data'] is! Map) {
          _toast('รูปแบบข้อมูลการอนุมัติไม่ถูกต้อง');
          return;
        }
        final data = flowJson['data'] as Map;
        final requests =
            (data['request'] is Map) ? data['request'] as Map : const {};
        final triggeredUuid = data['triggered_approval_uuid']?.toString();
        final reqUuid = requests['uuid']?.toString();

        if (triggeredUuid == null || reqUuid == null) {
          _toast('ข้อมูลคำขอไม่ครบ');
          return;
        }

        // 3) เรียก API Reject
        final ok = await POST_Reject(
          requestUuid: reqUuid,
          flowUid: triggeredUuid,
          profileUuid: profileId,
          signUuid: sigUuid,
          comMent: '$comment',
        );

        if (ok == null) {
          _toast('ยกเลิกคำขอไม่สำเร็จ (ไม่มีการตอบสนอง)');
          return;
        }
        if (ok.statusCode == 200 || ok.statusCode == 201) {
          // 4) นำทางกลับหน้าหลัก (เช็ค mounted ให้ครบ)
          if (!mounted) return;

          final prefs = await SharedPreferences.getInstance();
          final routePref = prefs.getString('route'); // ถ้าจะใช้จริง

          // ใช้ post-frame เพื่อลดโอกาสชน build ขณะ pop/push
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => AdminScafScreen(route: 'ใบอนุญาต'),
              ),
              (r) => false,
            );
          });
        } else {
          final okJson = jsonDecode(ok.body);
          Dialog_error(context, '${okJson['message']}');
          return;
        }
      });
    } catch (e, st) {
      //debug//print('ReviewsFlowUuid error: $e\n$st');
      _toast('พบข้อผิดพลาด โปรดลองอีกครั้ง');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showQRUploadDialog() {
    final expiry =
        DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch;
    // Base URL from current window
    final baseUrl = (html.window.location.origin ?? "") +
        (html.window.location.pathname ?? "");
    final qrUrl =
        '$baseUrl#/mobile_upload?request_uuid=${requestUuid ?? ""}&expiry=$expiry';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text('อัพโหลดเอกสารผ่านมือถือ', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('สแกน QR Code เพื่อเลือกไฟล์หรือถ่ายรูปจากมือถือ'),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 250,
              child: QrImageView(
                data: qrUrl,
                version: QrVersions.auto,
                size: 250.0,
              ),
            ),
            const SizedBox(height: 10),
            const Text('QR Code จะหมดอายุใน 10 นาที',
                style: TextStyle(color: Colors.red, fontSize: 12)),
            const SizedBox(height: 10),
            const Text(
                'เมื่ออัพโหลดเสร็จแล้ว ให้กดปุ่ม "รีเฟรชข้อมูล" ด้านล่าง',
                style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              loadClientReviewsUuid();
            },
            child: const Text('รีเฟรชข้อมูล'),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    final sm = ScaffoldMessenger.maybeOf(context);
    sm?.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<Null> Cancel_showDialog() async {
    List<Map<String, dynamic>> data_user_cancel = [
      // {
      //   "ser": "1",
      //   "title": "วันที่ตรวจสอบ",
      //   "detail": "04-05-2025",
      // },
      {
        "ser": "1",
        "title": "เหตุผลที่ปฏิเสธ",
        "detail": "",
      },
      // {
      //   "ser": "3",
      //   "title": "ชื่อผู้ตรวจสอบ",
      //   "detail": "นางสาวเชียงราย พะเยา",
      // },
    ];
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
                // stream: Stream.periodic(const Duration(seconds: 0)),
                builder: (context, snapshot) {
              return AlertDialog(
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
                      for (int index = 0;
                          index < data_user_cancel.length;
                          index++)
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SizedBox(
                            width: 300,
                            // height: 80,
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
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 4, 4, 4),
                                  child: Container(
                                    height: 60,
                                    child: TextFormField(
                                      // scrollPadding: const EdgeInsets.all(1.0),
                                      autofocus: true,
                                      readOnly: false,
                                      // focusNode: myFocusNode,
                                      textAlign: TextAlign.left,
                                      keyboardType: TextInputType.number,
                                      maxLines: 3,

                                      initialValue:
                                          '${data_user_cancel[index]["detail"]}',
                                      onChanged: (value) {
                                        setState(() {
                                          comment = value.toString().trim();
                                        });
                                      },

                                      cursorColor: Colors.green,
                                      decoration: InputDecoration(
                                          fillColor:
                                              Colors.white.withOpacity(0.3),
                                          filled: true,
                                          // prefixIcon: const Icon(
                                          //     Icons
                                          //         .electrical_services,
                                          //     color: Colors.red),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6)),
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          // labelText: 'เลขมิเตอร์',
                                          labelStyle: const TextStyle(
                                            color: ManageScreen_Color
                                                .Colors_Text2_,
                                            // fontWeight:
                                            //     FontWeight.bold,
                                            fontFamily: Font_.Fonts_T,
                                          )),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.deny(
                                            RegExp("[' ']")),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: Column(
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
                                                bottomRight:
                                                    Radius.circular(10)),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 0)),
                      builder: (context, snapshot) {
                        return Container(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 200,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                        (comment == '' ||
                                                Pincontroller.text !=
                                                    randomString.toString())
                                            ? Colors.grey
                                            : Colors.black,
                                        // Colors.black,
                                      ),
                                    ),
                                    onPressed: (comment == '')
                                        ? null
                                        : () async {
                                            onRejectTap();
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Translate
                                          .TranslateAndSet_TextAutoSize(
                                              'ยืนยัน',
                                              ChaoAreaScreen_Color
                                                  .Colors_Text3_,
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
                      })
                ],
              );
            }));
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
            height: (index + 1 == data_person.length || index == 0) ? null : 50,
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
                      keyboardType: TextInputType.multiline,
                      showCursor: false,
                      readOnly: true,
                      controller: _controllers_person[index],
                      minLines: (index == 0)
                          ? 1
                          : (index + 1 == data_person.length)
                              ? 3
                              : 1,
                      maxLines: (index == 0)
                          ? 2
                          : (index + 1 == data_person.length)
                              ? 3
                              : 1,
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
            height: (data_shop[shop].ser.toString() == '1') ? 150 : 50,
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
                        child: Column(
                          children: [
                            Row(
                              children: [
                                for (int shop_sub = 0;
                                    shop_sub <
                                        data_shop[shop].detailsub.length - 1;
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
                                        controller:
                                            _controllers_shop_sub[shop_sub],
                                        maxLines: 1,
                                        // style: TextStyle(
                                        //     overflow: TextOverflow.ellipsis),
                                        // initialValue:
                                        //     '${shop_sub["detail"]}',
                                        onFieldSubmitted: (value) async {},

                                        decoration: InputDecoration(
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
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
                                      ),
                                    ),
                                  )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                for (int shop_sub = 2;
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
                                        controller:
                                            _controllers_shop_sub[shop_sub],
                                        maxLines: 1,
                                        // style: TextStyle(
                                        //     overflow: TextOverflow.ellipsis),
                                        // initialValue:
                                        //     '${shop_sub["detail"]}',
                                        onFieldSubmitted: (value) async {},

                                        decoration: InputDecoration(
                                            fillColor:
                                                Colors.white.withOpacity(0.3),
                                            filled: true,
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6)),
                                              borderSide: BorderSide(
                                                width: 1,
                                                color: Colors.black,
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
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
                                      ),
                                    ),
                                  )
                              ],
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
                            style: TextStyle(overflow: TextOverflow.ellipsis),
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
            height: 50,
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
                      padding: const EdgeInsets.all(6.0),
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

  List<RequiredDocument> docs = [];
  Widget Doc_Data(BuildContext context) {
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final date = DateTime.parse(dateStr);
        return '${DateFormat('dd-MM').format(date)}-${date.year}';
      } catch (e) {
        //print('❌ Invalid date format: $dateStr');
        return '';
      }
    }

    String getDisplayText(RequiredDocument doc, Map<String, dynamic> titleDoc) {
      String displayText = '';

      switch (titleDoc["ser"].toString()) {
        case '1':
          displayText = doc.document.nameTh ?? '';
          break;
        case '2':
          displayText = formatDate(doc.attachment?.uploadedAt);
          break;
        case '3':
          displayText = doc.attachment?.uuid ?? '';
          break;
        case '4':
          displayText = doc.attachment?.statusLabel ?? '';
          break;
        default:
          displayText = formatDate(doc.attachment?.reviewedAt);
          break;
      }

      return displayText;
    }

    String getDisplayText1(
        Submitteddocuments doc, Map<String, dynamic> titleDoc) {
      String displayText = '';

      switch (titleDoc["ser"].toString()) {
        case '1':
          displayText = doc.document.nameTh ?? '';
          break;
        case '2':
          displayText = formatDate(doc.attachment?.uploadedAt);
          break;
        case '3':
          displayText = doc.attachment?.uuid ?? '';
          break;
        case '4':
          displayText = doc.attachment?.statusLabel == 'รอตรวจสอบ'
              ? 'ผ่าน'
              : ''; //doc.attachment?.statusLabel ?? '';
          break;
        default:
          displayText = formatDate(doc.attachment?.reviewedAt);
          break;
      }

      return displayText;
    }

    String getDisplayTextReceipt(
        ReceiptDocuments receipt, Map<String, dynamic> titleDoc) {
      String displayText = '';

      switch (titleDoc["ser"].toString()) {
        case '1':
          displayText = receipt.document!.nameTh ?? '';
          break;
        case '2':
          displayText = formatDate(receipt.attachment?.uploadedAt);
          break;
        case '3':
          displayText = receipt.attachment?.uuid ?? '';
          break;
        case '4':
          displayText =
              // displayText = receipt.attachment?.statusLabel != '' ? 'ผ่าน' : '';

              receipt.attachment?.statusLabel ?? '';
          break;
        default:
          displayText = formatDate(receipt.attachment?.reviewedAt);
          break;
      }

      return displayText;
    }

    if (reviewDetail.isEmpty) {
      return SizedBox(height: 100, child: Widget_Loading(context));
    }

    // docs = reviewDetail.first.requiredDocs;
    final currentDocs = reviewDetail.first.requiredDocs
        .where((doc) => doc.document != null)
        .toList();
    return SizedBox(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                          'ฟอร์มตรวจสอบเอกสาร',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: PeopleChaoScreen_Color.Colors_Text2_,
                              fontFamily: Font_.Fonts_T),
                        ),
                        Container(
                          color: Colors.brown[200],
                          child: Row(children: [
                            for (var title_doc in submitteddoc_checklist)
                              Expanded(
                                flex:
                                    title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                                child: Container(
                                  padding: const EdgeInsets.all(2.0),
                                  child: AutoSizeText(
                                    minFontSize: 12,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    '${title_doc["title"]}',
                                    textAlign:
                                        title_doc["title"] == 'ชื่อเอกสาร'
                                            ? TextAlign.left
                                            : TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: PeopleChaoScreen_Color
                                            .Colors_Text2_,
                                        fontFamily: Font_.Fonts_T),
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  if (reviewDetail.first.submitteddocuments.isEmpty)
                    SizedBox(height: 100, child: Widget_Loading(context))
                  else
                    Column(
                      children:
                          reviewDetail.first.submitteddocuments.map((doc) {
                        return Row(
                          children:
                              submitteddoc_checklist.map<Widget>((title_doc) {
                            if (title_doc["title"] == 'ไฟล์เอกสาร') {
                              final hasFile =
                                  doc.attachment?.fileName?.isNotEmpty ?? false;

                              return Expanded(
                                flex:
                                    title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lime.shade800,
                                    ),
                                    onPressed: () async {
                                      final attachment = doc.attachment;

                                      final attUuid = attachment?.uuid;
                                      final doccu = doc.document;
                                      final resultx = await Navigator.of(
                                              context,
                                              rootNavigator: true)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            PreviewPdfgenchecklist_CMM2(
                                          // doc: 'pdf',
                                          title: 'แบบฟอร์มตรวจสอบเอกสาร',
                                          docs: currentDocs,
                                          zn: _controllers_shop_sub[1].text,
                                          ln: _controllers_shop_sub[2].text,
                                          Request_Uuid: reviewDetail
                                              .first.newRequest.requestUuid,
                                          code: doccu.code,
                                          id: doccu.id,
                                          uuid: attUuid,
                                          viewver: widget.viewver,
                                        ),
                                      ));

                                      // ตรวจสอบค่าที่กลับมา
                                      if (resultx != null &&
                                          resultx['message'] != null) {
                                        await Dialog_success(
                                            context, '${resultx['message']}');
                                        loadClientReviewsUuid();
                                      } else {
                                        //print(
                                        //  'ตรวจสอบค่าที่กลับมา ${resultx['message']}');
                                      }
                                    },
                                    // : null,
                                    child: Text(
                                      'เรียกดู',
                                      style: TextStyle(
                                        color:
                                            CustomerScreen_Color.Colors_Text3_,
                                        fontSize: 12,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                flex:
                                    title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    getDisplayText1(doc, title_doc),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign:
                                        title_doc["title"] == 'ชื่อเอกสาร'
                                            ? TextAlign.left
                                            : TextAlign.center,
                                    style: TextStyle(
                                      color: CustomerScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
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
                    'เอกสารแนบ',
                    // 'เอกสารแนบ (${docs.length} เอกสาร)',
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
                          flex: title_doc["title"] == 'ชื่อเอกสาร' ? 2 : 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              '${title_doc["title"]}',
                              textAlign: title_doc["title"] == 'ชื่อเอกสาร'
                                  ? TextAlign.left
                                  : TextAlign.center,
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
            Divider(),
            if (currentDocs.isEmpty)
              SizedBox(height: 100, child: Widget_Loading(context))
            else
              Column(
                children: currentDocs.asMap().entries.map((row) {
                  final i = row.key; // index ของแถว (0-based)
                  final doc = row.value; // ข้อมูล doc ของแถวนั้น

                  return Row(
                    children: data_title_doc.asMap().entries.map<Widget>((col) {
                      final titleDoc = col.value;
                      final title = (titleDoc["title"] ?? '').toString();
                      final isNameCol = title == 'ชื่อเอกสาร';
                      final isFileCol = title == 'ไฟล์เอกสาร';
                      final flex = isNameCol ? 2 : 1;

                      if (isFileCol) {
                        final hasFile =
                            doc.attachment?.fileName?.isNotEmpty ?? false;

                        return Expanded(
                          flex: flex,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: hasFile
                                    ? Colors.lime.shade800
                                    : Colors.black,
                              ),
                              onPressed: hasFile
                                  ? () async {
                                      final att = doc.attachment!;
                                      final doccu = doc.document!;
                                      final resultx = await Navigator.of(
                                              context,
                                              rootNavigator: true)
                                          .push(
                                        MaterialPageRoute(
                                          builder: (_) => PreviewPdf_ordit_CMM2(
                                            id: att.id.toString(),
                                            uuid: att.uuid,
                                            Request_Uuid: att.requestUuid,
                                            code:
                                                att.clientDocumentId.toString(),
                                            file_path: att.filePath,
                                            file_type: att.fileType,
                                            title: doccu.nameTh ?? '',
                                            file_typeOpen: 'ReviewsFile',
                                            uploaded_At: att.uploadedAt,
                                            statusReviewer:
                                                att.status.toString(),
                                            data_title_doc: data_title_doc,
                                            docs: currentDocs,
                                            payment: reviewDetail,
                                            viewver: widget.viewver,
                                          ),
                                        ),
                                      );
                                      await loadClientReviewsUuid();

                                      // if (resultx is Map &&
                                      //     resultx['message'] != null) {
                                      //   await loadClientReviewsUuid();
                                      // }
                                    }
                                  : null,
                              child: const Text(
                                'เรียกดู',
                                style: TextStyle(
                                  color: CustomerScreen_Color.Colors_Text3_,
                                  fontSize: 12,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        final rawText = getDisplayText(doc, titleDoc);
                        final displayText =
                            isNameCol ? '${i + 1}. $rawText' : rawText;

                        return Expanded(
                          flex: flex,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              displayText,
                              overflow: TextOverflow.ellipsis,
                              textAlign:
                                  isNameCol ? TextAlign.left : TextAlign.center,
                              style: const TextStyle(
                                color: CustomerScreen_Color.Colors_Text2_,
                                fontFamily: Font_.Fonts_T,
                              ),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  );
                }).toList(),
              )
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
                    (reviewDetail.first.receiptDocuments.isEmpty)
                        ? 'รายการชำระ'
                        : 'รายการชำระ',
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
                          flex: '${title_receipt["title"]}' == 'ชื่อเอกสาร'
                              ? 2
                              : 1,
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            child: AutoSizeText(
                              minFontSize: 12,
                              maxFontSize: 16,
                              maxLines: 1,
                              '${title_receipt["title"]}',
                              textAlign: title_receipt["title"] == 'ชื่อเอกสาร'
                                  ? TextAlign.left
                                  : TextAlign.center,
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
            // (attachments.isEmpty)
            //     ? Widget_Loading(context)
            //     :

            (reviewDetail.first.receiptDocuments.isEmpty)
                ? const Center(
                    child: Text(
                      'ไม่พบข้อมูล',
                      style: TextStyle(
                        color: PeopleChaoScreen_Color.Colors_Text2_,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  )
                : SizedBox(
                    child: Column(
                      children: reviewDetail.first.receiptDocuments.map((doc) {
                        return Row(
                          children:
                              data_title_receipt.map<Widget>((title_receipt) {
                            final hasFile =
                                doc.attachment?.fileName?.isNotEmpty ?? false;
                            if (title_receipt["title"] == 'ไฟล์เอกสาร') {
                              return Expanded(
                                flex: title_receipt["title"] == 'ชื่อเอกสาร'
                                    ? 2
                                    : 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hasFile
                                          ? Colors.lime.shade800
                                          : (widget.viewver == true)
                                              ? Colors.grey.shade800
                                              : Colors.blue.shade800,
                                    ),
                                    onPressed: hasFile
                                        ? () async {
                                            final attachment = reviewDetail
                                                .first
                                                .receiptDocuments
                                                .first
                                                .attachment;

                                            final attUuid =
                                                attachment?.uuid ?? null;
                                            final doccu = reviewDetail
                                                .first
                                                .receiptDocuments
                                                .first
                                                .document;
                                            final resultx = await Navigator.of(
                                                    context,
                                                    rootNavigator: true)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  PreviewPdfgencreceiptView_CMM(
                                                      // doc: 'pdf',
                                                      title:
                                                          'แบบฟอร์มรายการชำระ',
                                                      // docs: docs,
                                                      // zn: _controllers_shop_sub[
                                                      //         1]
                                                      //     .text,
                                                      // ln: _controllers_shop_sub[
                                                      //         2]
                                                      //     .text,
                                                      reviewDetail:
                                                          reviewDetail,
                                                      //         .receiptDocuments,
                                                      // code: doccu
                                                      //     .code,
                                                      // id: doccu
                                                      //     .id,
                                                      uuid: attUuid),
                                            ));

                                            // ตรวจสอบค่าที่กลับมา
                                            if (resultx['message'] != null) {
                                              //print(
                                              //     'ตรวจสอบค่าที่กลับมา ${resultx['message']}');
                                              // Loading_Data_config();
                                              loadClientReviewsUuid();
                                            }
                                          }
                                        : (widget.viewver == true)
                                            ? null
                                            : () async {
                                                final result =
                                                    await Navigator.of(context,
                                                            rootNavigator: true)
                                                        .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      RegencreceiptView_CMM(
                                                    uuid_Request:
                                                        requestUuid.toString(),
                                                  ),
                                                ));
                                                if (result == true) {
                                                  loadClientReviewsUuid();
                                                }
                                              },
                                    child: Text(
                                      hasFile ? 'เรียกดู' : 'สร้างเอกสาร',
                                      textAlign:
                                          title_receipt["title"] == 'ชื่อเอกสาร'
                                              ? TextAlign.left
                                              : TextAlign.center,
                                      style: TextStyle(
                                        color:
                                            CustomerScreen_Color.Colors_Text3_,
                                        fontSize: 12,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Expanded(
                                flex: title_receipt["title"] == 'ชื่อเอกสาร'
                                    ? 2
                                    : 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    getDisplayTextReceipt(
                                        reviewDetail
                                            .first.receiptDocuments.first,
                                        title_receipt),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign:
                                        title_receipt["title"] == 'ชื่อเอกสาร'
                                            ? TextAlign.left
                                            : TextAlign.center,
                                    style: TextStyle(
                                      color: CustomerScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),

            SizedBox(
              height: 10,
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
                    topRight: Radius.circular(15)),
              ),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'ข้อมูลเอกสารเพิ่มเติม',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.brown[200],
              child: Row(children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'ชื่อเอกสาร',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'เล่มที่',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'เลขที่',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    child: AutoSizeText(
                      minFontSize: 12,
                      maxFontSize: 16,
                      maxLines: 1,
                      'วันที่',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T),
                    ),
                  ),
                ),
                if (widget.viewver == false) SizedBox(width: 42),
              ]),
            ),
            _buildDocRow(
              docName: 'บันทึกข้อความ',
              numberController: _noteNumberController,
              dateController: _noteDateController,
              payType: '',
            ),
            _buildDocRow(
              docName: 'ใบเสร็จค่าใบอนุญาตฯ',
              numberController: _feeNumberController,
              dateController: _feeDateController,
              payType: 'fee',
              bookNoController: _feeBookNoController,
            ),
            _buildDocRow(
              docName: 'ใบเสร็จค่าปรับ',
              numberController: _fineNumberController,
              dateController: _fineDateController,
              payType: 'fine',
              bookNoController: _fineBookNoController,
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
                readOnly: true,
                keyboardType: TextInputType.number,
                // controller: Formbecause_,
                initialValue: (reviewDetail.first.newRequest == null)
                    ? ''
                    : '${reviewDetail.first.newRequest.comment}',
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
      SizedBox(
        height: 20,
      ),
      if (widget.viewver == false && widget.plugin == false)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 243, 131, 130),
                  ),
                ),
                onPressed: () async {
                  generateRandomString();
                  Cancel_showDialog();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Translate.TranslateAndSet_TextAutoSize(
                      'ปฏิเสธคำร้อง',
                      // 'ปฏิเสธคำร้อง/แจ้งการแก้ไข',
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
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    (isOpenApproved == false) ? Colors.grey : Colors.black,
                  ),
                ),
                onPressed: (isOpenApproved == false)
                    ? null
                    : () async {
                        setState(() {
                          ser_tap = 2;
                        });
                      },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Translate.TranslateAndSet_TextAutoSize(
                      'ยืนยัน/ถัดไป',
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
          ],
        )
    ]));
  }

  Widget _buildDocRow({
    required String docName,
    required TextEditingController numberController,
    required TextEditingController dateController,
    required String payType,
    TextEditingController? bookNoController,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                docName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CustomerScreen_Color.Colors_Text2_,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                bookNoController == null || bookNoController.text.isEmpty
                    ? '-'
                    : bookNoController.text,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CustomerScreen_Color.Colors_Text2_,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                numberController.text.isEmpty ? '-' : numberController.text,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CustomerScreen_Color.Colors_Text2_,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                dateController.text.isEmpty ? '-' : dateController.text,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CustomerScreen_Color.Colors_Text2_,
                  fontFamily: Font_.Fonts_T,
                ),
              ),
            ),
          ),
          if (widget.viewver == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 10, 2),
              child: IconButton(
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Icon(
                  Icons.edit_note,
                  color: Colors.blue.shade700,
                ),
                onPressed: () async {
                  print('🟢 Edit tapped: docName=$docName, payType=$payType');
                  final tempNumber =
                      TextEditingController(text: numberController.text);
                  final tempDate =
                      TextEditingController(text: dateController.text);
                  final tempBookNo = bookNoController != null
                      ? TextEditingController(text: bookNoController.text)
                      : null;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                              width: 400,
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.edit_note,
                                          color: Colors.black),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'แก้ไข/เพิ่ม เอกสาร$docName',
                                          style: TextStyle(
                                            fontFamily: Font_.Fonts_T,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Divider(height: 30),
                                  if (tempBookNo != null) ...[
                                    Text(
                                      'เล่มที่',
                                      style: TextStyle(
                                        fontFamily: Font_.Fonts_T,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    TextField(
                                      controller: tempBookNo,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        hintText: 'ตัวอย่าง: 01',
                                        prefixIcon: Icon(Icons.book, size: 20),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                  Text(
                                    'เลขที่',
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: tempNumber,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: 'ตัวอย่าง: 0001',
                                      prefixIcon: Icon(Icons.numbers, size: 20),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'วันที่',
                                    style: TextStyle(
                                      fontFamily: Font_.Fonts_T,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  TextField(
                                    controller: tempDate,
                                    readOnly: true,
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                        locale: const Locale('th', 'TH'),
                                      );
                                      if (pickedDate != null) {
                                        setDialogState(() {
                                          tempDate.text =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(pickedDate);
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      hintText: 'เลือกวันที่',
                                      prefixIcon:
                                          Icon(Icons.calendar_today, size: 20),
                                      suffixIcon: Icon(Icons.arrow_drop_down),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('ยกเลิก',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontFamily: Font_.Fonts_T)),
                                      ),
                                      SizedBox(width: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24, vertical: 12),
                                        ),
                                        onPressed: () async {
                                          print(
                                              '═══════════════════════════════');
                                          print(
                                              '💾 [SAVE] docName=$docName, payType="$payType"');
                                          print(
                                              '   tempNumber.text="${tempNumber.text}"');
                                          print(
                                              '   tempDate.text="${tempDate.text}"');
                                          print(
                                              '   tempBookNo.text="${tempBookNo?.text}"');
                                          print(
                                              '   requestUuid="$requestUuid"');
                                          print(
                                              '   reviewDetail.length=${reviewDetail.length}');
                                          String apiDate = '';
                                          try {
                                            if (tempDate.text.isNotEmpty) {
                                              DateTime parsed =
                                                  DateFormat('dd-MM-yyyy')
                                                      .parse(tempDate.text);
                                              apiDate = DateFormat('yyyy-MM-dd')
                                                  .format(parsed);
                                            }
                                          } catch (e) {
                                            print(
                                                '⚠️ Date parse error: $e — fallback to raw');
                                            apiDate = tempDate.text;
                                          }
                                          print('   apiDate="$apiDate"');
                                          bool success = false;
                                          if (payType.isEmpty) {
                                            print(
                                                '➡️ [BRANCH] Post_ReviewsAddon (note)');
                                            print(
                                                '   requestUuid=${requestUuid.toString()}');
                                            print(
                                                '   bookNo=${tempNumber.text}');
                                            print('   bookDate=$apiDate');
                                            final resp =
                                                await Post_ReviewsAddon(
                                              requestUuid:
                                                  requestUuid.toString(),
                                              bookNo: tempNumber.text,
                                              bookDate: apiDate,
                                            );
                                            print(
                                                '⬅️ Post_ReviewsAddon resp=${resp?.statusCode} body=${resp?.body}');
                                            success = resp != null &&
                                                (resp.statusCode == 200 ||
                                                    resp.statusCode == 201);
                                          } else {
                                            final paymentUuid =
                                                reviewDetail.isNotEmpty
                                                    ? reviewDetail
                                                        .first.payment.uuid
                                                    : null;
                                            print(
                                                '➡️ [BRANCH] Post_GC_payment_addon (payType=$payType)');
                                            print(
                                                '   paymentUuid=$paymentUuid');
                                            if (paymentUuid == null ||
                                                paymentUuid.isEmpty) {
                                              print(
                                                  '❌ paymentUuid empty — abort');
                                              Navigator.pop(context);
                                              return;
                                            }
                                            print(
                                                '   nobill=${tempNumber.text}');
                                            print(
                                                '   docnobill=${tempBookNo?.text ?? ''}');
                                            print('   billdate=$apiDate');
                                            print('   payType=$payType');
                                            final resp =
                                                await Post_GC_payment_addon(
                                              uuidPayment: paymentUuid,
                                              nobill: tempNumber.text,
                                              docnobill: tempBookNo?.text ?? '',
                                              billdate: apiDate,
                                              payType: payType,
                                            );
                                            print(
                                                '⬅️ Post_GC_payment_addon resp=${resp?.statusCode} body=${resp?.body}');
                                            success = resp != null &&
                                                (resp.statusCode == 200 ||
                                                    resp.statusCode == 201);
                                          }
                                          print('✅ success=$success');
                                          print(
                                              '═══════════════════════════════');
                                          if (success) {
                                            setState(() {
                                              numberController.text =
                                                  tempNumber.text;
                                              dateController.text =
                                                  tempDate.text;
                                              if (tempBookNo != null) {
                                                bookNoController?.text =
                                                    tempBookNo.text;
                                              }
                                            });
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text('บันทึก',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: Font_.Fonts_T,
                                                fontWeight: FontWeight.bold)),
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
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pluginUploadSignal.removeListener(_onPluginUpload);
    _noteNumberController.dispose();
    _noteDateController.dispose();
    _feeNumberController.dispose();
    _feeDateController.dispose();
    _feeBookNoController.dispose();
    _fineNumberController.dispose();
    _fineDateController.dispose();
    _fineBookNoController.dispose();
    super.dispose();
  }
}
