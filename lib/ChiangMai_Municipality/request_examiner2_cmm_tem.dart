// import 'dart:async';
// import 'dart:convert';
// import 'dart:js_interop';
// import 'dart:math';
// import 'dart:ui';
// import 'dart:ui' as ui;
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:chaoperty/ChiangMai_Municipality/unity/Enum.dart';
// import 'package:chaoperty/ChiangMai_Municipality/unity/FormatDate.dart';
// import 'package:fl_pin_code/pin_code.dart';
// import 'package:fl_pin_code/styles.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
// import '../AdminScaffold/AdminScaffold.dart';
// import '../Constant/Myconstant.dart';
// import '../Responsive/responsive.dart';
// import '../Style/Translate.dart';
// import '../Style/colors.dart';
// import 'Model/ApprovalsFlowCheckUp_Model.dart';
// import 'Model/Person&Shop_Model.dart';
// import 'Model/ReviewUuid_Model.dart';
// import 'cignaturepad_cmm.dart';
// import 'unity/API_admin_reject.dart';
// import 'unity/API_admin_signature.dart';
// import 'unity/API_approvals_roles&checkup.dart';
// import 'unity/API_requests_reviews.dart';
// import 'unity/API_requests_reviewsflow.dart';
// import 'unity/SecurePrefs_helper.dart';
// import 'package:http/http.dart' as http;

// import 'unity/show_dialog_cmm.dart';

// class RequestExaminer2_CMM extends StatefulWidget {
//   final bool viewver;
//   const RequestExaminer2_CMM({super.key, required this.viewver});

//   @override
//   State<RequestExaminer2_CMM> createState() => _RequestExaminer2_CMMState();
// }

// class _RequestExaminer2_CMMState extends State<RequestExaminer2_CMM> {
//   int ser_tap = 1;
//   String? requestUuid, FlowUuid;
// //-------------------------------------->
//   // ตัวแปร debounce
//   Timer? _debounce;
//   // เพิ่มตัวแปรเพื่อเก็บ sortColumnIndex และค่าเริ่มต้น
//   int sortColumnIndex = 0;
//   // ตัวแปรที่ใช้ระบุว่าอยู่ในสถานะกำลังโหลดหรือไม่
//   bool isLoading = false;
//   bool isLoading_main = false;
//   //-------------------------------------->
//   List<TextEditingController> _controllers_person = [];
//   List<TextEditingController> _controllers_shop = [];
//   List<TextEditingController> _controllers_shop_sub = [];
//   List<TextEditingController> _controllers_cid = [];
//   //-------------------------------------->
//   List<ApprovalsFlowCheckUpModel> checkupModel = [];

//   List data_cid = [];
//   ////////////--------------------->
//   List<PersonFieldModel> data_person = data_persons;
//   List<ShopFieldModel> data_shop = data_shops;
//   ////////////--------------------->
//   List<ReviewDetail> reviewDetail = [];
//   bool isOpenApproved = false;

//   ////////////--------------------->
//   @override
//   void initState() {
//     super.initState();

//     // เริ่มด้วย controller ว่างๆ ที่ไม่อ้าง index 0 แบบไม่เช็ค
//     _controllers_person = List.generate(
//       data_person.length,
//       (i) => TextEditingController(text: data_person[i].detail ?? ''),
//     );

//     _controllers_shop = List.generate(
//       data_shop.length,
//       (i) => TextEditingController(text: data_shop[i].detail ?? ''),
//     );

//     _controllers_shop_sub = (data_shop.isNotEmpty)
//         ? List.generate(
//             data_shop[0].detailsub.length,
//             (i) => TextEditingController(
//                 text: data_shop[0].detailsub[i].detail ?? ''),
//           )
//         : <TextEditingController>[];

//     _controllers_cid = List.generate(
//       data_cid.length,
//       (i) => TextEditingController(text: data_cid[i]['detail'] ?? ''),
//     );

//     // โหลดข้อมูล
//     Loading_ApprovalsCheckUp();
//   }

//   void _onChangedDebounced(void Function() action,
//       {Duration duration = const Duration(milliseconds: 400)}) {
//     _debounce?.cancel();
//     _debounce = Timer(duration, action);
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel(); // ✅ ล้าง timer
//     for (final c in _controllers_person) {
//       c.dispose();
//     }
//     for (final c in _controllers_shop) {
//       c.dispose();
//     }
//     for (final c in _controllers_shop_sub) {
//       c.dispose();
//     }
//     for (final c in _controllers_cid) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> Loading_ApprovalsCheckUp() async {
//     setState(() {
//       isLoading = true;
//       isLoading_main = true;
//     });

//     try {
//       await loadApprovalsCheckUp();
//       await loadClientReviewsUuid();
//       await Future.delayed(
//           const Duration(milliseconds: 600)); // พอให้ UI นุ่มนวล

//       if (!mounted) return;
//       setState(() {
//         isLoading = false;
//         isLoading_main = false;
//       });
//     } catch (e, st) {
//       //   debug//print('❌ Loading_ApprovalsCheckUp error: $e');
//       //  debug//printStack(stackTrace: st);
//       if (!mounted) return;
//       setState(() {
//         isLoading = false;
//         isLoading_main = false;
//       });
//     }
//   }

//   Future<void> loadApprovalsCheckUp() async {
//     final results = await Future.wait([
//       SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest),
//       SecurePrefs.getDecrypted(SecurePrefsType.flowUuid),
//     ]);

//     final String? value = results[0];
//     final String? valueFlowUuid = results[1];

//     if (value == null || value.isEmpty) {
//       // debug//print('❌ ไม่มี UuidRequest: ยกเลิกโหลด');
//       if (mounted)
//         setState(() {
//           checkupModel.clear();
//         });
//       return;
//     }

//     if (mounted) {
//       setState(() {
//         requestUuid = value;
//         FlowUuid = valueFlowUuid;
//         checkupModel.clear();
//       });
//     }

//     final response =
//         await read_GC_ApprovalsCheckUp(value); // ✅ ส่งค่าที่ non-null
//     if (response?.statusCode == 200) {
//       final jsonMap = json.decode(response!.body);
//       if (jsonMap['data'] is Map<String, dynamic>) {
//         final model = ApprovalsFlowCheckUpModel.fromJson(jsonMap['data']);
//         if (mounted) setState(() => checkupModel = [model]);
//         // debug//print('✅ โหลด 1 รายการเสร็จสมบูรณ์');
//       } else {
//         // debug//print('❌ "data" ไม่ใช่ Map');
//       }
//     } else {
//       // debug//print('❌ ไม่สามารถโหลดข้อมูลได้');
//     }
//   }

//   Future<void> loadClientReviewsUuid() async {
//     if (mounted) setState(() => reviewDetail.clear());

//     final results = await Future.wait([
//       SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest),
//       SecurePrefs.getDecrypted(SecurePrefsType.flowUuid),
//     ]);

//     final String? value = results[0];
//     final String? valueFlowUuid = results[1];

//     if (value == null || value.isEmpty) {
//       // debug//print('❌ ไม่มี UuidRequest: ยกเลิกโหลด reviews');
//       return;
//     }

//     if (mounted) {
//       setState(() {
//         requestUuid = value;
//         FlowUuid = valueFlowUuid;
//       });
//     }

//     final response = await read_GC_ReviewsUuid(value);
//     if (response?.statusCode == 200) {
//       final result = json.decode(response!.body);
//       final reviewDetailModel = ReviewDetail.fromJson(result['data']);
//       final bool isOpen = result['is_open_approved'] == true;

//       if (mounted) {
//         setState(() {
//           isOpenApproved = isOpen;
//           reviewDetail.add(reviewDetailModel);
//         });
//       }

//       await Future.delayed(const Duration(milliseconds: 300));
//       if (mounted) await Set_data();
//     } else {
//       //debug//print('❌ error: read_GC_ReviewsUuid');
//     }
//   }

//   Future<void> Set_data() async {
//     // debug//print('🔄 เริ่มโหลดข้อมูล: uuid=$requestUuid, flow=$FlowUuid');
//     try {
//       AddForm_requests_uuid(0);
//     } catch (e, st) {
//       //debug//print('🧾 ข้อความ: $e');
//       //debug//print('📍 StackTrace:\n$st');
//     }
//   }

//   void AddForm_requests_uuid(int index) {
//     if (reviewDetail.isEmpty || index >= reviewDetail.length) return;
//     final d = reviewDetail[index];

//     String _s(String? v) => v ?? '';
//     String _num(num? v) => v?.toString() ?? '';

//     // ระวังฟิลด์ซ้อนที่อาจเป็น null (json)
//     final cj = d.client.json;

//     final person = <String>[
//       _s(d.client.cname),
//       _s(d.client.tax),
//       _num(d.client.age),
//       _s(d.client.national),
//       _s(cj?.number),
//       _s(cj?.moo),
//       _s(cj?.soi),
//       _s(cj?.road),
//       _s(cj?.tambon),
//       _s(cj?.amphoe),
//       _s(cj?.province),
//       _s(d.client.tel),
//       _s(d.client.addr1),
//     ];

//     final shop = <String>[
//       '-',
//       _num(d.newRequest.qty),
//       _s(d.client.stype),
//       _s(d.client.scname),
//     ];

//     final shopSub = <String>[
//       _s(d.newRequest.subzone),
//       _s(d.newRequest.zn),
//       _s(d.newRequest.ln),
//     ];

//     final details = <String>[
//       _s(d.newRequest.sdate),
//       _s(d.newRequest.ldate),
//       _s(d.newRequest.type),
//       '1',
//     ];

//     final cid = <String>[
//       _s(d.newRequest.sdate),
//       _s(d.newRequest.ldate),
//       _s(d.newRequest.type),
//       _num(d.newRequest.leaseTermMonths),
//     ];

//     _updateCustomerData(person, shop, shopSub, details, cid);
//   }

//   ///////////----------------------->
//   void _syncControllersLength() {
//     void _syncList<T>(List<TextEditingController> ctrls, int wantLen,
//         String Function(int) textAt) {
//       // ลด
//       while (ctrls.length > wantLen) {
//         ctrls.removeLast().dispose();
//       }
//       // เพิ่ม
//       while (ctrls.length < wantLen) {
//         ctrls.add(TextEditingController(text: textAt(ctrls.length)));
//       }
//     }

//     _syncList(_controllers_person, data_person.length,
//         (i) => data_person[i].detail ?? '');
//     _syncList(
//         _controllers_shop, data_shop.length, (i) => data_shop[i].detail ?? '');
//     _syncList(_controllers_cid, data_cid.length,
//         (i) => (data_cid[i]['detail'] ?? '').toString());

//     final subLen = (data_shop.isNotEmpty) ? data_shop[0].detailsub.length : 0;
//     _syncList(_controllers_shop_sub, subLen,
//         (i) => data_shop[0].detailsub[i].detail ?? '');
//   }

//   ///////////----------------------->
//   void _updateCustomerData(
//     List<String> personData,
//     List<String> shopData,
//     List<String> shopSubData,
//     List<String> detailsData, // เผื่อใช้ต่อ
//     List<String> cidData,
//   ) {
//     for (int i = 0; i < personData.length && i < data_person.length; i++) {
//       data_person[i].detail = personData[i];
//     }
//     for (int i = 0; i < shopData.length && i < data_shop.length; i++) {
//       data_shop[i].detail = shopData[i];
//     }
//     if (data_shop.isNotEmpty) {
//       for (int i = 0;
//           i < shopSubData.length && i < data_shop[0].detailsub.length;
//           i++) {
//         data_shop[0].detailsub[i].detail = shopSubData[i];
//       }
//     }

//     // ถ้า data_cid เดิมว่าง ให้เตรียมโครงสร้างก่อน
//     if (data_cid.length < cidData.length) {
//       // เติม map เปล่าให้ครบ
//       data_cid.addAll(List.generate(
//           cidData.length - data_cid.length, (_) => {'detail': ''}));
//     }
//     for (int i = 0; i < cidData.length && i < data_cid.length; i++) {
//       data_cid[i]['detail'] = cidData[i];
//     }

//     // sync ความยาว controller ให้ตรง
//     _syncControllersLength();

//     // อัปเดตข้อความใน controller (กัน null)
//     for (int i = 0;
//         i < _controllers_person.length && i < data_person.length;
//         i++) {
//       _controllers_person[i].text = data_person[i].detail ?? '';
//     }
//     for (int i = 0; i < _controllers_shop.length && i < data_shop.length; i++) {
//       _controllers_shop[i].text = data_shop[i].detail ?? '';
//     }
//     for (int i = 0; i < _controllers_cid.length && i < data_cid.length; i++) {
//       _controllers_cid[i].text = (data_cid[i]['detail'] ?? '').toString();
//     }
//     if (data_shop.isNotEmpty) {
//       for (int i = 0;
//           i < _controllers_shop_sub.length && i < data_shop[0].detailsub.length;
//           i++) {
//         _controllers_shop_sub[i].text = data_shop[0].detailsub[i].detail ?? '';
//       }
//     }

//     if (mounted) setState(() {}); // รีเฟรชครั้งเดียว
//   }

//   ////////////--------------------->

//   @override
//   Widget build(BuildContext context) {
//     // ✅ ดึงเอกสารแบบปลอดภัย (กันลิสต์ว่าง/ค่า null)
//     final List<ApproveDocuments> docs = (checkupModel.isNotEmpty
//         ? (checkupModel.first.approveDocuments ?? const <ApproveDocuments>[])
//         : const <ApproveDocuments>[]);

//     // ✅ ชุดเอกสารที่ required
//     final List<ApproveDocuments> requiredDocs =
//         docs.where((d) => d.required == 1).toList();

//     // ---------- Helpers ----------
//     bool _hasSingle(dynamic a) {
//       // ไฟล์เดี่ยวอาจเป็น String/อ็อบเจ็กต์
//       if (a == null) return false;
//       if (a is String) return a.trim().isNotEmpty;
//       return true; // มีค่าเป็นอ็อบเจ็กต์ → ถือว่ามี 1 ชิ้น
//     }

//     int _countSingle(dynamic a) => _hasSingle(a) ? 1 : 0;

//     int _countList(List? list) => list?.length ?? 0;

//     bool _attached(ApproveDocuments d) {
//       final hasSingle = _hasSingle(d.approveAttachment);
//       final hasList = (d.approveAttachments?.isNotEmpty ?? false);
//       return hasSingle || hasList;
//     }

//     // ✅ ทุกเอกสารบังคับต้องแนบไฟล์ และต้องมีเอกสารบังคับจริงอย่างน้อย 1 รายการ
//     final bool isAllRequiredAttached =
//         requiredDocs.isNotEmpty && requiredDocs.every(_attached);

//     // ✅ นับไฟล์แนบทั้งหมดของทุกรายการ (ไฟล์เดี่ยว + ไฟล์หลาย)
//     final int totalAttachments = docs.fold<int>(0, (sum, d) {
//       final hasList = (d.approveAttachments?.isNotEmpty ?? false);
//       final count = hasList
//           ? _countList(d.approveAttachments)
//           : _countSingle(d.approveAttachment);
//       return sum + count;
//     });

//     // (ถ้าอยาก debug ชนิดข้อมูลของ approveAttachment บางตัว)
//     // for (var i = 0; i < docs.length; i++) {
//     //   final a = docs[i].approveAttachment;
//     //   debug//print('doc[$i] approveAttachment type: ${a?.runtimeType}, value: $a');
//     // }

// // --------
//     return (ser_tap == 2)
//         ? SignaturePad_CMM(
//             requestUuid: '$requestUuid', triggeredUuid: '$FlowUuid')
//         : Padding(
//             padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
//             child: SingleChildScrollView(
//               child: SizedBox(
//                 width: MediaQuery.of(context).size.width,
//                 // height: MediaQuery.of(context).size.height + 300,
//                 child: Column(children: [
//                   // ช่องค้นหา
//                   if (widget.viewver == false)
//                     Container(
//                         width: MediaQuery.of(context).size.width,
//                         // height: 50,
//                         decoration: BoxDecoration(
//                           color: AppbackgroundColor.TiTile_Box,
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             topRight: Radius.circular(10),
//                             bottomLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(10),
//                           ),
//                           border: Border.all(color: Colors.white, width: 2),
//                         ),
//                         // padding: const EdgeInsets.all(5.0),
//                         child: Row(children: [
//                           Expanded(
//                             flex: 1,
//                             child: Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Translate.TranslateAndSetText(
//                                   'คำขอต่อสัญญา ',
//                                   ChaoAreaScreen_Color.Colors_Text1_,
//                                   TextAlign.left,
//                                   FontWeight.bold,
//                                   FontWeight_.Fonts_T,
//                                   14,
//                                   2),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(4.0),
//                             child: SizedBox(
//                               width: 150,
//                               child: ElevatedButton(
//                                 style: ButtonStyle(
//                                   backgroundColor:
//                                       MaterialStateProperty.all<Color>(
//                                     Colors.black,
//                                     // Colors.black,
//                                   ),
//                                 ),
//                                 onPressed: () async {
//                                   SharedPreferences preferences =
//                                       await SharedPreferences.getInstance();
//                                   String? _route =
//                                       preferences.getString('route');
//                                   MaterialPageRoute materialPageRoute =
//                                       MaterialPageRoute(
//                                           builder: (BuildContext context) =>
//                                               AdminScafScreen(
//                                                   route: 'ใบอนุญาต',
//                                                   route_getdata: ""));
//                                   Navigator.pushAndRemoveUntil(context,
//                                       materialPageRoute, (route) => false);
//                                 },
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Translate.TranslateAndSet_TextAutoSize(
//                                       '<< ย้อนกลับ ',
//                                       ChaoAreaScreen_Color.Colors_Text3_,
//                                       TextAlign.center,
//                                       null,
//                                       FontWeight_.Fonts_T,
//                                       12,
//                                       18,
//                                       1),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           // Expanded(
//                           //   flex: 2,
//                           //   child: Padding(
//                           //     padding: const EdgeInsets.all(8.0),
//                           //     child: Translate.TranslateAndSetText(
//                           //         'รายละเอียดเอกสารสำหรับต่อสัญญา ',
//                           //         ChaoAreaScreen_Color.Colors_Text1_,
//                           //         TextAlign.left,
//                           //         FontWeight.bold,
//                           //         FontWeight_.Fonts_T,
//                           //         14,
//                           //         2),
//                           //   ),
//                           // ),
//                         ])),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   SizedBox(
//                     child: ScrollConfiguration(
//                         behavior: ScrollConfiguration.of(context)
//                             .copyWith(dragDevices: {
//                           PointerDeviceKind.touch,
//                           PointerDeviceKind.mouse,
//                         }),
//                         child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Container(
//                                 width: (MediaQuery.of(context).size.width <
//                                         1200)
//                                     ? 1400
//                                     : (Responsive.isDesktop(context))
//                                         ? MediaQuery.of(context).size.width *
//                                             0.85
//                                         : 1400,
//                                 // height: MediaQuery.of(context).size.height * 0.8,
//                                 decoration: const BoxDecoration(
//                                   color: AppbackgroundColor.Sub_Abg_Colors,
//                                   borderRadius: BorderRadius.only(
//                                       topLeft: Radius.circular(10),
//                                       topRight: Radius.circular(10),
//                                       bottomLeft: Radius.circular(10),
//                                       bottomRight: Radius.circular(10)),
//                                   // border: Border.all(color: Colors.grey, width: 1),
//                                 ),
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Expanded(
//                                         flex: 1,
//                                         child: (isLoading)
//                                             ? SizedBox(
//                                                 child: Column(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     const CircularProgressIndicator(),
//                                                     StreamBuilder(
//                                                       stream: Stream.periodic(
//                                                           const Duration(
//                                                               milliseconds: 25),
//                                                           (i) => i),
//                                                       builder:
//                                                           (context, snapshot) {
//                                                         if (!snapshot.hasData)
//                                                           return const Text('');
//                                                         double elapsed = double
//                                                                 .parse(snapshot
//                                                                     .data
//                                                                     .toString()) *
//                                                             0.05;
//                                                         return Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: Text(
//                                                             'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.', // ตัวบ่งชี้กำลังโหลด
//                                                             // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
//                                                             style: const TextStyle(
//                                                                 color: PeopleChaoScreen_Color
//                                                                     .Colors_Text2_,
//                                                                 fontFamily:
//                                                                     Font_
//                                                                         .Fonts_T
//                                                                 //fontSize: 10.0
//                                                                 ),
//                                                           ),
//                                                         );
//                                                       },
//                                                     ),
//                                                   ],
//                                                 ),
//                                               )
//                                             : Container(
//                                                 child: Column(children: [
//                                                   Form_Person(context),
//                                                   SizedBox(
//                                                     height: 20,
//                                                   ),
//                                                   Form_Shop(context),
//                                                   SizedBox(
//                                                     height: 20,
//                                                   ),
//                                                   Form_Cid(context),
//                                                   SizedBox(
//                                                     height: 30,
//                                                   ),
//                                                 ]),
//                                               )),
//                                     Expanded(
//                                       flex: 2,
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Column(children: [
//                                           SizedBox(
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.start,
//                                               children: [
//                                                 Container(
//                                                   decoration: BoxDecoration(
//                                                     color: AppbackgroundColor
//                                                             .TiTile_Colors
//                                                         .withOpacity(0.8),
//                                                     borderRadius:
//                                                         BorderRadius.only(
//                                                             topLeft:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             topRight:
//                                                                 Radius.circular(
//                                                                     15),
//                                                             bottomLeft:
//                                                                 Radius.circular(
//                                                                     0),
//                                                             bottomRight:
//                                                                 Radius.circular(
//                                                                     0)),
//                                                     // border: Border.all(color: Colors.grey, width: 1),
//                                                   ),
//                                                   padding:
//                                                       const EdgeInsets.fromLTRB(
//                                                           0, 0, 0, 0),
//                                                   child: Row(
//                                                     children: [
//                                                       Expanded(
//                                                         child: AutoSizeText(
//                                                           minFontSize: 12,
//                                                           maxFontSize: 16,
//                                                           maxLines: 1,
//                                                           'รูปภาพหลักฐานจากผู้เช่า/ผู้ค้า',
//                                                           textAlign:
//                                                               TextAlign.left,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           style: TextStyle(
//                                                               color: PeopleChaoScreen_Color
//                                                                   .Colors_Text2_,
//                                                               fontFamily: Font_
//                                                                   .Fonts_T),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 20,
//                                                 ),
//                                                 (isLoading)
//                                                     ? SizedBox(
//                                                         child: Column(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             const CircularProgressIndicator(),
//                                                             StreamBuilder(
//                                                               stream: Stream.periodic(
//                                                                   const Duration(
//                                                                       milliseconds:
//                                                                           25),
//                                                                   (i) => i),
//                                                               builder: (context,
//                                                                   snapshot) {
//                                                                 if (!snapshot
//                                                                     .hasData)
//                                                                   return const Text(
//                                                                       '');
//                                                                 double elapsed =
//                                                                     double.parse(snapshot
//                                                                             .data
//                                                                             .toString()) *
//                                                                         0.05;
//                                                                 return Padding(
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                               .all(
//                                                                           8.0),
//                                                                   child: Text(
//                                                                     'ดาวน์โหลด : ${elapsed.toStringAsFixed(2)} s.', // ตัวบ่งชี้กำลังโหลด
//                                                                     // 'Time : ${elapsed.toStringAsFixed(2)} seconds',
//                                                                     style: const TextStyle(
//                                                                         color: PeopleChaoScreen_Color
//                                                                             .Colors_Text2_,
//                                                                         fontFamily:
//                                                                             Font_.Fonts_T
//                                                                         //fontSize: 10.0
//                                                                         ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       )
//                                                     : (checkupModel
//                                                             .first
//                                                             .requestDocument!
//                                                             .isEmpty)
//                                                         ? Center(
//                                                             child: const Text(
//                                                               'ไม่พบข้อมูล',
//                                                               style: TextStyle(
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text2_,
//                                                                   fontFamily:
//                                                                       Font_
//                                                                           .Fonts_T
//                                                                   //fontSize: 10.0
//                                                                   ),
//                                                             ),
//                                                           )
//                                                         : SizedBox(
//                                                             // color:
//                                                             //     Colors.brown[200],
//                                                             child: Row(
//                                                               children: [
//                                                                 for (var admin_requestDocument
//                                                                     in checkupModel
//                                                                         .first
//                                                                         .requestDocument!)
//                                                                   Padding(
//                                                                     padding:
//                                                                         const EdgeInsets.all(
//                                                                             4.0),
//                                                                     child:
//                                                                         Column(
//                                                                       crossAxisAlignment:
//                                                                           CrossAxisAlignment
//                                                                               .start,
//                                                                       children: [
//                                                                         // ชื่อเอกสาร
//                                                                         Align(
//                                                                           alignment:
//                                                                               Alignment.topLeft,
//                                                                           child:
//                                                                               AutoSizeText(
//                                                                             minFontSize:
//                                                                                 12,
//                                                                             maxFontSize:
//                                                                                 16,
//                                                                             maxLines:
//                                                                                 1,
//                                                                             '${admin_requestDocument.nameTh ?? "-"}',
//                                                                             style:
//                                                                                 TextStyle(
//                                                                               color: PeopleChaoScreen_Color.Colors_Text2_,
//                                                                               fontFamily: Font_.Fonts_T,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         // กรอบภาพ
//                                                                         Container(
//                                                                             height:
//                                                                                 150,
//                                                                             width:
//                                                                                 270,
//                                                                             padding: const EdgeInsets.all(
//                                                                                 2.0),
//                                                                             decoration:
//                                                                                 BoxDecoration(
//                                                                               color: AppbackgroundColor.Sub_Abg_Colors,
//                                                                               borderRadius: BorderRadius.circular(10),
//                                                                               border: Border.all(color: Colors.grey, width: 1),
//                                                                             ),
//                                                                             child:
//                                                                                 Stack(children: [
//                                                                               ClipRRect(
//                                                                                 borderRadius: BorderRadius.circular(8.0),
//                                                                                 child: (admin_requestDocument.requestAttachments!.fileType.toString() == 'pdf')
//                                                                                     ? FutureBuilder<http.Response?>(
//                                                                                         future: img_ApprovalsRequests('${admin_requestDocument.requestAttachments!.uuid}'),
//                                                                                         builder: (context, snapshot) {
//                                                                                           if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                             return const Center(child: CircularProgressIndicator());
//                                                                                           }

//                                                                                           if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                             return SfPdfViewer.memory(
//                                                                                               snapshot.data!.bodyBytes,
//                                                                                               enableDocumentLinkAnnotation: false,
//                                                                                               canShowScrollHead: false,
//                                                                                               canShowScrollStatus: false,
//                                                                                               pageLayoutMode: PdfPageLayoutMode.continuous,
//                                                                                               enableDoubleTapZooming: false,
//                                                                                             );
//                                                                                           } else {
//                                                                                             return const Icon(Icons.broken_image);
//                                                                                           }
//                                                                                         },
//                                                                                       )
//                                                                                     : Center(
//                                                                                         child: ClipRRect(
//                                                                                           borderRadius: BorderRadius.circular(8.0),
//                                                                                           child: FittedBox(
//                                                                                             fit: BoxFit.contain,
//                                                                                             child: FutureBuilder<http.Response?>(
//                                                                                               future: img_ApprovalsRequests('${admin_requestDocument.requestAttachments!.uuid}'),
//                                                                                               builder: (context, snapshot) {
//                                                                                                 if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                   return const CircularProgressIndicator();
//                                                                                                 }
//                                                                                                 if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                   return Image.memory(snapshot.data!.bodyBytes, fit: BoxFit.contain);
//                                                                                                 } else {
//                                                                                                   return const Icon(Icons.broken_image);
//                                                                                                 }
//                                                                                               },
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                       ),
//                                                                               ),
//                                                                               Align(
//                                                                                 alignment: Alignment.center,
//                                                                                 child: SizedBox(
//                                                                                   width: 130,
//                                                                                   child: ElevatedButton(
//                                                                                     style: ButtonStyle(
//                                                                                       backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey.withOpacity(0.5)),
//                                                                                     ),
//                                                                                     onPressed: () async {
//                                                                                       showDialog(
//                                                                                         context: context,
//                                                                                         barrierDismissible: false,
//                                                                                         builder: (context) {
//                                                                                           return StatefulBuilder(
//                                                                                             builder: (context, setState) {
//                                                                                               final uuid = admin_requestDocument.requestAttachments?.uuid;

//                                                                                               return AlertDialog(
//                                                                                                 shape: RoundedRectangleBorder(
//                                                                                                   borderRadius: BorderRadius.circular(20),
//                                                                                                 ),
//                                                                                                 backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
//                                                                                                 titlePadding: const EdgeInsets.all(0.0),
//                                                                                                 contentPadding: const EdgeInsets.all(10.0),
//                                                                                                 actionsPadding: const EdgeInsets.all(6.0),
//                                                                                                 title: Column(
//                                                                                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                                   children: [
//                                                                                                     Row(
//                                                                                                       mainAxisAlignment: MainAxisAlignment.end,
//                                                                                                       children: [
//                                                                                                         InkWell(
//                                                                                                           onTap: () => Navigator.pop(context),
//                                                                                                           child: Padding(
//                                                                                                             padding: const EdgeInsets.all(4.0),
//                                                                                                             child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
//                                                                                                           ),
//                                                                                                         ),
//                                                                                                       ],
//                                                                                                     ),
//                                                                                                     Padding(
//                                                                                                       padding: const EdgeInsets.all(4.0),
//                                                                                                       child: Text(
//                                                                                                         admin_requestDocument.nameTh ?? 'ไม่พบชื่อเอกสาร',
//                                                                                                         // minFontSize: 12,
//                                                                                                         // maxFontSize: 16,
//                                                                                                         maxLines: 2,
//                                                                                                         textAlign: TextAlign.center,
//                                                                                                         style: TextStyle(
//                                                                                                           color: PeopleChaoScreen_Color.Colors_Text2_,
//                                                                                                           fontFamily: Font_.Fonts_T,
//                                                                                                           fontWeight: FontWeight.bold,
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                     ),
//                                                                                                   ],
//                                                                                                 ),
//                                                                                                 content: SizedBox(
//                                                                                                   height: MediaQuery.of(context).size.height * 0.9,
//                                                                                                   width: MediaQuery.of(context).size.width * 0.55,
//                                                                                                   child: (uuid != null && admin_requestDocument.requestAttachments!.fileType.toString() == 'pdf')
//                                                                                                       ? Stack(
//                                                                                                           children: [
//                                                                                                             FutureBuilder<http.Response?>(
//                                                                                                               future: img_ApprovalsRequests('${admin_requestDocument.requestAttachments!.uuid}'),
//                                                                                                               builder: (context, snapshot) {
//                                                                                                                 if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                                   return const Center(child: CircularProgressIndicator());
//                                                                                                                 }

//                                                                                                                 if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                                   return SfPdfViewer.memory(
//                                                                                                                     snapshot.data!.bodyBytes,
//                                                                                                                     enableDocumentLinkAnnotation: false,
//                                                                                                                     canShowScrollHead: false,
//                                                                                                                     canShowScrollStatus: false,
//                                                                                                                     pageLayoutMode: PdfPageLayoutMode.continuous,
//                                                                                                                     enableDoubleTapZooming: false,
//                                                                                                                   );
//                                                                                                                 } else {
//                                                                                                                   return const Icon(Icons.broken_image);
//                                                                                                                 }
//                                                                                                               },
//                                                                                                             ),
//                                                                                                             // SfPdfViewer.network(
//                                                                                                             //   '${MyConstant().domain_v1}/admin/requests/attachments/$uuid/preview',
//                                                                                                             //   enableDocumentLinkAnnotation: false,
//                                                                                                             //   canShowScrollHead: false,
//                                                                                                             //   canShowScrollStatus: false,
//                                                                                                             //   pageLayoutMode: PdfPageLayoutMode.continuous,
//                                                                                                             //   enableDoubleTapZooming: false,
//                                                                                                             // ),
//                                                                                                             IgnorePointer(child: _buildWatermarkOverlay())
//                                                                                                           ],
//                                                                                                         )
//                                                                                                       : (uuid != null && admin_requestDocument.requestAttachments!.fileType.toString() != 'pdf')
//                                                                                                           ? ClipRRect(
//                                                                                                               borderRadius: BorderRadius.circular(8.0),
//                                                                                                               child: FittedBox(
//                                                                                                                 fit: BoxFit.contain,
//                                                                                                                 child: FutureBuilder<http.Response?>(
//                                                                                                                   future: img_ApprovalsRequests('${admin_requestDocument.requestAttachments!.uuid}'),
//                                                                                                                   // future: img_ApprovalsCheckUp('$requestUuid', '${admin_requestDocument.requestAttachments!.uuid}'),
//                                                                                                                   builder: (context, snapshot) {
//                                                                                                                     if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                                       return Center(child: SizedBox(width: 100, height: 100, child: const CircularProgressIndicator()));
//                                                                                                                     }
//                                                                                                                     if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                                       return Center(
//                                                                                                                         child: InteractiveViewer(child: Image.memory(snapshot.data!.bodyBytes, fit: BoxFit.contain)),
//                                                                                                                       );
//                                                                                                                     } else {
//                                                                                                                       return const Icon(Icons.broken_image);
//                                                                                                                     }
//                                                                                                                   },
//                                                                                                                 ),
//                                                                                                               ),
//                                                                                                             )
//                                                                                                           : const Center(
//                                                                                                               child: Text(
//                                                                                                                 'ไม่พบไฟล์แนบ',
//                                                                                                                 style: TextStyle(color: Colors.grey),
//                                                                                                               ),
//                                                                                                             ),
//                                                                                                 ),
//                                                                                               );
//                                                                                             },
//                                                                                           );
//                                                                                         },
//                                                                                       );
//                                                                                     },
//                                                                                     child: Padding(
//                                                                                       padding: const EdgeInsets.all(4.0),
//                                                                                       child: Translate.TranslateAndSet_TextAutoSize(
//                                                                                         (admin_requestDocument.requestAttachments!.fileType.toString() == 'pdf') ? 'Preview PDF' : 'Preview Image',
//                                                                                         ChaoAreaScreen_Color.Colors_Text3_,
//                                                                                         TextAlign.center,
//                                                                                         null,
//                                                                                         FontWeight_.Fonts_T,
//                                                                                         10,
//                                                                                         12,
//                                                                                         1,
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                               )
//                                                                             ])),
//                                                                         // วันที่
//                                                                         Align(
//                                                                           alignment:
//                                                                               Alignment.center,
//                                                                           child:
//                                                                               AutoSizeText(
//                                                                             (admin_requestDocument.requestAttachments.isNull)
//                                                                                 ? ''
//                                                                                 : '${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse('${admin_requestDocument.requestAttachments!.createdAt!}'))}',

//                                                                             // admin_requestDocument.requestAttachments!.createdAt ?? '',
//                                                                             minFontSize:
//                                                                                 12,
//                                                                             maxFontSize:
//                                                                                 16,
//                                                                             maxLines:
//                                                                                 1,
//                                                                             textAlign:
//                                                                                 TextAlign.center,
//                                                                             style:
//                                                                                 TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                               ],
//                                                             ),
//                                                           ),
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 20,
//                                           ),
//                                           SizedBox(
//                                             child: Column(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.start,
//                                               children: [
//                                                 Container(
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.brown[200],
//                                                     borderRadius:
//                                                         BorderRadius.only(
//                                                             topLeft:
//                                                                 Radius.circular(
//                                                                     10),
//                                                             topRight:
//                                                                 Radius.circular(
//                                                                     15),
//                                                             bottomLeft:
//                                                                 Radius.circular(
//                                                                     0),
//                                                             bottomRight:
//                                                                 Radius.circular(
//                                                                     0)),
//                                                     // border: Border.all(color: Colors.grey, width: 1),
//                                                   ),
//                                                   padding:
//                                                       const EdgeInsets.fromLTRB(
//                                                           0, 0, 0, 0),
//                                                   child: Row(
//                                                     children: [
//                                                       Expanded(
//                                                         child: AutoSizeText(
//                                                           minFontSize: 12,
//                                                           maxFontSize: 16,
//                                                           maxLines: 1,
//                                                           'รูปภาพหลักฐานการตรวจสอบข้อเท็จจริง',
//                                                           textAlign:
//                                                               TextAlign.left,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           style: TextStyle(
//                                                               color: PeopleChaoScreen_Color
//                                                                   .Colors_Text2_,
//                                                               fontFamily: Font_
//                                                                   .Fonts_T),
//                                                         ),
//                                                       ),
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(3.0),
//                                                         child: InkWell(
//                                                             onTap: () async {
//                                                               // await loadApprovalsCheckUp();
//                                                               showDialog(
//                                                                 context:
//                                                                     context,
//                                                                 barrierDismissible:
//                                                                     false,
//                                                                 builder:
//                                                                     (context) {
//                                                                   return StatefulBuilder(
//                                                                     builder:
//                                                                         (context,
//                                                                             setState) {
//                                                                       return AlertDialog(
//                                                                         shape: RoundedRectangleBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(20)),
//                                                                         backgroundColor:
//                                                                             AppbackgroundColor.Sub_Abg_Colors,
//                                                                         titlePadding:
//                                                                             const EdgeInsets.all(0),
//                                                                         contentPadding:
//                                                                             const EdgeInsets.all(10),
//                                                                         actionsPadding:
//                                                                             const EdgeInsets.all(6),
//                                                                         title:
//                                                                             Column(
//                                                                           crossAxisAlignment:
//                                                                               CrossAxisAlignment.center,
//                                                                           children: [
//                                                                             Row(
//                                                                               mainAxisAlignment: MainAxisAlignment.end,
//                                                                               children: [
//                                                                                 InkWell(
//                                                                                   onTap: () => Navigator.pop(context),
//                                                                                   child: const Padding(
//                                                                                     padding: EdgeInsets.all(4),
//                                                                                     child: Icon(Icons.highlight_off, size: 30, color: Colors.red),
//                                                                                   ),
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                             const Padding(
//                                                                               padding: EdgeInsets.all(4.0),
//                                                                               child: Text(
//                                                                                 'ประวัติการอัปโหลดภาพ',
//                                                                                 style: TextStyle(
//                                                                                   fontSize: 18,
//                                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
//                                                                                   fontFamily: Font_.Fonts_T,
//                                                                                   fontWeight: FontWeight.bold,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                         content:
//                                                                             SizedBox(
//                                                                           height:
//                                                                               MediaQuery.of(context).size.height * (MediaQuery.of(context).size.height < 800 ? 0.7 : 0.9),
//                                                                           width:
//                                                                               350,
//                                                                           child:
//                                                                               ListView(
//                                                                             children: [
//                                                                               const SizedBox(height: 20),
//                                                                               if (isLoading)
//                                                                                 Widget_Loading(context)
//                                                                               else if (checkupModel.first.approveDocuments?.isEmpty ?? true)
//                                                                                 const Center(
//                                                                                   child: Text(
//                                                                                     'ไม่พบข้อมูล',
//                                                                                     style: TextStyle(
//                                                                                       color: PeopleChaoScreen_Color.Colors_Text2_,
//                                                                                       fontFamily: Font_.Fonts_T,
//                                                                                     ),
//                                                                                   ),
//                                                                                 )
//                                                                               else
//                                                                                 ...checkupModel.first.approveDocuments!.map((type) {
//                                                                                   return Container(
//                                                                                     decoration: const BoxDecoration(
//                                                                                       border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
//                                                                                     ),
//                                                                                     child: Column(
//                                                                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                       children: [
//                                                                                         if ((type.approveAttachments?.isNotEmpty ?? false))
//                                                                                           Padding(
//                                                                                             padding: const EdgeInsets.symmetric(vertical: 4.0),
//                                                                                             child: Text(
//                                                                                               type.nameTh ?? '-',
//                                                                                               style: const TextStyle(
//                                                                                                 fontSize: 16,
//                                                                                                 color: PeopleChaoScreen_Color.Colors_Text2_,
//                                                                                                 fontFamily: Font_.Fonts_T,
//                                                                                                 fontWeight: FontWeight.bold,
//                                                                                               ),
//                                                                                             ),
//                                                                                           ),
//                                                                                         if ((type.approveAttachments?.isNotEmpty ?? false))
//                                                                                           ...type.approveAttachments!.map((history) {
//                                                                                             final previewFuture = img_ApprovalsCheckUp(requestUuid, history.uuid);
//                                                                                             return ListTile(
//                                                                                               title: Text(
//                                                                                                 history.caption ?? '-',
//                                                                                                 maxLines: 1,
//                                                                                                 overflow: TextOverflow.ellipsis,
//                                                                                                 style: const TextStyle(fontSize: 14, fontFamily: Font_.Fonts_T),
//                                                                                               ),
//                                                                                               subtitle: Text(
//                                                                                                 (history.createdAt == null) ? '-' : '${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse('${history.createdAt!}')) ?? "-"}',
//                                                                                                 // history.createdAt ?? '-',
//                                                                                                 maxLines: 1,
//                                                                                                 overflow: TextOverflow.ellipsis,
//                                                                                                 style: const TextStyle(fontSize: 14, fontFamily: Font_.Fonts_T),
//                                                                                               ),
//                                                                                               trailing: InkWell(
//                                                                                                 onTap: () {
//                                                                                                   showDialog(
//                                                                                                     context: context,
//                                                                                                     barrierDismissible: false,
//                                                                                                     builder: (context) {
//                                                                                                       return AlertDialog(
//                                                                                                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                                                                                                         backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
//                                                                                                         titlePadding: const EdgeInsets.all(0),
//                                                                                                         contentPadding: const EdgeInsets.all(10),
//                                                                                                         actionsPadding: const EdgeInsets.all(6),
//                                                                                                         title: Row(
//                                                                                                           mainAxisAlignment: MainAxisAlignment.end,
//                                                                                                           children: [
//                                                                                                             InkWell(
//                                                                                                               onTap: () => Navigator.pop(context),
//                                                                                                               child: const Padding(
//                                                                                                                 padding: EdgeInsets.all(4),
//                                                                                                                 child: Icon(Icons.highlight_off, size: 30, color: Colors.red),
//                                                                                                               ),
//                                                                                                             ),
//                                                                                                           ],
//                                                                                                         ),
//                                                                                                         content: ClipRRect(
//                                                                                                           borderRadius: BorderRadius.circular(8.0),
//                                                                                                           child: SizedBox(
//                                                                                                             height: MediaQuery.of(context).size.height * 0.9,
//                                                                                                             width: MediaQuery.of(context).size.width * 0.55,
//                                                                                                             child: FutureBuilder<http.Response?>(
//                                                                                                               future: previewFuture,
//                                                                                                               builder: (context, snapshot) {
//                                                                                                                 if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                                   return const Center(child: CircularProgressIndicator());
//                                                                                                                 }
//                                                                                                                 if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                                   final ct = (snapshot.data!.headers['content-type'] ?? '').toLowerCase();
//                                                                                                                   final bytes = snapshot.data!.bodyBytes;
//                                                                                                                   if (ct.contains('pdf')) {
//                                                                                                                     // แสดงเต็มจอได้ ปลอดภัย
//                                                                                                                     return SfPdfViewer.memory(bytes);
//                                                                                                                   } else {
//                                                                                                                     return InteractiveViewer(
//                                                                                                                       child: Image.memory(bytes, fit: BoxFit.contain),
//                                                                                                                     );
//                                                                                                                   }
//                                                                                                                 }
//                                                                                                                 return const Icon(Icons.broken_image, size: 48);
//                                                                                                               },
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                         ),
//                                                                                                       );
//                                                                                                     },
//                                                                                                   );
//                                                                                                 },
//                                                                                                 child: SizedBox(
//                                                                                                   height: 120,
//                                                                                                   width: 120,
//                                                                                                   child: ClipRRect(
//                                                                                                     borderRadius: BorderRadius.circular(8.0),
//                                                                                                     child: FutureBuilder<http.Response?>(
//                                                                                                       future: previewFuture,
//                                                                                                       builder: (context, snapshot) {
//                                                                                                         if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                           return const Center(child: CircularProgressIndicator());
//                                                                                                         }
//                                                                                                         if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                           final ct = (snapshot.data!.headers['content-type'] ?? '').toLowerCase();
//                                                                                                           final bytes = snapshot.data!.bodyBytes;

//                                                                                                           // ✅ Thumbnail: ห้ามใช้ SfPdfViewer ในกรอบเล็ก ๆ
//                                                                                                           if (ct.contains('pdf')) {
//                                                                                                             // แสดง placeholder สำหรับ PDF
//                                                                                                             return Container(
//                                                                                                               alignment: Alignment.center,
//                                                                                                               padding: const EdgeInsets.all(8),
//                                                                                                               child: Column(
//                                                                                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                                                                                 children: const [
//                                                                                                                   Icon(Icons.picture_as_pdf, size: 30),
//                                                                                                                   // SizedBox(height: 5),
//                                                                                                                   // Text('PDF', overflow: TextOverflow.ellipsis),
//                                                                                                                 ],
//                                                                                                               ),
//                                                                                                             );
//                                                                                                           } else {
//                                                                                                             // รูปภาพเท่านั้นถึงจะแสดงจริงใน thumbnail
//                                                                                                             return Center(
//                                                                                                               child: InteractiveViewer(child: Image.memory(bytes, fit: BoxFit.contain)),
//                                                                                                             );
//                                                                                                           }
//                                                                                                         }
//                                                                                                         return const Icon(Icons.broken_image, size: 48);
//                                                                                                       },
//                                                                                                     ),
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                             );
//                                                                                           }),
//                                                                                       ],
//                                                                                     ),
//                                                                                   );
//                                                                                 }),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                       );
//                                                                     },
//                                                                   );
//                                                                 },
//                                                               );
//                                                             },
//                                                             child: Icon(
//                                                                 Icons.history)),
//                                                       )
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   height: 20,
//                                                 ),
//                                                 (isLoading)
//                                                     ? Widget_Loading(context)
//                                                     : (checkupModel
//                                                             .first
//                                                             .approveDocuments!
//                                                             .isEmpty)
//                                                         ? Center(
//                                                             child: const Text(
//                                                               'ไม่พบข้อมูล',
//                                                               style: TextStyle(
//                                                                   color: PeopleChaoScreen_Color
//                                                                       .Colors_Text2_,
//                                                                   fontFamily:
//                                                                       Font_
//                                                                           .Fonts_T
//                                                                   //fontSize: 10.0
//                                                                   ),
//                                                             ),
//                                                           )
//                                                         : SizedBox(
//                                                             // color:
//                                                             //     Colors.brown[200],
//                                                             child:
//                                                                 ScrollConfiguration(
//                                                               behavior: ScrollConfiguration
//                                                                       .of(
//                                                                           context)
//                                                                   .copyWith(
//                                                                       dragDevices: {
//                                                                     PointerDeviceKind
//                                                                         .touch,
//                                                                     PointerDeviceKind
//                                                                         .mouse,
//                                                                   }),
//                                                               child:
//                                                                   SingleChildScrollView(
//                                                                 scrollDirection:
//                                                                     Axis.horizontal,
//                                                                 child: Row(
//                                                                   children: [
//                                                                     for (var admin_imgpeople
//                                                                         in checkupModel
//                                                                             .first
//                                                                             .approveDocuments!)
//                                                                       Padding(
//                                                                         padding:
//                                                                             const EdgeInsets.all(4.0),
//                                                                         child:
//                                                                             Column(
//                                                                           crossAxisAlignment:
//                                                                               CrossAxisAlignment.start,
//                                                                           children: [
//                                                                             // ชื่อเอกสาร
//                                                                             Align(
//                                                                               alignment: Alignment.topLeft,
//                                                                               child: AutoSizeText(
//                                                                                 minFontSize: 12,
//                                                                                 maxFontSize: 16,
//                                                                                 maxLines: 1,
//                                                                                 '${admin_imgpeople.nameTh ?? "-"}',
//                                                                                 style: TextStyle(
//                                                                                   color: PeopleChaoScreen_Color.Colors_Text2_,
//                                                                                   fontFamily: Font_.Fonts_T,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                             // กรอบภาพ
//                                                                             Container(
//                                                                               height: 150,
//                                                                               width: 270,
//                                                                               padding: const EdgeInsets.all(2.0),
//                                                                               decoration: BoxDecoration(
//                                                                                 color: AppbackgroundColor.Sub_Abg_Colors,
//                                                                                 borderRadius: BorderRadius.circular(10),
//                                                                                 border: Border.all(color: Colors.grey, width: 1),
//                                                                               ),
//                                                                               child: (admin_imgpeople.approveAttachment == null || admin_imgpeople.approveAttachment.isNull || admin_imgpeople.approveAttachment.toString() == 'null')
//                                                                                   ? InkWell(
//                                                                                       onTap: (widget.viewver == true)
//                                                                                           ? null
//                                                                                           : () async {
//                                                                                               final id = admin_imgpeople.id;
//                                                                                               if (id != null) {
//                                                                                                 final response = await pickAndUpload_CheckUp(requestUuid ?? '', id);

//                                                                                                 if (response == null) {
//                                                                                                   //print('⚠️ ไม่มีการเลือกไฟล์หรือเกิดข้อผิดพลาด');
//                                                                                                   Dialog_error(context, 'ไม่มีไฟล์ถูกอัปโหลด');
//                                                                                                   return;
//                                                                                                 }

//                                                                                                 //print('📌 attachments ใหม่: $response');
//                                                                                                 if (response.statusCode == 200 || response.statusCode == 201) {
//                                                                                                   final Map<String, dynamic> result = json.decode(response.body);
//                                                                                                   final data = result['data'];
//                                                                                                   final updatedAttachment = ApprovalsFlowCheckUpModel.fromJson(data);
//                                                                                                   setState(() {
//                                                                                                     admin_imgpeople.approveAttachment = ApproveAttachment.fromJson(data);
//                                                                                                   });

//                                                                                                   // //print('✅ อัปโหลดสำเร็จ: ${updatedAttachment.approveDocuments?.first.approveAttachment!.uuid}');
//                                                                                                   Dialog_success(context, 'อัปโหลดสำเร็จ');
//                                                                                                 } else {
//                                                                                                   //print('❌ การอัปโหลดล้มเหลว: ${response.statusCode}');
//                                                                                                   Dialog_error(context, 'การอัปโหลดล้มเหลว');
//                                                                                                 }
//                                                                                               } else {
//                                                                                                 Dialog_error(context, 'ไม่พบ ID สำหรับ ${admin_imgpeople.nameTh ?? "-"}');
//                                                                                               }
//                                                                                             },
//                                                                                       child: SizedBox(
//                                                                                         child: (widget.viewver == true)
//                                                                                             ? Center(child: Text("ไม่พบไฟล์", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)))
//                                                                                             : Column(
//                                                                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                                                                 children: [
//                                                                                                   Icon(Icons.system_update_alt_outlined, size: 30, color: Colors.grey),
//                                                                                                   SizedBox(height: 8),
//                                                                                                   Text("คลิกหรือกด เพื่อเลือกไฟล์", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
//                                                                                                   Text("รองรับไฟล์ภาพ JPG หรือ PNG", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
//                                                                                                   Text("ขนาดไฟล์สูงสุด: 10MB", textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: Colors.grey)),
//                                                                                                 ],
//                                                                                               ),
//                                                                                       ),
//                                                                                     )
//                                                                                   : Stack(children: [
//                                                                                       Center(
//                                                                                         child: ClipRRect(
//                                                                                           borderRadius: BorderRadius.circular(8.0),
//                                                                                           child: (admin_imgpeople.approveAttachment!.uuid != null && admin_imgpeople.approveAttachment!.fileType.toString() == 'pdf')
//                                                                                               ? SizedBox(
//                                                                                                   height: 400,
//                                                                                                   width: 300,
//                                                                                                   child: FutureBuilder<http.Response?>(
//                                                                                                     future: img_ApprovalsCheckUp('$requestUuid', '${admin_imgpeople.approveAttachment!.uuid}'),
//                                                                                                     builder: (context, snapshot) {
//                                                                                                       if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                         return const Center(child: CircularProgressIndicator());
//                                                                                                       }

//                                                                                                       if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                         final contentType = snapshot.data!.headers['content-type'] ?? '';
//                                                                                                         if (contentType.contains('application/pdf')) {
//                                                                                                           return SfPdfViewer.memory(
//                                                                                                             snapshot.data!.bodyBytes,
//                                                                                                             enableDocumentLinkAnnotation: false,
//                                                                                                             canShowScrollHead: false,
//                                                                                                             canShowScrollStatus: false,
//                                                                                                             pageLayoutMode: PdfPageLayoutMode.continuous,
//                                                                                                             enableDoubleTapZooming: false,
//                                                                                                           );
//                                                                                                         } else {
//                                                                                                           return Image.memory(
//                                                                                                             snapshot.data!.bodyBytes,
//                                                                                                             fit: BoxFit.contain,
//                                                                                                           );
//                                                                                                         }
//                                                                                                       }

//                                                                                                       return const Icon(Icons.broken_image, size: 48);
//                                                                                                     },
//                                                                                                   ),
//                                                                                                 )
//                                                                                               : FittedBox(
//                                                                                                   fit: BoxFit.contain,
//                                                                                                   child: FutureBuilder<http.Response?>(
//                                                                                                     future: img_ApprovalsCheckUp('$requestUuid', '${admin_imgpeople.approveAttachment!.uuid}'),
//                                                                                                     builder: (context, snapshot) {
//                                                                                                       if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                         return Center(child: SizedBox(width: 100, height: 100, child: const CircularProgressIndicator()));
//                                                                                                       }
//                                                                                                       if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                         return Image.memory(
//                                                                                                           snapshot.data!.bodyBytes,
//                                                                                                           fit: BoxFit.contain,
//                                                                                                         );
//                                                                                                       } else {
//                                                                                                         return const Icon(Icons.broken_image);
//                                                                                                       }
//                                                                                                     },
//                                                                                                   ),
//                                                                                                 ),
//                                                                                         ),
//                                                                                       ),
//                                                                                       Align(
//                                                                                         alignment: Alignment.center,
//                                                                                         child: Column(
//                                                                                           mainAxisAlignment: MainAxisAlignment.center,
//                                                                                           children: [
//                                                                                             SizedBox(
//                                                                                               width: 130,
//                                                                                               child: ElevatedButton(
//                                                                                                 style: ButtonStyle(
//                                                                                                   backgroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey.withOpacity(0.5)),
//                                                                                                 ),
//                                                                                                 onPressed: () async {
//                                                                                                   showDialog(
//                                                                                                     context: context,
//                                                                                                     barrierDismissible: false,
//                                                                                                     builder: (context) {
//                                                                                                       return StatefulBuilder(
//                                                                                                         builder: (context, setState) {
//                                                                                                           final uuid = admin_imgpeople.approveAttachment?.uuid;

//                                                                                                           return AlertDialog(
//                                                                                                             shape: RoundedRectangleBorder(
//                                                                                                               borderRadius: BorderRadius.circular(20),
//                                                                                                             ),
//                                                                                                             backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
//                                                                                                             titlePadding: const EdgeInsets.all(0.0),
//                                                                                                             contentPadding: const EdgeInsets.all(10.0),
//                                                                                                             actionsPadding: const EdgeInsets.all(6.0),
//                                                                                                             title: Column(
//                                                                                                               crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                                               children: [
//                                                                                                                 Row(
//                                                                                                                   mainAxisAlignment: MainAxisAlignment.end,
//                                                                                                                   children: [
//                                                                                                                     InkWell(
//                                                                                                                       onTap: () => Navigator.pop(context),
//                                                                                                                       child: Padding(
//                                                                                                                         padding: const EdgeInsets.all(4.0),
//                                                                                                                         child: Icon(Icons.highlight_off, size: 30, color: Colors.red[700]),
//                                                                                                                       ),
//                                                                                                                     ),
//                                                                                                                   ],
//                                                                                                                 ),
//                                                                                                                 Padding(
//                                                                                                                   padding: const EdgeInsets.all(4.0),
//                                                                                                                   child: Text(
//                                                                                                                     admin_imgpeople.nameTh ?? 'ไม่พบชื่อเอกสาร',
//                                                                                                                     // minFontSize: 12,
//                                                                                                                     // maxFontSize: 16,
//                                                                                                                     maxLines: 2,
//                                                                                                                     textAlign: TextAlign.center,
//                                                                                                                     style: TextStyle(
//                                                                                                                       color: PeopleChaoScreen_Color.Colors_Text2_,
//                                                                                                                       fontFamily: Font_.Fonts_T,
//                                                                                                                       fontWeight: FontWeight.bold,
//                                                                                                                     ),
//                                                                                                                   ),
//                                                                                                                 ),
//                                                                                                               ],
//                                                                                                             ),
//                                                                                                             content: Stack(
//                                                                                                               children: [
//                                                                                                                 SizedBox(
//                                                                                                                   height: MediaQuery.of(context).size.height * 0.9,
//                                                                                                                   width: MediaQuery.of(context).size.width * 0.55,
//                                                                                                                   child: Builder(
//                                                                                                                     builder: (context) {
//                                                                                                                       final attachment = admin_imgpeople.approveAttachment;
//                                                                                                                       final uuid = attachment?.uuid;
//                                                                                                                       final fileType = attachment?.fileType?.toLowerCase();

//                                                                                                                       if (uuid == null || fileType == null) {
//                                                                                                                         return const Center(
//                                                                                                                           child: Text(
//                                                                                                                             'ไม่พบไฟล์แนบ',
//                                                                                                                             style: TextStyle(color: Colors.grey),
//                                                                                                                           ),
//                                                                                                                         );
//                                                                                                                       }

//                                                                                                                       final Future<http.Response?> future = img_ApprovalsCheckUp(requestUuid, uuid);

//                                                                                                                       return FutureBuilder<http.Response?>(
//                                                                                                                         future: future,
//                                                                                                                         builder: (context, snapshot) {
//                                                                                                                           if (snapshot.connectionState == ConnectionState.waiting) {
//                                                                                                                             return const Center(child: CircularProgressIndicator());
//                                                                                                                           }

//                                                                                                                           if (snapshot.hasData && snapshot.data?.statusCode == 200) {
//                                                                                                                             final contentType = snapshot.data!.headers['content-type'] ?? '';
//                                                                                                                             final isPDF = contentType.contains('application/pdf');

//                                                                                                                             final contentWidget = isPDF
//                                                                                                                                 ? SfPdfViewer.memory(
//                                                                                                                                     snapshot.data!.bodyBytes,
//                                                                                                                                     enableDocumentLinkAnnotation: false,
//                                                                                                                                     canShowScrollHead: false,
//                                                                                                                                     canShowScrollStatus: false,
//                                                                                                                                     pageLayoutMode: PdfPageLayoutMode.continuous,
//                                                                                                                                     enableDoubleTapZooming: false,
//                                                                                                                                   )
//                                                                                                                                 : ClipRRect(
//                                                                                                                                     borderRadius: BorderRadius.circular(8.0),
//                                                                                                                                     child: Center(
//                                                                                                                                       child: InteractiveViewer(
//                                                                                                                                         child: Image.memory(
//                                                                                                                                           snapshot.data!.bodyBytes,
//                                                                                                                                           fit: BoxFit.contain,
//                                                                                                                                         ),
//                                                                                                                                       ),
//                                                                                                                                     ));

//                                                                                                                             return Stack(
//                                                                                                                               children: [
//                                                                                                                                 contentWidget,
//                                                                                                                                 IgnorePointer(child: _buildWatermarkOverlay()),
//                                                                                                                               ],
//                                                                                                                             );
//                                                                                                                           }

//                                                                                                                           return const Center(child: Icon(Icons.broken_image, size: 48));
//                                                                                                                         },
//                                                                                                                       );
//                                                                                                                     },
//                                                                                                                   ),
//                                                                                                                 ),
//                                                                                                               ],
//                                                                                                             ),
//                                                                                                           );
//                                                                                                         },
//                                                                                                       );
//                                                                                                     },
//                                                                                                   );
//                                                                                                 },
//                                                                                                 child: Padding(
//                                                                                                   padding: const EdgeInsets.all(4.0),
//                                                                                                   child: Translate.TranslateAndSet_TextAutoSize(
//                                                                                                     (admin_imgpeople.approveAttachment!.fileType.toString() == 'pdf') ? 'Preview PDF' : 'Preview Image',
//                                                                                                     ChaoAreaScreen_Color.Colors_Text3_,
//                                                                                                     TextAlign.center,
//                                                                                                     null,
//                                                                                                     FontWeight_.Fonts_T,
//                                                                                                     10,
//                                                                                                     12,
//                                                                                                     1,
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                             ),
//                                                                                             SizedBox(
//                                                                                               height: 10,
//                                                                                             ),
//                                                                                             if (widget.viewver == false)
//                                                                                               Align(
//                                                                                                   alignment: Alignment.center,
//                                                                                                   child: SizedBox(
//                                                                                                       width: 130,
//                                                                                                       child: ElevatedButton(
//                                                                                                         style: ButtonStyle(
//                                                                                                           backgroundColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.5)),
//                                                                                                         ),
//                                                                                                         onPressed: () async {
//                                                                                                           final id = admin_imgpeople.id;
//                                                                                                           if (id != null) {
//                                                                                                             final response = await pickAndUpload_CheckUp(requestUuid ?? '', id);

//                                                                                                             if (response == null) {
//                                                                                                               //print('⚠️ ไม่มีการเลือกไฟล์หรือเกิดข้อผิดพลาด');
//                                                                                                               Dialog_error(context, 'ไม่มีไฟล์ถูกอัปโหลด');
//                                                                                                               return;
//                                                                                                             }

//                                                                                                             //print('📌 attachments ใหม่: $response');
//                                                                                                             if (response.statusCode == 200 || response.statusCode == 201) {
//                                                                                                               final Map<String, dynamic> result = json.decode(response.body);
//                                                                                                               final data = result['data'];
//                                                                                                               final updatedAttachment = ApprovalsFlowCheckUpModel.fromJson(data);
//                                                                                                               setState(() {
//                                                                                                                 admin_imgpeople.approveAttachment = ApproveAttachment.fromJson(data);
//                                                                                                               });
//                                                                                                               await loadApprovalsCheckUp();

//                                                                                                               // //print('✅ อัปโหลดสำเร็จ: ${updatedAttachment.approveDocuments?.first.approveAttachment!.uuid}');
//                                                                                                               Dialog_success(context, 'อัปโหลดสำเร็จ');
//                                                                                                             } else {
//                                                                                                               //print('❌ การอัปโหลดล้มเหลว: ${response.statusCode}');
//                                                                                                               Dialog_error(context, 'การอัปโหลดล้มเหลว');
//                                                                                                             }
//                                                                                                           } else {
//                                                                                                             Dialog_error(context, 'ไม่พบ ID สำหรับ ${admin_imgpeople.nameTh ?? "-"}');
//                                                                                                           }
//                                                                                                         },
//                                                                                                         child: Padding(
//                                                                                                           padding: const EdgeInsets.all(4.0),
//                                                                                                           child: Translate.TranslateAndSet_TextAutoSize(
//                                                                                                             'Upload อีกครั้ง',
//                                                                                                             ChaoAreaScreen_Color.Colors_Text3_,
//                                                                                                             TextAlign.center,
//                                                                                                             null,
//                                                                                                             FontWeight_.Fonts_T,
//                                                                                                             10,
//                                                                                                             12,
//                                                                                                             1,
//                                                                                                           ),
//                                                                                                         ),
//                                                                                                       )))
//                                                                                           ],
//                                                                                         ),
//                                                                                       ),
//                                                                                     ]),
//                                                                             ),
//                                                                             // วันที่
//                                                                             Align(
//                                                                               alignment: Alignment.center,
//                                                                               child: AutoSizeText(
//                                                                                 (admin_imgpeople.approveAttachment.isNull) ? '' : '${DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.parse('${admin_imgpeople.approveAttachment!.createdAt!}'))}',

//                                                                                 //  admin_imgpeople.approveAttachment!.createdAt ?? '',
//                                                                                 minFontSize: 12,
//                                                                                 maxFontSize: 16,
//                                                                                 maxLines: 1,
//                                                                                 textAlign: TextAlign.center,
//                                                                                 style: TextStyle(color: PeopleChaoScreen_Color.Colors_Text2_, fontFamily: Font_.Fonts_T),
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                   ],
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                 Padding(
//                                                   padding:
//                                                       const EdgeInsets.all(0.0),
//                                                   child: Row(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8.0),
//                                                         child: Icon(
//                                                           Icons.info,
//                                                           size: 18,
//                                                         ),
//                                                       ),
//                                                       Expanded(
//                                                         child: AutoSizeText(
//                                                           minFontSize: 12,
//                                                           maxFontSize: 16,
//                                                           maxLines: 1,
//                                                           'โปรดแนบรูปเอกสารหลักฐานการตรวจสอบข้อเท็จจริงก่อนดำเนินการยืนยันเอกสารถูกต้อง',
//                                                           textAlign:
//                                                               TextAlign.left,
//                                                           overflow: TextOverflow
//                                                               .ellipsis,
//                                                           style: TextStyle(
//                                                               color: PeopleChaoScreen_Color
//                                                                   .Colors_Text2_,
//                                                               fontFamily: Font_
//                                                                   .Fonts_T),
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                           SizedBox(
//                                             height: 40,
//                                           ),
//                                           if (widget.viewver == false)
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment
//                                                       .spaceBetween,
//                                               children: [
//                                                 SizedBox(
//                                                   width: 200,
//                                                   child: ElevatedButton(
//                                                     style: ButtonStyle(
//                                                       backgroundColor:
//                                                           MaterialStateProperty
//                                                               .all<Color>(
//                                                         const Color.fromARGB(
//                                                             255, 243, 131, 130),
//                                                       ),
//                                                     ),
//                                                     onPressed: () async {
//                                                       generateRandomString();
//                                                       Cancel_showDialog();
//                                                     },
//                                                     // onPressed: () async {
//                                                     //   SharedPreferences
//                                                     //       preferences =
//                                                     //       await SharedPreferences
//                                                     //           .getInstance();
//                                                     //   String? _route = preferences
//                                                     //       .getString('route');
//                                                     //   MaterialPageRoute
//                                                     //       materialPageRoute =
//                                                     //       MaterialPageRoute(
//                                                     //           builder: (BuildContext
//                                                     //                   context) =>
//                                                     //               AdminScafScreen(
//                                                     //                   route:
//                                                     //                       'ใบอนุญาต'));
//                                                     //   Navigator
//                                                     //       .pushAndRemoveUntil(
//                                                     //           context,
//                                                     //           materialPageRoute,
//                                                     //           (route) => false);
//                                                     // },
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: Translate
//                                                           .TranslateAndSet_TextAutoSize(
//                                                               'ปฏิเสธคำร้อง',
//                                                               ChaoAreaScreen_Color
//                                                                   .Colors_Text2_,
//                                                               TextAlign.center,
//                                                               null,
//                                                               FontWeight_
//                                                                   .Fonts_T,
//                                                               12,
//                                                               18,
//                                                               1),
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                   width: 200,
//                                                   child: ElevatedButton(
//                                                     style: ButtonStyle(
//                                                       backgroundColor:
//                                                           MaterialStateProperty
//                                                               .all<Color>(
//                                                         // Colors.black,
//                                                         (totalAttachments < 3)
//                                                             ? Colors
//                                                                 .grey // 👉 disable ถ้ามีอย่างน้อย 1 ที่ไม่เป็น null
//                                                             : Colors.black,
//                                                       ),
//                                                     ),
//                                                     onPressed:
//                                                         // isAllRequiredAttached
//                                                         //     ? null
//                                                         //     :
//                                                         () async {
//                                                       if (totalAttachments >
//                                                           2) {
//                                                         setState(() {
//                                                           ser_tap = 2;
//                                                         });
//                                                       } else {
//                                                         Dialog_error(context,
//                                                             'กรุณาตรวจสอบเอกสารให้ถ฿กต้องครบถ้วน');
//                                                       }
//                                                     },
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                               8.0),
//                                                       child: Translate
//                                                           .TranslateAndSet_TextAutoSize(
//                                                               'ยืนยัน/ถัดไป',
//                                                               ChaoAreaScreen_Color
//                                                                   .Colors_Text3_,
//                                                               TextAlign.center,
//                                                               null,
//                                                               FontWeight_
//                                                                   .Fonts_T,
//                                                               12,
//                                                               18,
//                                                               1),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             )
//                                         ]),
//                                       ),
//                                     ),
//                                   ],
//                                 )))),
//                   )
//                 ]),
//               ),
//             ));
//   }

//   Form_Person(context) {
//     return SizedBox(
//         child: Column(children: [
//       // for (var person
//       //     in data_person)
//       for (int index = 0; index < data_person.length; index++)
//         Padding(
//           padding: const EdgeInsets.all(2.0),
//           child: SizedBox(
//             height: (index + 1 == data_person.length) ? null : 40,
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     padding: const EdgeInsets.all(2.0),
//                     child: AutoSizeText(
//                       minFontSize: 12,
//                       maxFontSize: 16,
//                       maxLines: 1,
//                       '${data_person[index].title}',
//                       textAlign: TextAlign.left,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                           color: PeopleChaoScreen_Color.Colors_Text2_,
//                           fontFamily: Font_.Fonts_T),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Container(
//                     padding: const EdgeInsets.all(2.0),
//                     child: TextFormField(
//                       textAlign: TextAlign.left,
//                       keyboardType: TextInputType.number,
//                       showCursor: false,
//                       readOnly: true,
//                       controller: _controllers_person[index],
//                       maxLines: (index + 1 == data_person.length) ? 3 : 1,
//                       // validator:
//                       //     (value) {
//                       //   if (value ==
//                       //           null ||
//                       //       value
//                       //           .isEmpty) {
//                       //     return '';
//                       //   }
//                       //   return null;
//                       // },
//                       // initialValue:
//                       //     '${person["detail"]}',
//                       onFieldSubmitted: (value) async {},

//                       decoration: InputDecoration(
//                           fillColor: Colors.white.withOpacity(0.3),
//                           filled: true,
//                           focusedBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(6)),
//                             borderSide: BorderSide(
//                               width: 1,
//                               color: Colors.black,
//                             ),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(Radius.circular(6)),
//                             borderSide: BorderSide(
//                               width: 1,
//                               color: Colors.grey,
//                               // color: (_controllers_person[index].text == null || _controllers_person[index].text.toString() == '')
//                               //     ? Colors.red
//                               //     : Colors.grey,
//                             ),
//                           ),
//                           // labelText: 'ระบุชื่อร้านค้า',
//                           labelStyle: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.black54,
//                               fontFamily: Font_.Fonts_T)),
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
//               ],
//             ),
//           ),
//         ),
//     ]));
//   }

//   Form_Shop(context) {
//     return SizedBox(
//         child: Column(children: [
//       // for (var shop in data_shop)
//       for (int shop = 0; shop < data_shop.length; shop++)
//         Padding(
//           padding: const EdgeInsets.all(2.0),
//           child: SizedBox(
//             height: (data_shop[shop].ser.toString() == '1') ? 150 : 40,
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     padding: const EdgeInsets.all(2.0),
//                     child: AutoSizeText(
//                       minFontSize: 12,
//                       maxFontSize: 16,
//                       maxLines: 1,
//                       '${data_shop[shop].title}*',
//                       textAlign: TextAlign.left,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                           color: PeopleChaoScreen_Color.Colors_Text2_,
//                           fontFamily: Font_.Fonts_T),
//                     ),
//                   ),
//                 ),
//                 (data_shop[shop].ser.toString() == '1')
//                     ? Expanded(
//                         flex: 2,
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 for (int shop_sub = 0;
//                                     shop_sub <
//                                         data_shop[shop].detailsub.length - 1;
//                                     shop_sub++)
//                                   // for (var shop_sub
//                                   //     in data_shop[shop]
//                                   //         [
//                                   //         "detailsub"])
//                                   Expanded(
//                                     flex: 1,
//                                     child: Container(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: TextFormField(
//                                         textAlign: TextAlign.left,
//                                         keyboardType: TextInputType.number,
//                                         showCursor: false,
//                                         readOnly: true,
//                                         controller:
//                                             _controllers_shop_sub[shop_sub],
//                                         maxLines: 1,
//                                         // style: TextStyle(
//                                         //     overflow: TextOverflow.ellipsis),
//                                         // initialValue:
//                                         //     '${shop_sub["detail"]}',
//                                         onFieldSubmitted: (value) async {},

//                                         decoration: InputDecoration(
//                                             fillColor:
//                                                 Colors.white.withOpacity(0.3),
//                                             filled: true,
//                                             focusedBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(6)),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             enabledBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(6)),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             labelText:
//                                                 '${data_shop[shop].detailsub[shop_sub].titlesub}',
//                                             labelStyle: const TextStyle(
//                                                 fontSize: 16,
//                                                 color: Colors.black,
//                                                 fontFamily: Font_.Fonts_T)),
//                                         // inputFormatters: <TextInputFormatter>[
//                                         //   // for below version 2 use this
//                                         //   FilteringTextInputFormatter
//                                         //       .allow(RegExp(r'[0-9]')),
//                                         //   // for version 2 and greater youcan also use this
//                                         //   FilteringTextInputFormatter
//                                         //       .digitsOnly
//                                         // ],
//                                       ),
//                                     ),
//                                   )
//                               ],
//                             ),
//                             SizedBox(
//                               height: 10,
//                             ),
//                             Row(
//                               children: [
//                                 for (int shop_sub = 2;
//                                     shop_sub < data_shop[shop].detailsub.length;
//                                     shop_sub++)
//                                   // for (var shop_sub
//                                   //     in data_shop[shop]
//                                   //         [
//                                   //         "detailsub"])
//                                   Expanded(
//                                     flex: 1,
//                                     child: Container(
//                                       padding: const EdgeInsets.all(2.0),
//                                       child: TextFormField(
//                                         textAlign: TextAlign.left,
//                                         keyboardType: TextInputType.number,
//                                         showCursor: false,
//                                         readOnly: true,
//                                         controller:
//                                             _controllers_shop_sub[shop_sub],
//                                         maxLines: 1,
//                                         // style: TextStyle(
//                                         //     overflow: TextOverflow.ellipsis),
//                                         // initialValue:
//                                         //     '${shop_sub["detail"]}',
//                                         onFieldSubmitted: (value) async {},

//                                         decoration: InputDecoration(
//                                             fillColor:
//                                                 Colors.white.withOpacity(0.3),
//                                             filled: true,
//                                             focusedBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(6)),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.black,
//                                               ),
//                                             ),
//                                             enabledBorder:
//                                                 const OutlineInputBorder(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(6)),
//                                               borderSide: BorderSide(
//                                                 width: 1,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                             labelText:
//                                                 '${data_shop[shop].detailsub[shop_sub].titlesub}',
//                                             labelStyle: const TextStyle(
//                                                 fontSize: 16,
//                                                 color: Colors.black,
//                                                 fontFamily: Font_.Fonts_T)),
//                                         // inputFormatters: <TextInputFormatter>[
//                                         //   // for below version 2 use this
//                                         //   FilteringTextInputFormatter
//                                         //       .allow(RegExp(r'[0-9]')),
//                                         //   // for version 2 and greater youcan also use this
//                                         //   FilteringTextInputFormatter
//                                         //       .digitsOnly
//                                         // ],
//                                       ),
//                                     ),
//                                   )
//                               ],
//                             )
//                           ],
//                         ),
//                       )
//                     : Expanded(
//                         flex: 2,
//                         child: Container(
//                           padding: const EdgeInsets.all(2.0),
//                           child: TextFormField(
//                             textAlign: TextAlign.left,
//                             keyboardType: TextInputType.number,
//                             showCursor: false,
//                             readOnly: true,
//                             controller: _controllers_shop[shop],
//                             style: TextStyle(overflow: TextOverflow.ellipsis),
//                             //   initialValue:

//                             // '${shop["detail"]}',
//                             onFieldSubmitted: (value) async {},

//                             decoration: InputDecoration(
//                                 fillColor: Colors.white.withOpacity(0.3),
//                                 filled: true,
//                                 focusedBorder: const OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(6)),
//                                   borderSide: BorderSide(
//                                     width: 1,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 enabledBorder: const OutlineInputBorder(
//                                   borderRadius:
//                                       BorderRadius.all(Radius.circular(6)),
//                                   borderSide: BorderSide(
//                                     width: 1,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 // labelText: 'ระบุชื่อร้านค้า',
//                                 labelStyle: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.black54,
//                                     fontFamily: Font_.Fonts_T)),
//                             // inputFormatters: <TextInputFormatter>[
//                             //   // for below version 2 use this
//                             //   FilteringTextInputFormatter
//                             //       .allow(RegExp(r'[0-9]')),
//                             //   // for version 2 and greater youcan also use this
//                             //   FilteringTextInputFormatter
//                             //       .digitsOnly
//                             // ],
//                           ),
//                         ),
//                       )
//               ],
//             ),
//           ),
//         ),
//     ]));
//   }
//   // Form_Shop(context) {
//   //   return SizedBox(
//   //       child: Column(children: [
//   //     // for (var shop in data_shop)
//   //     for (int shop = 0; shop < data_shop.length; shop++)
//   //       Padding(
//   //         padding: const EdgeInsets.all(2.0),
//   //         child: SizedBox(
//   //           height: 40,
//   //           child: Row(
//   //             children: [
//   //               Expanded(
//   //                 flex: 1,
//   //                 child: Container(
//   //                   padding: const EdgeInsets.all(2.0),
//   //                   child: AutoSizeText(
//   //                     minFontSize: 12,
//   //                     maxFontSize: 16,
//   //                     maxLines: 1,
//   //                     '${data_shop[shop].title}*',
//   //                     textAlign: TextAlign.left,
//   //                     overflow: TextOverflow.ellipsis,
//   //                     style: TextStyle(
//   //                         color: PeopleChaoScreen_Color.Colors_Text2_,
//   //                         fontFamily: Font_.Fonts_T),
//   //                   ),
//   //                 ),
//   //               ),
//   //               (data_shop[shop].ser.toString() == '1')
//   //                   ? Expanded(
//   //                       flex: 2,
//   //                       child: Row(
//   //                         children: [
//   //                           for (int shop_sub = 0;
//   //                               shop_sub < data_shop[shop].detailsub.length;
//   //                               shop_sub++)
//   //                             // for (var shop_sub
//   //                             //     in data_shop[shop]
//   //                             //         [
//   //                             //         "detailsub"])
//   //                             Expanded(
//   //                               flex: 1,
//   //                               child: Container(
//   //                                 padding: const EdgeInsets.all(2.0),
//   //                                 child: TextFormField(
//   //                                   textAlign: TextAlign.left,
//   //                                   keyboardType: TextInputType.number,
//   //                                   showCursor: false,
//   //                                   readOnly: true,
//   //                                   controller: _controllers_shop_sub[shop_sub],
//   //                                   // initialValue:
//   //                                   //     '${shop_sub["detail"]}',
//   //                                   onFieldSubmitted: (value) async {},

//   //                                   decoration: InputDecoration(
//   //                                       fillColor:
//   //                                           Colors.white.withOpacity(0.3),
//   //                                       filled: true,
//   //                                       focusedBorder: const OutlineInputBorder(
//   //                                         borderRadius: BorderRadius.all(
//   //                                             Radius.circular(6)),
//   //                                         borderSide: BorderSide(
//   //                                           width: 1,
//   //                                           color: Colors.black,
//   //                                         ),
//   //                                       ),
//   //                                       enabledBorder: const OutlineInputBorder(
//   //                                         borderRadius: BorderRadius.all(
//   //                                             Radius.circular(6)),
//   //                                         borderSide: BorderSide(
//   //                                           width: 1,
//   //                                           color: Colors.grey,
//   //                                         ),
//   //                                       ),
//   //                                       labelText:
//   //                                           '${data_shop[shop].detailsub[shop_sub].titlesub}',
//   //                                       labelStyle: const TextStyle(
//   //                                           fontSize: 16,
//   //                                           color: Colors.black,
//   //                                           fontFamily: Font_.Fonts_T)),
//   //                                   // inputFormatters: <TextInputFormatter>[
//   //                                   //   // for below version 2 use this
//   //                                   //   FilteringTextInputFormatter
//   //                                   //       .allow(RegExp(r'[0-9]')),
//   //                                   //   // for version 2 and greater youcan also use this
//   //                                   //   FilteringTextInputFormatter
//   //                                   //       .digitsOnly
//   //                                   // ],
//   //                                 ),
//   //                               ),
//   //                             )
//   //                         ],
//   //                       ),
//   //                     )
//   //                   : Expanded(
//   //                       flex: 2,
//   //                       child: Container(
//   //                         padding: const EdgeInsets.all(2.0),
//   //                         child: TextFormField(
//   //                           textAlign: TextAlign.left,
//   //                           keyboardType: TextInputType.number,
//   //                           showCursor: false,
//   //                           readOnly: true,
//   //                           controller: _controllers_shop[shop],
//   //                           //   initialValue:

//   //                           // '${shop["detail"]}',
//   //                           onFieldSubmitted: (value) async {},

//   //                           decoration: InputDecoration(
//   //                               fillColor: Colors.white.withOpacity(0.3),
//   //                               filled: true,
//   //                               focusedBorder: const OutlineInputBorder(
//   //                                 borderRadius:
//   //                                     BorderRadius.all(Radius.circular(6)),
//   //                                 borderSide: BorderSide(
//   //                                   width: 1,
//   //                                   color: Colors.black,
//   //                                 ),
//   //                               ),
//   //                               enabledBorder: const OutlineInputBorder(
//   //                                 borderRadius:
//   //                                     BorderRadius.all(Radius.circular(6)),
//   //                                 borderSide: BorderSide(
//   //                                   width: 1,
//   //                                   color: Colors.grey,
//   //                                 ),
//   //                               ),
//   //                               // labelText: 'ระบุชื่อร้านค้า',
//   //                               labelStyle: const TextStyle(
//   //                                   fontSize: 14,
//   //                                   color: Colors.black54,
//   //                                   fontFamily: Font_.Fonts_T)),
//   //                           // inputFormatters: <TextInputFormatter>[
//   //                           //   // for below version 2 use this
//   //                           //   FilteringTextInputFormatter
//   //                           //       .allow(RegExp(r'[0-9]')),
//   //                           //   // for version 2 and greater youcan also use this
//   //                           //   FilteringTextInputFormatter
//   //                           //       .digitsOnly
//   //                           // ],
//   //                         ),
//   //                       ),
//   //                     )
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //   ]));
//   // }

//   Form_Cid(context) {
//     return SizedBox(
//         child: Column(children: [
//       for (var cid in data_cid)
//         Padding(
//           padding: const EdgeInsets.all(2.0),
//           child: SizedBox(
//             height: 40,
//             child: Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     padding: const EdgeInsets.all(2.0),
//                     child: AutoSizeText(
//                       minFontSize: 12,
//                       maxFontSize: 16,
//                       maxLines: 1,
//                       '${cid["title"]}*',
//                       textAlign: TextAlign.left,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                           color: PeopleChaoScreen_Color.Colors_Text2_,
//                           fontFamily: Font_.Fonts_T),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: InkWell(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         // color: Colors.green,
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(6),
//                           topRight: Radius.circular(6),
//                           bottomLeft: Radius.circular(6),
//                           bottomRight: Radius.circular(6),
//                         ),
//                         border: Border.all(color: Colors.grey, width: 1),
//                       ),
//                       padding: const EdgeInsets.all(4.0),
//                       child: AutoSizeText(
//                         minFontSize: 12,
//                         maxFontSize: 16,
//                         maxLines: 1,
//                         (cid["ser"].toString() == '3' ||
//                                 cid["ser"].toString() == '4')
//                             ? '${cid["detail"]}'
//                             : '${formatDate('${cid["detail"]}', type: DateFormatType.dmy)}',
//                         textAlign: TextAlign.left,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             color: PeopleChaoScreen_Color.Colors_Text2_,
//                             fontFamily: Font_.Fonts_T),
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//     ]));
//   }

//   Widget _buildWatermarkOverlay() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         final height = constraints.maxHeight;

//         List<Widget> watermarks = [];

//         for (double y = 0; y < height; y += 200) {
//           for (double x = 0; x < width; x += 300) {
//             watermarks.add(Positioned(
//               left: x,
//               top: y,
//               child: Transform.rotate(
//                 angle: -0.4,
//                 child: Opacity(
//                   opacity: 0.08,
//                   child: Text(
//                     'Chaoperty',
//                     style: TextStyle(
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black.withOpacity(0.8),
//                     ),
//                   ),
//                 ),
//               ),
//             ));
//           }
//         }

//         return Stack(children: watermarks);
//       },
//     );
//   }

//   String randomString = '';
//   final Pincontroller = TextEditingController();
//   generateRandomString() {
//     setState(() {
//       randomString = '';
//     });
//     final random = Random();
//     const characters = '0123456789';
//     final length = 2; // Change this to the desired length

//     for (int i = 0; i < length; i++) {
//       final index = random.nextInt(characters.length);
//       randomString += characters[index];
//     }

//     // return randomString;
//   }

//   String comment = '';

//   bool _busy = false;
//   void _toast(String msg) {
//     if (!mounted) return;
//     final sm = ScaffoldMessenger.maybeOf(context);
//     sm?.showSnackBar(SnackBar(content: Text(msg)));
//   }

//   Future<Null> Cancel_showDialog() async {
//     List<Map<String, dynamic>> data_user_cancel = [
//       // {
//       //   "ser": "1",
//       //   "title": "วันที่ตรวจสอบ",
//       //   "detail": "04-05-2025",
//       // },
//       {
//         "ser": "1",
//         "title": "เหตุผลที่ปฏิเสธ",
//         "detail": "",
//       },
//       // {
//       //   "ser": "3",
//       //   "title": "ชื่อผู้ตรวจสอบ",
//       //   "detail": "นางสาวเชียงราย พะเยา",
//       // },
//     ];
//     return showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) => StatefulBuilder(
//                 // stream: Stream.periodic(const Duration(seconds: 0)),
//                 builder: (context, snapshot) {
//               return AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
//                 titlePadding: const EdgeInsets.all(0.0),
//                 contentPadding: const EdgeInsets.all(10.0),
//                 actionsPadding: const EdgeInsets.all(6.0),
//                 title: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.all(4.0),
//                         child: Icon(Icons.highlight_off,
//                             size: 30, color: Colors.red[700]),
//                       ),
//                     ),
//                   ],
//                 ),
//                 content: SingleChildScrollView(
//                   child: ListBody(
//                     children: <Widget>[
//                       for (int index = 0;
//                           index < data_user_cancel.length;
//                           index++)
//                         Padding(
//                           padding: const EdgeInsets.all(4.0),
//                           child: SizedBox(
//                             width: 300,
//                             // height: 80,
//                             child: Column(
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(4.0),
//                                   child: Translate.TranslateAndSet_TextAutoSize(
//                                       '${data_user_cancel[index]["title"]}',
//                                       ChaoAreaScreen_Color.Colors_Text2_,
//                                       TextAlign.center,
//                                       null,
//                                       FontWeight_.Fonts_T,
//                                       12,
//                                       18,
//                                       1),
//                                 ),
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(4, 4, 4, 4),
//                                   child: Container(
//                                     height: 60,
//                                     child: TextFormField(
//                                       // scrollPadding: const EdgeInsets.all(1.0),
//                                       autofocus: true,
//                                       readOnly: false,
//                                       // focusNode: myFocusNode,
//                                       textAlign: TextAlign.left,
//                                       keyboardType: TextInputType.number,
//                                       maxLines: 3,
//                                       // controller: FormMeter_text,
//                                       // validator: (value) {
//                                       //   try {
//                                       //     if (value == null || value.isEmpty) {
//                                       //       return 'กรุณากรอกค่า';
//                                       //     }

//                                       //     final input = int.parse(value);
//                                       //     final indexx = int.parse(row['index'].toString());
//                                       //     final oldValue = int.parse(
//                                       //         transMeterModels[indexx].ovalue.toString());

//                                       //     if (input < oldValue) {
//                                       //       return 'ค่าต้องไม่น้อยกว่า $oldValue';
//                                       //     }
//                                       //   } catch (e) {
//                                       //     return 'รูปแบบไม่ถูกต้อง';
//                                       //   }

//                                       //   return null;
//                                       // },
//                                       // maxLength: 13,
//                                       initialValue:
//                                           '${data_user_cancel[index]["detail"]}',
//                                       onChanged: (value) {
//                                         setState(() {
//                                           comment = value.toString().trim();
//                                         });
//                                       },

//                                       cursorColor: Colors.green,
//                                       decoration: InputDecoration(
//                                           fillColor:
//                                               Colors.white.withOpacity(0.3),
//                                           filled: true,
//                                           // prefixIcon: const Icon(
//                                           //     Icons
//                                           //         .electrical_services,
//                                           //     color: Colors.red),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(6)),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.green.shade800,
//                                             ),
//                                           ),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                                 Radius.circular(6)),
//                                             borderSide: BorderSide(
//                                               width: 1,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                           // labelText: 'เลขมิเตอร์',
//                                           labelStyle: const TextStyle(
//                                             color: ManageScreen_Color
//                                                 .Colors_Text2_,
//                                             // fontWeight:
//                                             //     FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T,
//                                           )),
//                                       inputFormatters: <TextInputFormatter>[
//                                         FilteringTextInputFormatter.deny(
//                                             RegExp("[' ']")),
//                                         // for below version 2 use this
//                                         // FilteringTextInputFormatter.allow(
//                                         //     RegExp(r'[0-9 .]')),
//                                         // for version 2 and greater youcan also use this
//                                         // FilteringTextInputFormatter
//                                         //     .digitsOnly
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: SizedBox(
//                           child: Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Container(
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       const Text(
//                                         'CODE : ',
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontFamily: Font_.Fonts_T),
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.all(2),
//                                         child: Container(
//                                           decoration: const BoxDecoration(
//                                             borderRadius: BorderRadius.only(
//                                                 topLeft: Radius.circular(10),
//                                                 topRight: Radius.circular(10),
//                                                 bottomLeft: Radius.circular(10),
//                                                 bottomRight:
//                                                     Radius.circular(10)),
//                                             color: Color.fromARGB(
//                                                 255, 179, 177, 170),
//                                             // image:
//                                             //     const DecorationImage(
//                                             //   image: AssetImage(
//                                             //       "assets/pngegg2.png"),
//                                             //   fit: BoxFit
//                                             //       .cover,
//                                             // ),
//                                           ),
//                                           width: 65,
//                                           // color: Colors.black,
//                                           padding: const EdgeInsets.all(2.0),
//                                           child: Center(
//                                             child: Text(
//                                               '${randomString}',
//                                               style: TextStyle(
//                                                   color: Colors.red[800],
//                                                   fontWeight: FontWeight.bold,
//                                                   fontFamily: Font_.Fonts_T),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(4.0),
//                                 child: Center(
//                                   child: Container(
//                                     height: 40,
//                                     width: 90,
//                                     child: PinCode(
//                                       keyboardType: TextInputType.number,
//                                       numberOfFields: 2,
//                                       fieldWidth: 40.0,
//                                       style: const TextStyle(
//                                         fontFamily: Font_.Fonts_T,
//                                         color: Colors.black,
//                                       ),
//                                       fieldStyle: PinCodeStyle.box,
//                                       onChanged: (value) {
//                                         setState(() {
//                                           Pincontroller.text = value.trim();
//                                         });
//                                       },
//                                       onCompleted: (text) {
//                                         setState(() {
//                                           Pincontroller.text = text.trim();
//                                         });
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 actions: [
//                   StreamBuilder(
//                       stream: Stream.periodic(const Duration(seconds: 0)),
//                       builder: (context, snapshot) {
//                         return Container(
//                           height: 50,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: SizedBox(
//                                   width: 200,
//                                   child: ElevatedButton(
//                                     style: ButtonStyle(
//                                       backgroundColor:
//                                           MaterialStateProperty.all<Color>(
//                                         (comment == '' ||
//                                                 Pincontroller.text !=
//                                                     randomString.toString())
//                                             ? Colors.grey
//                                             : Colors.black,
//                                         // Colors.black,
//                                       ),
//                                     ),
//                                     onPressed: (comment == '')
//                                         ? null
//                                         : () async {
//                                             onRejectTap();
//                                           },
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Translate
//                                           .TranslateAndSet_TextAutoSize(
//                                               'ยืนยัน',
//                                               ChaoAreaScreen_Color
//                                                   .Colors_Text3_,
//                                               TextAlign.center,
//                                               null,
//                                               FontWeight_.Fonts_T,
//                                               12,
//                                               18,
//                                               1),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       })
//                 ],
//               );
//             }));
//   }

//   Future<void> onRejectTap() async {
//     if (_busy) return; // กันกดซ้ำ
//     _busy = true;
//     Dia_log1(context);
//     try {
//       // 1) โหลดลายเซ็นผู้อนุมัติ
//       final respSig = await read_AdminSignature();
//       if (respSig == null || respSig.statusCode != 200) {
//         _toast('โหลดข้อมูลลายเซ็นไม่สำเร็จ');
//         return;
//       }

//       final sigJson = jsonDecode(respSig.body);
//       if (sigJson is! Map || sigJson['data'] is! Map) {
//         _toast('รูปแบบข้อมูลลายเซ็นไม่ถูกต้อง');
//         return;
//       }
//       final sigData = sigJson['data'] as Map;
//       final profileId = sigData['profile_uuid']?.toString();
//       final profileName = sigData['profile']?.toString();
//       final sigUuid = sigData['signature_uuid']?.toString();
//       final positionName = sigData['position_name']?.toString();
//       //print(profileId);
//       //print(sigUuid);

//       if (profileId == null || sigUuid == null) {
//         _toast('ข้อมูลผู้ลงนามไม่ครบ');
//         return;
//       }
//       Future.delayed(const Duration(seconds: 1), () async {
//         // 2) โหลด Reviews Flow
//         final respFlow =
//             await read_GC_ReviewsFlowUuid(UuidRequest: '$requestUuid');
//         if (respFlow == null || respFlow.statusCode != 200) {
//           _toast('โหลดข้อมูลการอนุมัติไม่สำเร็จ');
//           return;
//         }

//         final flowJson = jsonDecode(respFlow.body);
//         if (flowJson is! Map || flowJson['data'] is! Map) {
//           _toast('รูปแบบข้อมูลการอนุมัติไม่ถูกต้อง');
//           return;
//         }
//         final data = flowJson['data'] as Map;
//         final requests =
//             (data['request'] is Map) ? data['request'] as Map : const {};
//         final triggeredUuid = data['triggered_approval_uuid']?.toString();
//         final reqUuid = requests['uuid']?.toString();

//         if (triggeredUuid == null || reqUuid == null) {
//           _toast('ข้อมูลคำขอไม่ครบ');
//           return;
//         }

//         // 3) เรียก API Reject
//         final ok = await POST_Reject(
//           requestUuid: reqUuid,
//           flowUid: triggeredUuid,
//           profileUuid: profileId,
//           signUuid: sigUuid,
//           comMent: '$comment',
//         );

//         // ถ้า POST_Reject ไม่มี bool ให้เช็ก ให้ดูจาก status/throw ของมันแทน
//         if (ok == false) {
//           _toast('ยกเลิกคำขอไม่สำเร็จ');
//           return;
//         }
//         if (ok!.statusCode == 200 || ok.statusCode == 201) {
//           // 4) นำทางกลับหน้าหลัก (เช็ค mounted ให้ครบ)
//           if (!mounted) return;

//           final prefs = await SharedPreferences.getInstance();
//           final routePref = prefs.getString('route'); // ถ้าจะใช้จริง

//           // ใช้ post-frame เพื่อลดโอกาสชน build ขณะ pop/push
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (!mounted) return;
//             Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(
//                 builder: (_) => AdminScafScreen(route: 'ใบอนุญาต'),
//               ),
//               (r) => false,
//             );
//           });
//         } else {
//           final okJson = jsonDecode(ok.body);
//           Dialog_error(context, '${okJson['message']}');
//           return;
//         }
//       });
//     } catch (e, st) {
//       // debug//print('ReviewsFlowUuid error: $e\n$st');
//       _toast('พบข้อผิดพลาด โปรดลองอีกครั้ง');
//     } finally {
//       _busy = false;
//     }
//   }
// }
