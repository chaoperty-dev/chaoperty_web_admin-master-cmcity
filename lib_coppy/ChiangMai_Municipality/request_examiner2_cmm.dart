import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/Enum.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/FormatDate.dart';
import 'package:fl_pin_code/pin_code.dart';
import 'package:fl_pin_code/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../AdminScaffold/AdminScaffold.dart';
import '../Responsive/responsive.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Model/ApprovalsFlowCheckUp_Model.dart';
import 'Model/Dataconfig_Model.dart';
import 'Model/Person&Shop_Model.dart';
import 'Model/ReviewUuid_Model.dart';
import 'cignaturepad_cmm.dart';
import 'request_examiner1_cmm.dart';
import 'unity/API_admin_reject.dart';
import 'unity/API_admin_signature.dart';
import 'unity/API_approvals_roles&checkup.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/API_requests_reviewsflow.dart';
import 'unity/SecurePrefs_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'unity/show_dialog_cmm.dart';

class RequestExaminer2_CMM extends StatefulWidget {
  final bool viewver;
  final bool plugin;
  const RequestExaminer2_CMM(
      {super.key, required this.viewver, required this.plugin});

  @override
  State<RequestExaminer2_CMM> createState() => _RequestExaminer2_CMMState();
}

class _RequestExaminer2_CMMState extends State<RequestExaminer2_CMM> {
  int ser_tap = 1, MobieTap = 0;
  String? requestUuid, FlowUuid;
//-------------------------------------->
  // ตัวแปร debounce
  Timer? _debounce;
  // เพิ่มตัวแปรเพื่อเก็บ sortColumnIndex และค่าเริ่มต้น
  int sortColumnIndex = 0;
  // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
  bool isLoading = false;
  bool isLoading_main = false;
  //-------------------------------------->
  List<TextEditingController> _controllers_person = [];
  List<TextEditingController> _controllers_shop = [];
  List<TextEditingController> _controllers_shop_sub = [];
  List<TextEditingController> _controllers_cid = [];
  //-------------------------------------->
  List<ApprovalsFlowCheckUpModel> checkupModel = [];

  List data_cid = [];
  ////////////--------------------->
  List<PersonFieldModel> data_person = data_persons;
  List<ShopFieldModel> data_shop = data_shops;
  ////////////--------------------->
  List<ReviewDetail> reviewDetail = [];
  bool isOpenApproved = false;
  final ValueNotifier<int> _dataUpdateNotifier = ValueNotifier<int>(0);
  ////////////--------------------->
  @override
  void initState() {
    super.initState();

    // เริ่มด้วย controller ว่างๆ ที่ไม่อ้าง index 0 แบบไม่เช็ค
    _controllers_person = List.generate(
      data_person.length,
      (i) => TextEditingController(text: data_person[i].detail),
    );

    _controllers_shop = List.generate(
      data_shop.length,
      (i) => TextEditingController(text: data_shop[i].detail),
    );

    _controllers_shop_sub = (data_shop.isNotEmpty)
        ? List.generate(
            data_shop[0].detailsub.length,
            (i) =>
                TextEditingController(text: data_shop[0].detailsub[i].detail),
          )
        : <TextEditingController>[];

    _controllers_cid = List.generate(
      data_cid.length,
      (i) => TextEditingController(text: data_cid[i]['detail']),
    );

    // โหลดข้อมูล
    Loading_ApprovalsCheckUp();
  }

  void _onChangedDebounced(void Function() action,
      {Duration duration = const Duration(milliseconds: 400)}) {
    _debounce?.cancel();
    _debounce = Timer(duration, action);
  }

  @override
  void dispose() {
    _debounce?.cancel(); // ✅ ล้าง timer
    for (final c in _controllers_person) {
      c.dispose();
    }
    for (final c in _controllers_shop) {
      c.dispose();
    }
    for (final c in _controllers_shop_sub) {
      c.dispose();
    }
    for (final c in _controllers_cid) {
      c.dispose();
    }
    _dataUpdateNotifier.dispose(); // ✅ เพิ่ม
    super.dispose();
  }

  Future<void> Loading_ApprovalsCheckUp() async {
    setState(() {
      isLoading = true;
      isLoading_main = true;
    });

    try {
      await loadApprovalsCheckUp();
      await loadClientReviewsUuid();
      await Future.delayed(
          const Duration(milliseconds: 600)); // พอให้ UI นุ่มนวล

      if (!mounted) return;
      setState(() {
        isLoading = false;
        isLoading_main = false;
      });
    } catch (e, st) {
      //   debug//print('❌ Loading_ApprovalsCheckUp error: $e');
      //  debug//printStack(stackTrace: st);
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isLoading_main = false;
      });
    }
  }

  Future<void> loadApprovalsCheckUp() async {
    final results = await Future.wait([
      SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest),
      SecurePrefs.getDecrypted(SecurePrefsType.flowUuid),
    ]);

    final String? value = results[0];
    final String? valueFlowUuid = results[1];

    if (value == null || value.isEmpty) {
      // debug//print('❌ ไม่มี UuidRequest: ยกเลิกโหลด');
      if (mounted)
        setState(() {
          checkupModel.clear();
        });
      return;
    }

    if (mounted) {
      setState(() {
        requestUuid = value;
        FlowUuid = valueFlowUuid;
        checkupModel.clear();
      });
    }

    final response =
        await read_GC_ApprovalsCheckUp(value); // ✅ ส่งค่าที่ non-null
    if (response?.statusCode == 200) {
      final jsonMap = json.decode(response!.body);
      if (jsonMap['data'] is Map<String, dynamic>) {
        final model = ApprovalsFlowCheckUpModel.fromJson(jsonMap['data']);
        if (mounted) setState(() => checkupModel = [model]);
        // debug//print('✅ โหลด 1 รายการเสร็จสมบูรณ์');
      } else {
        // debug//print('❌ "data" ไม่ใช่ Map');
      }
    } else {
      // debug//print('❌ ไม่สามารถโหลดข้อมูลได้');
    }
  }

  Future<void> loadClientReviewsUuid() async {
    if (mounted) setState(() => reviewDetail.clear());

    final results = await Future.wait([
      SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest),
      SecurePrefs.getDecrypted(SecurePrefsType.flowUuid),
    ]);

    final String? value = results[0];
    final String? valueFlowUuid = results[1];

    if (value == null || value.isEmpty) {
      // debug//print('❌ ไม่มี UuidRequest: ยกเลิกโหลด reviews');
      return;
    }

    if (mounted) {
      setState(() {
        requestUuid = value;
        FlowUuid = valueFlowUuid;
      });
    }

    final response = await read_GC_ReviewsUuid(value);
    if (response?.statusCode == 200) {
      try {
        final result = json.decode(response!.body);
        final reviewDetailModel = ReviewDetail.fromJson(result['data']);
        final bool isOpen = result['is_open_approved'] == true;
        print('read_GC_ReviewsUuid result: ${result}');
        if (mounted) {
          setState(() {
            isOpenApproved = isOpen;
            reviewDetail.add(reviewDetailModel);
          });
        }
      } catch (e) {
      } finally {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) await Set_data();
      }
    } else {
      //debug//print('❌ error: read_GC_ReviewsUuid');
    }
  }

  Future<void> Set_data() async {
    // debug//print('🔄 เริ่มโหลดข้อมูล: uuid=$requestUuid, flow=$FlowUuid');
    try {
      await AddForm_requests_uuid(0);
    } catch (e, st) {
      //debug//print('🧾 ข้อความ: $e');
      //debug//print('📍 StackTrace:\n$st');
    }
  }

  Future<void> AddForm_requests_uuid(int index) async {
    if (reviewDetail.isEmpty || index >= reviewDetail.length) return;
    final d = reviewDetail[index];

    String _s(String? v) => v ?? '';
    String _num(num? v) => v?.toString() ?? '';

    // ระวังฟิลด์ซ้อนที่อาจเป็น null (json)
    final cj = d.client.json;

    final person = <String>[
      _s(d.client.cname), // 0 ชื่อ-นามสกุล*
      _s(d.client.tax), // 1 เลขบัตร*
      _num(d.client.age), // 2 อายุ*
      _s(d.client.national), // 3 สัญชาติ*

      _s(d.client.addr1), // 4 บ้านเลขที่*  (หรือบ้านเลขที่จริง)
      _s(cj.moo), // 5 หมู่ที่
      _s(cj.soi), // 6 ตรอก/ซอย
      _s(cj.road), // 7 ถนน*
      _s(cj.tambon), // 8 ตำบล/แขวง*
      _s(cj.amphoe), // 9 อำเภอ/เขต*
      _s(cj.province), // 10 จังหวัด*

      _s(d.client.tel), // 11 เบอร์โทร*
      '', // 12 หมายเหตุ
    ];
    // final person = <String>[
    //   _s(d.client.cname),
    //   _s(d.client.tax),
    //   _num(d.client.age),
    //   _s(d.client.national),
    //   _s(cj.soi),
    //   _s(cj.road),
    //   _s(cj.tambon),
    //   _s(cj.amphoe),
    //   _s(cj.province),
    //   _s(d.client.tel),
    //   _s(d.client.addr1),
    // ];

    final shop = <String>[
      '-',
      _num(double.parse(d.newRequest.qty)),
      _s(d.client.stype),
      _s(d.client.scname),
    ];

    final shopSub = <String>[
      _s(d.newRequest.subzone),
      _s(d.newRequest.zn),
      _s(d.newRequest.ln),
    ];

    final details = <String>[
      _s(d.newRequest.sdate),
      _s(d.newRequest.ldate),
      _s(d.newRequest.type),
      '1',
    ];

    final cid = <String>[
      _s(d.newRequest.sdate),
      _s(d.newRequest.ldate),
      _s(d.newRequest.type),
      _num(d.newRequest.leaseTermMonths),
    ];

    await _updateCustomerData(person, shop, shopSub, details, cid);
  }

  ///////////----------------------->
  void _syncControllersLength() {
    void _syncList<T>(List<TextEditingController> ctrls, int wantLen,
        String Function(int) textAt) {
      // ลด
      while (ctrls.length > wantLen) {
        ctrls.removeLast().dispose();
      }
      // เพิ่ม
      while (ctrls.length < wantLen) {
        ctrls.add(TextEditingController(text: textAt(ctrls.length)));
      }
    }

    _syncList(
        _controllers_person, data_person.length, (i) => data_person[i].detail);
    _syncList(_controllers_shop, data_shop.length, (i) => data_shop[i].detail);
    _syncList(_controllers_cid, data_cid.length,
        (i) => (data_cid[i]['detail'] ?? '').toString());

    final subLen = (data_shop.isNotEmpty) ? data_shop[0].detailsub.length : 0;
    _syncList(
        _controllers_shop_sub, subLen, (i) => data_shop[0].detailsub[i].detail);
  }

  ///////////----------------------->
  Future<void> Loading_Data_config() async {
    final cid = await getContractInfo(); // รอโหลดให้เสร็จก่อน

    if (!mounted) return;

    setState(() {
      // ✅ เก็บครบทุก field เสมอ (ไม่กรองที่นี่)
      data_cid = cid.map<Map<String, dynamic>>((e) {
        final m = Map<String, dynamic>.from(e as Map);

        // ✅ กัน null และ normalize key สำคัญ
        m['ser'] = (m['ser'] ?? '').toString();
        m['title'] = (m['title'] ?? '').toString();
        m['detail'] = (m['detail'] ?? '').toString();

        return m;
      }).toList();
    });
  }

  Future<void> _updateCustomerData(
    List<dynamic> personData,
    List<String> shopData,
    List<String> shopSubData,
    List<String> detailsData,
    List<String> cidData,
  ) async {
    await Loading_Data_config();

    // ✅ แก้ personData - cast ให้ถูก type
    if (personData.isNotEmpty) {
      for (int i = 0; i < personData.length && i < data_person.length; i++) {
        final value = personData[i];
        print('personData[$i] : $value');

        // ✅ Cast to String ให้ปลอดภัย
        data_person[i].detail = (value?.toString() ?? '').trim();
      }
    }

    // ✅ แก้ shopData
    if (shopData.isNotEmpty) {
      for (int i = 0; i < shopData.length && i < data_shop.length; i++) {
        data_shop[i].detail = (shopData[i]?.toString() ?? '').trim();
      }
    }

    // ✅ แก้ shopSubData
    if (shopSubData.isNotEmpty && data_shop.isNotEmpty) {
      for (int i = 0;
          i < shopSubData.length && i < data_shop[0].detailsub.length;
          i++) {
        data_shop[0].detailsub[i].detail =
            (shopSubData[i]?.toString() ?? '').trim();
      }
    }

    // ✅ แก้ cidData - ensure list มี element พอ
    if (cidData.isNotEmpty) {
      // Resize list ถ้าจำเป็น
      while (data_cid.length < cidData.length) {
        data_cid.add({'detail': '', 'status': 'pending'});
      }

      for (int i = 0; i < cidData.length && i < data_cid.length; i++) {
        final value = cidData[i];
        print('cidData[$i] : $value');

        // ✅ ตรวจสอบ type ก่อนแทน
        if (data_cid[i] is Map<String, dynamic>) {
          data_cid[i]['detail'] = (value?.toString() ?? '').trim();
        } else {
          print('❌ Error: data_cid[$i] is not a Map');
        }
      }
    }

    // ✅ sync ความยาว controller
    _syncControllersLength();

    // ✅ อัพเดต controller text จาก data_person
    for (int i = 0;
        i < _controllers_person.length && i < data_person.length;
        i++) {
      if (i == 4) {
        // ✅ รวม address fields
        final address = [
          data_person[4].detail ?? '',
          // data_person[5].detail ?? '',
          // data_person[6].detail ?? '',
          // data_person[7].detail ?? '',
          // data_person[8].detail ?? '',
          // data_person[9].detail ?? '',
          // data_person[10].detail ?? '',
        ].where((e) => e.isNotEmpty).join(' ');

        _controllers_person[4].text = address;
      } else {
        _controllers_person[i].text = data_person[i].detail ?? '';
      }
    }

    // ✅ อัพเดต controller shop
    for (int i = 0; i < _controllers_shop.length && i < data_shop.length; i++) {
      _controllers_shop[i].text = data_shop[i].detail ?? '';
    }

    // ✅ อัพเดต controller shop_sub
    if (data_shop.isNotEmpty && data_shop[0].detailsub.isNotEmpty) {
      for (int i = 0;
          i < _controllers_shop_sub.length && i < data_shop[0].detailsub.length;
          i++) {
        _controllers_shop_sub[i].text = data_shop[0].detailsub[i].detail ?? '';
      }
    }

    // ✅ อัพเดต controller cid
    for (int i = 0; i < _controllers_cid.length && i < data_cid.length; i++) {
      final cidDetail = data_cid[i]['detail'];
      if (cidDetail != null) {
        _controllers_cid[i].text = cidDetail.toString().trim();
      }
    }

    // ✅ Rebuild UI
    if (mounted) {
      setState(() {
        print('✅ Data updated and UI rebuilt');
      });
    }
  }

  ////////////--------------------->

  @override
  Widget build(BuildContext context) {
    if (ser_tap == 2) {
      return SignaturePad_CMM(
        requestUuid: requestUuid ?? '',
        triggeredUuid: FlowUuid ?? '',
      );
    }

    // Helper logic for attachments count (preserved from original logic)
    final List<ApproveDocuments> docs = (checkupModel.isNotEmpty
        ? (checkupModel.first.approveDocuments ?? const <ApproveDocuments>[])
        : const <ApproveDocuments>[]);

    final int totalAttachments = docs.fold<int>(0, (sum, d) {
      final hasList = (d.approveAttachments?.isNotEmpty ?? false);
      final hasSingle =
          d.approveAttachment != null && !d.approveAttachment.isNull;
      final count =
          hasList ? d.approveAttachments!.length : (hasSingle ? 1 : 0);
      return sum + count;
    });

    return Scaffold(
      backgroundColor: AppbackgroundColor.Abg_Colors,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.viewver == false && widget.plugin == false)
              _buildHeader(context),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sidebar (Visible on Desktop)
                    if (Responsive.isDesktop(context))
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppbackgroundColor.Sub_Abg_Colors,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: SingleChildScrollView(
                              child: _buildSidebarDesktop(context)),
                        ),
                      ),

                    if (Responsive.isDesktop(context))
                      const SizedBox(width: 20),

                    // Main Content
                    Expanded(
                      flex: 2,
                      child: Container(
                        // height: 450,
                        decoration: BoxDecoration(
                          // color: AppbackgroundColor.Sub_Abg_Colors,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (Responsive.isMobile(context)) ...[
                                // const SizedBox(height: 4),
                                Container(
                                  // decoration: BoxDecoration(
                                  //   color: AppbackgroundColor.Sub_Abg_Colors,
                                  //   // borderRadius: BorderRadius.circular(10),
                                  // ),
                                  // padding: const EdgeInsets.all(12),
                                  child: _buildSidebar(context),
                                ),
                                _buildReviewerAttachments(context),
                              ] else if (Responsive.isTablet(context)) ...[
                                const SizedBox(height: 4),
                                IntrinsicHeight(
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: _buildSidebar(context),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 3,
                                          child: _buildReviewerAttachments(
                                              context),
                                        ),
                                      ]),
                                ),
                              ] else ...[
                                _buildReviewerAttachments(context),
                              ],

                              const SizedBox(height: 30),
                              _buildExaminerAttachments(context),

                              const SizedBox(height: 40),

                              // Action Buttons
                              if (widget.viewver == false &&
                                  widget.plugin == false)
                                Responsive.isMobile(context)
                                    ? Column(
                                        children: [
                                          _buildRejectButton(context),
                                          const SizedBox(height: 20),
                                          _buildConfirmButton(context,
                                              totalAttachments:
                                                  totalAttachments),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildRejectButton(context),
                                          const SizedBox(height: 20),
                                          _buildConfirmButton(context,
                                              totalAttachments:
                                                  totalAttachments),
                                        ],
                                      ),

                              // Summary info
                              const SizedBox(height: 20),
                              // Row(
                              //   children: [
                              //     const Icon(Icons.info_outline,
                              //         size: 20, color: Colors.grey),
                              //     const SizedBox(width: 8),
                              //     Expanded(
                              //       child: AutoSizeText(
                              //         'โปรดแนบรูปเอกสารหลักฐานการตรวจสอบข้อเท็จจริงก่อนดำเนินการยืนยันเอกสารถูกต้อง',
                              //         minFontSize: 12,
                              //         maxFontSize: 14,
                              //         maxLines: 2,
                              //         style: TextStyle(
                              //           color: Colors.grey.shade600,
                              //           fontFamily: Font_.Fonts_T,
                              //         ),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ],
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
    );
  }

  Widget _buildRejectButton(BuildContext context) {
    return SizedBox(
      width: Responsive.isMobile(context) ? double.infinity : 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF38382),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          generateRandomString();
          Cancel_showDialog();
        },
        child: Translate.TranslateAndSet_TextAutoSize(
          'ปฏิเสธคำขอ',
          ChaoAreaScreen_Color.Colors_Text2_,
          TextAlign.center,
          null,
          FontWeight_.Fonts_T,
          12,
          18,
          1,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context,
      {required int totalAttachments}) {
    return SizedBox(
      width: Responsive.isMobile(context) ? double.infinity : 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: totalAttachments > 0 ? Colors.black : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          if (totalAttachments > 0) {
            setState(() {
              ser_tap = 2;
            });
          } else {
            Dialog_error(context, 'กรุณาตรวจสอบเอกสารให้ถูกต้องครบถ้วน');
          }
        },
        child: Translate.TranslateAndSet_TextAutoSize(
          'บันทึก',
          ChaoAreaScreen_Color.Colors_Text3_,
          TextAlign.center,
          null,
          FontWeight_.Fonts_T,
          12,
          18,
          1,
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
        if (data_person[index].ser.toString() != '6' &&
            data_person[index].ser.toString() != '7' &&
            data_person[index].ser.toString() != '8' &&
            data_person[index].ser.toString() != '9' &&
            data_person[index].ser.toString() != '10' &&
            data_person[index].ser.toString() != '11' &&
            data_person[index].ser.toString() != '13')
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: SizedBox(
              height: (index == 4 || index == 0) ? null : 50,
              // height: (index == 4) ? null : 40,
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
                        (data_person[index].title.toString() == 'บ้านเลขที่')
                            ? 'ที่อยู่'
                            : data_person[index].title?.replaceAll('*', '') ??
                                '',
                        // '${data_person[index].title}',
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
                          controller: _controllers_person[index],
                          readOnly: true,
                          showCursor: false,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          minLines: 1,
                          maxLines: 3,
                          decoration: InputDecoration(
                            isDense: true,
                            alignLabelWithHint:
                                true, // ✅ label อยู่บน ไม่กินพื้นที่แปลก ๆ
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.3),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1),
                            ),
                          ),
                        )

                        //  TextFormField(
                        //   controller: _controllers_person[index],
                        //   readOnly: true,
                        //   showCursor: false,
                        //   keyboardType: TextInputType.multiline,
                        //   textInputAction: TextInputAction.newline,
                        //   maxLines: null, // ✅ ให้ wrap ได้ไม่จำกัด
                        //   minLines: 1, // ✅ เริ่มต้น 1 บรรทัด

                        //   // maxLines: null,
                        //   // minLines: 1,
                        //   // validator:
                        //   //     (value) {
                        //   //   if (value ==
                        //   //           null ||
                        //   //       value
                        //   //           .isEmpty) {
                        //   //     return '';
                        //   //   }
                        //   //   return null;
                        //   // },
                        //   // initialValue:
                        //   //     '${person["detail"]}',
                        //   onFieldSubmitted: (value) async {},

                        //   decoration: InputDecoration(
                        //       isDense: true,
                        //       fillColor: Colors.white.withOpacity(0.3),
                        //       filled: true,
                        //       focusedBorder: const OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(6)),
                        //         borderSide: BorderSide(
                        //           width: 1,
                        //           color: Colors.black,
                        //         ),
                        //       ),
                        //       enabledBorder: OutlineInputBorder(
                        //         borderRadius:
                        //             BorderRadius.all(Radius.circular(6)),
                        //         borderSide: BorderSide(
                        //           width: 1,
                        //           color: Colors.grey,
                        //           // color: (_controllers_person[index].text == null || _controllers_person[index].text.toString() == '')
                        //           //     ? Colors.red
                        //           //     : Colors.grey,
                        //         ),
                        //       ),
                        //       // labelText: 'ระบุชื่อร้านค้า',
                        //       labelStyle: const TextStyle(
                        //           fontSize: 14,
                        //           color: Colors.black54,
                        //           fontFamily: Font_.Fonts_T)),
                        // ),
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
            height: (data_shop[shop].ser.toString() == '1') ? 150 : 40,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: (data_shop[shop].ser.toString() == '1')
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int shop_sub = 0;
                                shop_sub < data_shop[shop].detailsub.length - 1;
                                shop_sub++)
                              Container(
                                padding: const EdgeInsets.all(2.0),
                                child: AutoSizeText(
                                  minFontSize: 12,
                                  maxFontSize: 16,
                                  maxLines: 1,
                                  '${data_shop[shop].detailsub[shop_sub].titlesub}',
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              child: AutoSizeText(
                                minFontSize: 12,
                                maxFontSize: 16,
                                maxLines: 1,
                                'ล็อกที่',
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: PeopleChaoScreen_Color.Colors_Text2_,
                                    fontFamily: Font_.Fonts_T),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          padding: const EdgeInsets.all(2.0),
                          child: AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 16,
                            maxLines: 1,
                            '${data_shop[shop].title}',
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
                                        data_shop[shop].detailsub.length - 2;
                                    shop_sub++)
                                  // for (var shop_sub
                                  //     in data_shop[shop]
                                  //         [
                                  //         "detailsub"])
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: 40,
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
                                                fontSize: 14,
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
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                for (int shop_sub = 1;
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
                                      height: 40,
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
                                                fontSize: 14,
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
                                      height: 40,
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
                                                fontSize: 12,
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
    final listToShow = Responsive.isDesktop(context)
        ? data_cid
        : data_cid.where((e) {
            final ser = (e['ser'] ?? '').toString();
            return ser != '3' && ser != '4';
          }).toList();

    return SizedBox(
      child: Column(
        children: [
          for (var cid in listToShow)
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
                          (cid['title'] ?? '-').toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Builder(builder: (_) {
                          final ser = (cid['ser'] ?? '').toString();
                          final detail = (cid['detail'] ?? '').toString();

                          final text = (ser == '3' || ser == '4')
                              ? detail
                              : formatDate(detail, type: DateFormatType.dmy);

                          return AutoSizeText(
                            minFontSize: 12,
                            maxFontSize: 16,
                            maxLines: 1,
                            text,
                            overflow: TextOverflow.ellipsis,
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppbackgroundColor.TiTile_Box,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: (!Responsive.isDesktop(context))
          ? Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: (Responsive.isMobile(context)) ? 80 : 150,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        MaterialPageRoute materialPageRoute = MaterialPageRoute(
                            builder: (BuildContext context) => AdminScafScreen(
                                  route: 'ใบอนุญาต',
                                  route_getdata: "",
                                ));
                        Navigator.pushAndRemoveUntil(
                            context, materialPageRoute, (route) => false);
                      },
                      child: (Responsive.isMobile(context))
                          ? Center(
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: ChaoAreaScreen_Color.Colors_Text3_,
                              ),
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.arrow_back_ios,
                                  color: ChaoAreaScreen_Color.Colors_Text3_,
                                ),
                                Expanded(
                                  child: Translate.TranslateAndSet_TextAutoSize(
                                    ' ย้อนกลับ ',
                                    ChaoAreaScreen_Color.Colors_Text3_,
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
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Translate.TranslateAndSetText(
                      'รายละเอียดคำขอใบอนุญาตฯ ',
                      ChaoAreaScreen_Color.Colors_Text1_,
                      TextAlign.left,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 40,
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onPressed: () {
                        int tapSer = 0;

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            final size = MediaQuery.of(context).size;

                            final dialogWidth =
                                size.width < 900 ? size.width * 0.95 : 1000.0;
                            final dialogHeight = size.height * 0.88;

                            return StatefulBuilder(
                              builder: (context, setStateSB) {
                                return Dialog(
                                  backgroundColor:
                                      AppbackgroundColor.Sub_Abg_Colors,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: SizedBox(
                                    width: dialogWidth,
                                    height: dialogHeight,
                                    child: Column(
                                      children: [
                                        // Header
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey.shade50
                                                .withOpacity(0.5),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: [
                                                    InkWell(
                                                      onTap: () => setStateSB(
                                                          () => tapSer = 0),
                                                      child: Container(
                                                        width: 170,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: tapSer == 0
                                                              ? Colors.black
                                                              : Colors.black54,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: const Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons.list,
                                                              color:
                                                                  Colors.white,
                                                              size: 22,
                                                            ),
                                                            SizedBox(width: 6),
                                                            Expanded(
                                                              child: Text(
                                                                'ข้อมูลผู้ทำรายการ',
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // InkWell(
                                                    //   onTap: () => setStateSB(
                                                    //       () => tapSer = 1),
                                                    //   child: Container(
                                                    //     width: 170,
                                                    //     padding:
                                                    //         const EdgeInsets
                                                    //             .all(6),
                                                    //     decoration:
                                                    //         BoxDecoration(
                                                    //       color: tapSer == 1
                                                    //           ? Colors.black
                                                    //           : Colors.black54,
                                                    //       borderRadius:
                                                    //           BorderRadius
                                                    //               .circular(6),
                                                    //       border: Border.all(
                                                    //         color: Colors.grey,
                                                    //         width: 1,
                                                    //       ),
                                                    //     ),
                                                    //     child: const Row(
                                                    //       mainAxisSize:
                                                    //           MainAxisSize.min,
                                                    //       children: [
                                                    //         Icon(
                                                    //           Icons
                                                    //               .safety_check,
                                                    //           color:
                                                    //               Colors.white,
                                                    //           size: 22,
                                                    //         ),
                                                    //         SizedBox(width: 6),
                                                    //         Expanded(
                                                    //           child: Text(
                                                    //             'ข้อมูลข้อเท็จจริง',
                                                    //             maxLines: 1,
                                                    //             overflow:
                                                    //                 TextOverflow
                                                    //                     .ellipsis,
                                                    //             style:
                                                    //                 TextStyle(
                                                    //               fontSize: 15,
                                                    //               fontWeight:
                                                    //                   FontWeight
                                                    //                       .bold,
                                                    //               color: Colors
                                                    //                   .white,
                                                    //             ),
                                                    //           ),
                                                    //         ),
                                                    //       ],
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.redAccent,
                                                  size: 26,
                                                ),
                                                tooltip: 'ปิดหน้าต่าง',
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Body
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              bottom: Radius.circular(16),
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              color: Colors.white
                                                  .withOpacity(0.98),
                                              child: tapSer == 0
                                                  ? const RequestExaminer1_CMM(
                                                      viewver: true,
                                                      plugin: false,
                                                    )
                                                  : const RequestExaminer2_CMM(
                                                      viewver: true,
                                                      plugin: false,
                                                    ),
                                            ),
                                          ),
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
                      child: Translate.TranslateAndSet_TextAutoSize(
                        'ข้อมูลเพิ่มเติม',
                        Colors.black,
                        TextAlign.center,
                        null,
                        FontWeight_.Fonts_T,
                        12,
                        14,
                        1,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Translate.TranslateAndSetText(
                      'รายละเอียดคำขอใบอนุญาตฯ ',
                      ChaoAreaScreen_Color.Colors_Text1_,
                      TextAlign.left,
                      FontWeight.bold,
                      FontWeight_.Fonts_T,
                      14,
                      2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 150,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        MaterialPageRoute materialPageRoute = MaterialPageRoute(
                            builder: (BuildContext context) => AdminScafScreen(
                                  route: 'ใบอนุญาต',
                                  route_getdata: "",
                                ));
                        Navigator.pushAndRemoveUntil(
                            context, materialPageRoute, (route) => false);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            color: ChaoAreaScreen_Color.Colors_Text3_,
                          ),
                          Expanded(
                            child: Translate.TranslateAndSet_TextAutoSize(
                              ' ย้อนกลับ ',
                              ChaoAreaScreen_Color.Colors_Text3_,
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
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSidebarDesktop(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            StreamBuilder(
              stream:
                  Stream.periodic(const Duration(milliseconds: 50), (i) => i),
              builder: (context, snapshot) {
                double elapsed = (snapshot.data ?? 0) * 0.05;
                return Text(
                  'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                  style: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSidebarSectionTitle(Icons.person, 'ข้อมูลผู้เช่า'),
        Form_Person(context),
        const SizedBox(height: 20),
        _buildSidebarSectionTitle(Icons.store, 'ข้อมูลร้านค้า'),
        Form_Shop(context),
        const SizedBox(height: 20),
        _buildSidebarSectionTitle(Icons.receipt_long, 'ข้อมูลสัญญา'),
        Form_Cid(context),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            StreamBuilder(
              stream:
                  Stream.periodic(const Duration(milliseconds: 50), (i) => i),
              builder: (context, snapshot) {
                double elapsed = (snapshot.data ?? 0) * 0.05;
                return Text(
                  'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                  style: const TextStyle(
                    color: PeopleChaoScreen_Color.Colors_Text2_,
                    fontFamily: Font_.Fonts_T,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    if (Responsive.isMobile(context) || Responsive.isTablet(context)) {
      return ValueListenableBuilder<int>(
        valueListenable: _dataUpdateNotifier,
        builder: (context, _, __) {
          return _buildCompactInfoCard(context);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSidebarSectionTitle(Icons.person, 'ข้อมูลบุคคล'),
        Form_Person(context),
        const SizedBox(height: 20),
        _buildSidebarSectionTitle(Icons.store, 'ข้อมูลร้านค้า'),
        Form_Shop(context),
        const SizedBox(height: 20),
        _buildSidebarSectionTitle(Icons.receipt_long, 'ข้อมูลสัญญา'),
        Form_Cid(context),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCompactInfoCard(BuildContext context) {
    final name =
        _controllers_person.isNotEmpty ? _controllers_person[0].text : "-";
    final area = _controllers_shop_sub.isNotEmpty
        ? _controllers_shop_sub[0].text
        : "-"; // subzone
    final zone = _controllers_shop_sub.length > 1
        ? _controllers_shop_sub[1].text
        : "-"; // zn
    final lock = _controllers_shop_sub.length > 2
        ? _controllers_shop_sub[2].text
        : "-"; // ln
    final productType =
        _controllers_shop.length > 2 ? _controllers_shop[2].text : "-"; // stype
    final shopName = _controllers_shop.length > 3
        ? _controllers_shop[3].text
        : "-"; // scname

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE5E4C7),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: const Text(
              'ข้อมูลผู้เช่า',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: Font_.Fonts_T,
                color: PeopleChaoScreen_Color.Colors_Text2_,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildCompactRow('ชื่อ-นามสกุล', name, isLong: true),
                const SizedBox(height: 10),
                _buildCompactRow('บริเวณ', area, isLong: true),
                const SizedBox(height: 10),
                if (Responsive.isMobile(context)) ...[
                  _buildCompactRow('โซน', zone),
                  const SizedBox(height: 10),
                  _buildCompactRow('ล็อค', lock),
                ] else
                  Row(
                    children: [
                      Expanded(child: _buildCompactRow('โซน', zone)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildCompactRow('ล็อค', lock)),
                    ],
                  ),
                const SizedBox(height: 10),
                _buildCompactRow('ประเภทสินค้า', productType, isLong: true),
                const SizedBox(height: 10),
                _buildCompactRow('ชื่อร้าน', shopName, isLong: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactRow(String label, String value, {bool isLong = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: Font_.Fonts_T,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: CustomerScreen_Color.Colors_Text1_),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: CustomerScreen_Color.Colors_Text1_,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: FontWeight_.Fonts_T,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExaminerAttachments(BuildContext context) {
    if (checkupModel.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppbackgroundColor.Sub_Abg_Colors,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildAttachmentHeader(
              'รูปภาพหลักฐานการตรวจสอบข้อเท็จจริง', Colors.brown[200]!,
              trailing: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showHistoryDialog(context),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(Icons.history, color: Colors.black, size: 18),
                  ),
                ),
              )),
          const SizedBox(height: 10),
          if (isLoading)
            _buildLoadingSpinner()
          else if (checkupModel.first.approveDocuments!.isEmpty)
            _buildEmptyMessage()
          else if (Responsive.isMobile(context))
            Column(
              children: [
                for (var doc in checkupModel.first.approveDocuments!)
                  _buildAttachmentCard(
                    title: doc.nameTh ?? "-",
                    timestamp: doc.approveAttachment?.createdAt,
                    onPreview: () => _showPreviewDialog(
                        context,
                        doc.nameTh ?? "-",
                        doc.approveAttachment?.uuid,
                        doc.approveAttachment?.fileType,
                        isReviewer: false),
                    previewContent: _buildThumbnailPreview(
                        doc.approveAttachment?.uuid,
                        doc.approveAttachment?.fileType,
                        isReviewer: false),
                    onUpload: widget.viewver
                        ? null
                        : () async {
                            final id = doc.id;
                            if (id != null) {
                              final response = await pickAndUpload_CheckUp(
                                  requestUuid ?? '', id);
                              if (response == null) {
                                Dialog_error(context, 'ไม่มีไฟล์ถูกอัปโหลด');
                                return;
                              }
                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                final Map<String, dynamic> result =
                                    json.decode(response.body);
                                final data = result['data'];
                                setState(() {
                                  doc.approveAttachment =
                                      ApproveAttachment.fromJson(data);
                                });
                                Dialog_success(context, 'อัปโหลดสำเร็จ');
                                await loadApprovalsCheckUp();
                              } else {
                                Dialog_error(context, 'การอัปโหลดล้มเหลว');
                              }
                            } else {
                              Dialog_error(context,
                                  'ไม่พบ ID สำหรับ ${doc.nameTh ?? "-"}');
                            }
                          },
                  ),
              ],
            )
          else
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              }),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var doc in checkupModel.first.approveDocuments!)
                      _buildAttachmentCard(
                        title: doc.nameTh ?? "-",
                        timestamp: doc.approveAttachment?.createdAt,
                        onPreview: () => _showPreviewDialog(
                            context,
                            doc.nameTh ?? "-",
                            doc.approveAttachment?.uuid,
                            doc.approveAttachment?.fileType,
                            isReviewer: false),
                        previewContent: _buildThumbnailPreview(
                            doc.approveAttachment?.uuid,
                            doc.approveAttachment?.fileType,
                            isReviewer: false),
                        onUpload: widget.viewver
                            ? null
                            : () async {
                                final id = doc.id;
                                if (id != null) {
                                  final response = await pickAndUpload_CheckUp(
                                      requestUuid ?? '', id);
                                  if (response == null) {
                                    Dialog_error(
                                        context, 'ไม่มีไฟล์ถูกอัปโหลด');
                                    return;
                                  }
                                  if (response.statusCode == 200 ||
                                      response.statusCode == 201) {
                                    final Map<String, dynamic> result =
                                        json.decode(response.body);
                                    final data = result['data'];
                                    setState(() {
                                      doc.approveAttachment =
                                          ApproveAttachment.fromJson(data);
                                    });
                                    Dialog_success(context, 'อัปโหลดสำเร็จ');
                                    await loadApprovalsCheckUp();
                                  } else {
                                    Dialog_error(context, 'การอัปโหลดล้มเหลว');
                                  }
                                } else {
                                  Dialog_error(context,
                                      'ไม่พบ ID สำหรับ ${doc.nameTh ?? "-"}');
                                }
                              },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: Responsive.isMobile(context)
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          shape: Responsive.isMobile(context)
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                )
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
          backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
          titlePadding: EdgeInsets.zero,
          title: Column(
            children: [
              Row(
                children: [
                  if (Responsive.isMobile(context))
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            size: 30, color: Colors.black),
                      ),
                    ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'ประวัติการอัปโหลดภาพ',
                        style: TextStyle(
                          fontSize: 18,
                          color: PeopleChaoScreen_Color.Colors_Text2_,
                          fontFamily: Font_.Fonts_T,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!Responsive.isMobile(context))
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_outlined,
                            size: 30, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            height: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.height
                : MediaQuery.of(context).size.height * 0.8,
            width: Responsive.isMobile(context)
                ? MediaQuery.of(context).size.width
                : 400,
            child: ListView(
              children: [
                if (isLoading)
                  _buildLoadingSpinner()
                else if (checkupModel.first.approveDocuments?.isEmpty ?? true)
                  _buildEmptyMessage()
                else
                  ...checkupModel.first.approveDocuments!.map((type) {
                    if (type.approveAttachments?.isEmpty ?? true) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            type.nameTh ?? '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: Font_.Fonts_T,
                            ),
                          ),
                        ),
                        ...type.approveAttachments!.map(
                          (history) => ListTile(
                            title: Text(
                              history.caption ?? '-',
                              style: const TextStyle(
                                  fontSize: 14, fontFamily: Font_.Fonts_T),
                            ),
                            subtitle: Text(
                              history.createdAt == null
                                  ? '-'
                                  : DateFormat('dd-MM-yyyy HH:mm:ss').format(
                                      DateTime.parse(history.createdAt!)),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility_outlined),
                              onPressed: () => _showPreviewDialog(
                                context,
                                history.caption ?? '-',
                                history.uuid,
                                null,
                                isReviewer: false,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // void _showHistoryDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setState) => AlertDialog(
  //         shape: (Responsive.isMobile(context))
  //             ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(0))
  //             : RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
  //         titlePadding: EdgeInsets.zero,
  //         title: Column(
  //           children: [
  //             Align(
  //               alignment: Alignment.topRight,
  //               child: IconButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 icon: const Icon(Icons.highlight_off,
  //                     size: 30, color: Colors.red),
  //               ),
  //             ),
  //             const Text(
  //               'ประวัติการอัปโหลดภาพ',
  //               style: TextStyle(
  //                   fontSize: 18,
  //                   color: PeopleChaoScreen_Color.Colors_Text2_,
  //                   fontFamily: Font_.Fonts_T,
  //                   fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //         content: SizedBox(
  //           height: (Responsive.isMobile(context))
  //               ? MediaQuery.of(context).size.height
  //               : MediaQuery.of(context).size.height * 0.8,
  //           width: (Responsive.isMobile(context))
  //               ? MediaQuery.of(context).size.width
  //               : 400,
  //           child: ListView(
  //             children: [
  //               if (isLoading)
  //                 _buildLoadingSpinner()
  //               else if (checkupModel.first.approveDocuments?.isEmpty ?? true)
  //                 _buildEmptyMessage()
  //               else
  //                 ...checkupModel.first.approveDocuments!.map((type) {
  //                   if (type.approveAttachments?.isEmpty ?? true)
  //                     return const SizedBox.shrink();
  //                   return Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Padding(
  //                         padding: const EdgeInsets.symmetric(vertical: 8),
  //                         child: Text(type.nameTh ?? '-',
  //                             style: const TextStyle(
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.bold,
  //                                 fontFamily: Font_.Fonts_T)),
  //                       ),
  //                       ...type.approveAttachments!.map((history) => ListTile(
  //                             title: Text(history.caption ?? '-',
  //                                 style: const TextStyle(
  //                                     fontSize: 14, fontFamily: Font_.Fonts_T)),
  //                             subtitle: Text(
  //                               history.createdAt == null
  //                                   ? '-'
  //                                   : DateFormat('dd-MM-yyyy HH:mm:ss').format(
  //                                       DateTime.parse(history.createdAt!)),
  //                               style: const TextStyle(
  //                                   fontSize: 12, color: Colors.grey),
  //                             ),
  //                             trailing: IconButton(
  //                               icon: const Icon(Icons.visibility_outlined),
  //                               onPressed: () => _showPreviewDialog(context,
  //                                   history.caption ?? '-', history.uuid, null,
  //                                   isReviewer: false),
  //                             ),
  //                           )),
  //                       const Divider(),
  //                     ],
  //                   );
  //                 }).toList(),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildReviewerAttachments(BuildContext context) {
    if (checkupModel.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: (Responsive.isDesktop(context))
          ? EdgeInsets.fromLTRB(0, 0, 0, 0)
          : EdgeInsets.fromLTRB(0, 9, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppbackgroundColor.Sub_Abg_Colors,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _buildAttachmentHeader('รูปภาพหลักฐานจากผู้เช่า/ผู้ค้า',
                AppbackgroundColor.TiTile_Colors.withOpacity(0.8)),
            const SizedBox(height: 10),
            if (isLoading)
              _buildLoadingSpinner()
            else if (checkupModel.first.requestDocument!.isEmpty)
              _buildEmptyMessage()
            else if (Responsive.isMobile(context) ||
                (Responsive.isTablet(context)))
              Column(
                children: [
                  for (var doc in checkupModel.first.requestDocument!)
                    _buildAttachmentCard(
                      title: doc.nameTh ?? "-",
                      timestamp: doc.requestAttachments?.createdAt,
                      onPreview: () => _showPreviewDialog(
                          context,
                          doc.nameTh ?? "-",
                          doc.requestAttachments?.uuid,
                          doc.requestAttachments?.fileType,
                          isReviewer: true),
                      previewContent: _buildThumbnailPreview(
                          doc.requestAttachments?.uuid,
                          doc.requestAttachments?.fileType,
                          isReviewer: true),
                    ),
                ],
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var doc in checkupModel.first.requestDocument!)
                      _buildAttachmentCard(
                        title: doc.nameTh ?? "-",
                        timestamp: doc.requestAttachments?.createdAt,
                        onPreview: () => _showPreviewDialog(
                            context,
                            doc.nameTh ?? "-",
                            doc.requestAttachments?.uuid,
                            doc.requestAttachments?.fileType,
                            isReviewer: true),
                        previewContent: _buildThumbnailPreview(
                            doc.requestAttachments?.uuid,
                            doc.requestAttachments?.fileType,
                            isReviewer: true),
                      ),
                  ],
                ),
              ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: ConstrainedBox(
            //     constraints: BoxConstraints(
            //         minWidth: MediaQuery.of(context).size.width),
            //     child:
            //         //  Align(
            //         //   alignment: Alignment.center, // ✅ ชิดขวา
            //         // child:
            //         Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       mainAxisSize: MainAxisSize.min, // ✅ Row กว้างเท่าที่จำเป็น
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         for (var doc in checkupModel.first.requestDocument!)
            //           _buildAttachmentCard(
            //             title: doc.nameTh ?? "-",
            //             timestamp: doc.requestAttachments?.createdAt,
            //             onPreview: () => _showPreviewDialog(
            //               context,
            //               doc.nameTh ?? "-",
            //               doc.requestAttachments?.uuid,
            //               doc.requestAttachments?.fileType,
            //               isReviewer: true,
            //             ),
            //             previewContent: _buildThumbnailPreview(
            //               doc.requestAttachments?.uuid,
            //               doc.requestAttachments?.fileType,
            //               isReviewer: true,
            //             ),
            //           ),
            //       ],
            //     ),
            //     // ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentHeader(String title, Color color, {Widget? trailing}) {
    return Padding(
      padding: (Responsive.isDesktop(context))
          ? EdgeInsets.fromLTRB(0, 0, 0, 0)
          : EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(0),
          ),
          // borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.black,
                      fontFamily: Font_.Fonts_T,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentCard({
    required String title,
    String? timestamp,
    required VoidCallback onPreview,
    required Widget previewContent,
    VoidCallback? onUpload,
  }) {
    final cardWidth = Responsive.isMobile(context) ? double.infinity : 270.0;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        width: cardWidth, // ให้ title/การ์ด/วันที่ อิงความกว้างเดียวกัน
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // title ชิดซ้าย
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                title,
                style: const TextStyle(
                  color: PeopleChaoScreen_Color.Colors_Text2_,
                  fontFamily: Font_.Fonts_T,
                  fontSize: 13,
                ),
              ),
            ),

            // Card Preview
            Container(
              height: 150,
              width: cardWidth,
              decoration: BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    if (timestamp == null && onUpload != null)
                      InkWell(
                        onTap: onUpload,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.system_update_alt_outlined,
                                  size: 30, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                "คลิกหรือกด เพื่อเลือกไฟล์",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "รองรับไฟล์ภาพ JPG หรือ PNG",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                "ขนาดไฟล์สูงสุด: 10MB",
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // ✅ บังคับให้ previewContent ได้ขนาดเต็มกรอบเสมอ
                      Positioned.fill(
                        child: ClipRect(
                          child: SizedBox.expand(
                            child: previewContent,
                          ),
                        ),
                      ),

                      // overlay tap
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(onTap: onPreview),
                        ),
                      ),

                      // upload again button
                      if (onUpload != null)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: SizedBox(
                            height: 30,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black.withOpacity(0.6),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onPressed: onUpload,
                              child: const Text(
                                'อัปโหลดใหม่',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontFamily: Font_.Fonts_T,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Timestamp (center)
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt,
                          color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd-MM-yyyy HH:mm:ss')
                            .format(DateTime.parse(timestamp)),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontFamily: Font_.Fonts_T,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSpinner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          StreamBuilder(
            stream: Stream.periodic(const Duration(milliseconds: 50), (i) => i),
            builder: (context, snapshot) {
              double elapsed = (snapshot.data ?? 0) * 0.05;
              return Text(
                'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.',
                style: const TextStyle(
                    color: Colors.grey, fontFamily: Font_.Fonts_T),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text('ไม่พบข้อมูล',
            style: TextStyle(color: Colors.grey, fontFamily: Font_.Fonts_T)),
      ),
    );
  }

  Widget _buildThumbnailPreview(String? uuid, String? fileType,
      {required bool isReviewer}) {
    if (uuid == null)
      return const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40));
    final isPdf = fileType?.toLowerCase() == 'pdf';

    return FutureBuilder<http.Response?>(
      future: isReviewer
          ? img_ApprovalsRequests(uuid)
          : img_ApprovalsCheckUp(requestUuid, uuid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasData && snapshot.data?.statusCode == 200) {
          if (isPdf) {
            return Container(
              color: Colors.grey.shade100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                  Text('PDF',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }
          return Image.memory(snapshot.data!.bodyBytes,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity);
        }
        return const Center(
            child: Icon(Icons.broken_image, color: Colors.grey));
      },
    );
  }

  void _showPreviewDialog(
      BuildContext context, String title, String? uuid, String? fileType,
      {required bool isReviewer}) {
    if (uuid == null) return;
    Future<ui.Image> _decodeImage(Uint8List bytes) async {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final screen = MediaQuery.of(ctx).size;

        final maxW = screen.width * 0.75;
        final maxH = screen.height * 0.85;

        return FutureBuilder<http.Response?>(
          future: isReviewer
              ? img_ApprovalsRequests(uuid)
              : img_ApprovalsCheckUp(requestUuid, uuid),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!(snap.hasData && snap.data?.statusCode == 200)) {
              return const Center(child: Icon(Icons.broken_image, size: 48));
            }

            final res = snap.data!;
            final bytes = res.bodyBytes;
            final isPdf =
                (res.headers['content-type'] ?? '').contains('application/pdf');

            // ── PDF: ให้เต็มกรอบ/สกรอลได้ ───────────────────────────────
            if (isPdf) {
              return Dialog(
                backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                insetPadding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(Icons.highlight_off,
                              size: 30, color: Colors.red[700]),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            SfPdfViewer.memory(bytes),
                            IgnorePointer(child: _buildWatermarkOverlay()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ── IMAGE: decode ขนาดรูป แล้วทำ Dialog ให้พอดี ───────────────
            return FutureBuilder<ui.Image>(
              future: _decodeImage(bytes),
              builder: (context, imgSnap) {
                if (!imgSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final img = imgSnap.data!;
                final aspect = img.width / img.height; // w/h

                // คำนวณขนาด dialog ให้ "พอดีรูป" ภายใต้ maxW/maxH
                double w = maxW;
                double h = w / aspect;
                if (h > maxH) {
                  h = maxH;
                  w = h * aspect;
                }

                return Dialog(
                  backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  insetPadding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: w,
                    height: h + 70, // + เผื่อ header/title (ปรับได้)
                    child: Column(
                      children: [
                        // header
                        SizedBox(
                          height: 70,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  icon: Icon(Icons.highlight_off,
                                      size: 30, color: Colors.red[700]),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color:
                                          PeopleChaoScreen_Color.Colors_Text2_,
                                      fontFamily: Font_.Fonts_T,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // body (พอดีกับรูปจริง)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(20)),
                            child: Stack(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return InteractiveViewer(
                                      minScale: 1,
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        height: constraints.maxHeight,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.memory(bytes),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IgnorePointer(child: _buildWatermarkOverlay()),
                              ],
                            ),
                          ),
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
    );
  }

  Widget _buildWatermarkOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        List<Widget> watermarks = [];

        for (double y = 0; y < height; y += 200) {
          for (double x = 0; x < width; x += 300) {
            watermarks.add(Positioned(
              left: x,
              top: y,
              child: Transform.rotate(
                angle: -0.4,
                child: Opacity(
                  opacity: 0.08,
                  child: Text(
                    'Chaoperty',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ));
          }
        }

        return Stack(children: watermarks);
      },
    );
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
                                        // for below version 2 use this
                                        // FilteringTextInputFormatter.allow(
                                        //     RegExp(r'[0-9 .]')),
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
      // final profileName = sigData['profile']?.toString();
      final sigUuid = sigData['signature_uuid']?.toString();
      // final positionName = sigData['position_name']?.toString();

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

        // ถ้า POST_Reject ไม่มี bool ให้เช็ก ให้ดูจาก status/throw ของมันแทน
        if (ok == false) {
          _toast('ยกเลิกคำขอไม่สำเร็จ');
          return;
        }
        if (ok!.statusCode == 200 || ok.statusCode == 201) {
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
      _toast('พบข้อผิดพลาด โปรดลองอีกครั้ง');
    } finally {
      _busy = false;
    }
  }
}
