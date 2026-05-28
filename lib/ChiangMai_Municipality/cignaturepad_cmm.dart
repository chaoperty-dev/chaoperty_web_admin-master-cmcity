import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chaoperty/ChiangMai_Municipality/unity/show_dialog_cmm.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'unity/url_preview_widget.dart';

import '../AdminScaffold/AdminScaffold.dart';
import '../Constant/Myconstant.dart';
import '../PeopleChao/Pays_.dart';
import '../Responsive/responsive.dart';
import '../Setting/Bill_Document_Template.dart';
import '../Style/Translate.dart';
import '../Style/colors.dart';
import 'Model/ReviewUuid_Model.dart';
import 'Model/Review_Model.dart';
import 'PDF_CMM/application_form1_cmm.dart';
import 'PDF_CMM/application_form2_cmm.dart';
import 'PDF_CMM/application_form3_cmm.dart';
import 'PDF_CMM/license_form_cmm.dart';
import 'PDF_CMM/receipt_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf1_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf2_cmm.dart';
import 'PDF_CMM/unity_pdf_cmm/perviewpdf_pdfMultiPreview.dart';
import 'request_examiner1_cmm.dart';
import 'request_examiner2_cmm.dart';
import 'unity/API_admin_signature.dart';
import 'unity/API_approvals_roles&checkup.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/API_requests_reviewsflow.dart';
import 'unity/SecurePrefs_helper.dart';

class SignaturePad_CMM extends StatefulWidget {
  final String? triggeredUuid;
  final String? requestUuid;

  const SignaturePad_CMM({
    super.key,
    this.triggeredUuid,
    this.requestUuid,
  });

  @override
  State<SignaturePad_CMM> createState() => _SignaturePad_CMMState();
}

class _SignaturePad_CMMState extends State<SignaturePad_CMM> {
  // ------------------ SignaturePad ------------------
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  Uint8List?
      signatureUser; // ภาพลายเซ็นที่จะประทับลงเอกสาร (จากปุ่ม "ประทับลายเซ็น")

  // ------------------ PDF ------------------
  String? _previewUrl;

  // ------------------ State/Flags ------------------
  bool isOpenApproved = false;
  bool _isSubmitting = false;
  bool _isCommentExpanded = true;
  String? requestUuid;
  String? flowUuid;
  String? triggeredUuid;

  // ------------------ UI Text ------------------
  String functionName = "GeneratePDF_1";
  String pdfName = "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ";

  // ------------------ Data ------------------
  final List<Map<String, String>> dataDocCid = [];
  final List<ReviewDetail> reviewDetail = [];

  // ------------------ Admin/Profile ------------------
  String fullNameAdmin = '';
  String positionAdmin = '';
  String profileUuid = '';
  String signatureUuid = '';
  Uint8List? signaturesUrl; // รูปลายเซ็นของแอดมิน (จาก API)

  // ------------------ Controllers ------------------
  final TextEditingController controllerFullNameAdmin = TextEditingController();
  final TextEditingController controllerPositionAdmin = TextEditingController();
  final TextEditingController controllerBecause = TextEditingController();
  String reviewSname = '';
  @override
  void initState() {
    super.initState();
    _check_main();
  }

  List<ReviewModel> reviewModels = [];

  Future<void> _check_main() async {
    final value = await SecurePrefs.getDecrypted(SecurePrefsType.approverAll);
    if (value.toString() == 'true') {
      final res = await read_GC_ApprovalsRoles(
        urlCustom: null,
        query: '',
        perPage: 100,
      );
      setState(() {
        reviewModels = res.data ?? [];
      });

      if (reviewModels.isEmpty) {
        // ไม่มีงานอนุมัติ
        return;
      }

      // bootstrap รายการแรก แล้วค่อยเปิด dialog
      await _bootstrapIndex(0);
      if (mounted) await _showApprovedDialog(context, startIndex: 0);
    } else {
      _bootstrap();
    }
  }

  /// รวมงานเตรียมข้อมูลตอนเปิดหน้าจอ
  Future<void> _bootstrapIndex(int i) async {
    try {
      if (i < 0 || i >= reviewModels.length) return;

      await SecurePrefs.setEncrypted(
        SecurePrefsType.UuidRequest,
        '${reviewModels[i].newRequest!.requestUuid}',
      );

      await _loadClientReviewsUuid();
      await Future.wait([
        _previewPdf(),
        _storedAuthData(),
        _reviewsFlowUuid(),
      ]);
      setState(() {
        // ใช้ลายเซ็นของแอดมินจาก API
        signatureUser = signaturesUrl;
      });
    } catch (e) {
      //debugprint('Bootstrap error: $e');
    }
  }

  Future<void> _bootstrap() async {
    try {
      await _loadClientReviewsUuid();
      await Future.wait([
        _previewPdf(),
        _storedAuthData(),
        _reviewsFlowUuid(),
      ]);
    } catch (e) {
      //debugprint('Bootstrap error: $e');
    }
  }

  // ------------------ LOADERS ------------------

  /// ดึง Uuid จาก SecurePrefs + รายละเอียดรีวิวและตั้งค่าชื่อไฟล์ PDF
  Future<void> _loadClientReviewsUuid() async {
    try {
      final value = await SecurePrefs.getDecrypted(SecurePrefsType.UuidRequest);
      final valueFlowUuid =
          await SecurePrefs.getDecrypted(SecurePrefsType.flowUuid);
      //print('UuidRequest : ${value}');
      //print('flowUuid : ${valueFlowUuid}');
      if (!mounted) return;
      setState(() {
        requestUuid = value;
        flowUuid = valueFlowUuid;
      });

      final response = await read_GC_ReviewsUuid(value);
      if (response == null) {
        // debugprint('read_GC_ReviewsUuid -> null response');
        return;
      }
      if (response.statusCode != 200) {
        // debugprint('read_GC_ReviewsUuid -> ${response.statusCode}');
        return;
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = ReviewDetail.fromJson(result['data']);
      final bool isOpen = (result['is_open_approved'] == true);
      setState(() {
        reviewSname = detail.client.cname.toString();
        // reviewSname = detail.client.scname.toString();
      });

      if (!mounted) return;
      setState(() {
        isOpenApproved = isOpen;
        reviewDetail.add(detail);
        pdfName =
            "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ($reviewSname)";

        dataDocCid
          ..clear()
          ..addAll([
            {"ser": "1", "title": pdfName, "detail": "GeneratePDF_1"},
            {
              "ser": "2",
              "title":
                  "ใบพิจารณาคำขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ($reviewSname)",
              "detail": "GeneratePDF_2"
            },
            {
              "ser": "3",
              "title": "ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ($reviewSname)",
              "detail": "GeneratePDF_3"
            },
          ]);
      });
    } catch (e) {
      // debugprint('❌ Error parsing review data: $e');
    }
  }

  List<String> Flow_Because = [];
  List<String> Flow_ApprovedBy = [];

  /// ดึง Flow/Triggered UUID
  Future<void> _reviewsFlowUuid() async {
    try {
      final response =
          await read_GC_ReviewsFlowUuid(UuidRequest: '${requestUuid}');
      if (response == null || response.statusCode != 200) return;

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final data = result['data'] as Map<String, dynamic>;
      final requests = data['request'] as Map<String, dynamic>;
// 1. ดึงข้อมูล flows ออกมาเป็น List ของ Map
      final List<dynamic> flowsList = data['flows'] as List<dynamic>;

      Flow_Because.clear();
      Flow_ApprovedBy.clear();

// 2. วนลูปเช็ค comment ของแต่ละขั้นตอน
      for (var item in flowsList) {
        final comment = item['comment'];
        // ใช้ ?? '' เพื่อป้องกันกรณี approved_by เป็น null จะได้ไม่แสดงคำว่า 'null' ออกมา
        String approvedBy =
            item['approved_by']?.toString().trim() ?? 'ไม่ระบุชื่อ';

        // จัดการเคสพิเศษ เช่น ลบเครื่องหมายขีด (-) ข้างหน้าชื่อออก ถ้ามี
        if (approvedBy.startsWith('-')) {
          approvedBy = approvedBy.substring(1).trim();
        }

        // ตรวจสอบว่ามีคอมเมนต์จริง ไม่เป็น null และไม่เป็นค่าว่าง
        if (comment != null && comment.toString().trim().isNotEmpty) {
          String commentText = '" ${comment.toString().trim()} "';
          Flow_Because.add(commentText);
          Flow_ApprovedBy.add(approvedBy);
        }
      }

      print('Flow_Because: $Flow_Because');
      print('Flow_ApprovedBy: $Flow_ApprovedBy');
      if (!mounted) return;
      setState(() {
        triggeredUuid = '${data['triggered_approval_uuid']}';
        requestUuid = '${requests['uuid']}';
      });

      // debugprint('ReviewsFlowUuid triggeredUuid : $triggeredUuid');
      // debugprint('ReviewsFlowUuid requestUuid   : $requestUuid');
    } catch (e) {
      //  debugprint('ReviewsFlowUuid error: $e');
    }
  }

  Future<void> _previewPdf() async {
    final reqUuid = widget.requestUuid ?? requestUuid ?? '';
    if (reqUuid.isEmpty || !mounted) return;
    final url =
        '${MyConstant().domain_v3}/api/preview/vendor-license-2/$reqUuid';
    print('_previewPdf url: $url');
    setState(() {
      _previewUrl = url;
    });
  }

  /// โหลดข้อมูลผู้ลงนาม + รูปลายเซ็น (bytes)
  Future<void> _storedAuthData() async {
    try {
      print('[SignaturePad] 🔄 เริ่มโหลดข้อมูลลายเซ็นแอดมิน...');
      final response = await read_AdminSignature();

      if (response == null) {
        print('[SignaturePad] ❌ read_AdminSignature returned null');
        return;
      }

      print('[SignaturePad] 📤 Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('[SignaturePad] ❌ Failed: ${response.body}');
        return;
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;
      final data = result['data'] as Map<String, dynamic>;

      final String? profileId = data['profile_uuid'];
      final String? profileName = data['profile'];
      final String? sigUuid = data['signature_uuid'];
      final String? positionName = data['position_name'];

      print('[SignaturePad] 📋 profile: $profileName, position: $positionName');
      print('[SignaturePad] 📋 signature_uuid: $sigUuid');

      // (ถ้าต้องใช้) บริบทผู้ใช้
      await SecurePrefs.getDecrypted(SecurePrefsType.authUserObject);

      // โหลดภาพลายเซ็นเป็น bytes
      Uint8List? sigBytes;
      if (sigUuid != null && sigUuid.isNotEmpty) {
        print('[SignaturePad] 🔄 โหลดรูปลายเซ็นจาก UUID: $sigUuid');
        final sigResp = await img_signatureUuid(signatureUuid: sigUuid);

        if (sigResp == null) {
          print('[SignaturePad] ❌ img_signatureUuid returned null');
        } else {
          print('[SignaturePad] 📤 Image Status: ${sigResp.statusCode}');
          if (sigResp.statusCode == 200) {
            sigBytes = sigResp.bodyBytes;
            print(
                '[SignaturePad] ✅ โหลดรูปลายเซ็นสำเร็จ: ${sigBytes!.lengthInBytes} bytes');
          } else {
            print('[SignaturePad] ❌ Failed to load image: ${sigResp.body}');
          }
        }
      } else {
        print('[SignaturePad] ⚠️ signature_uuid is null or empty');
      }

      if (!mounted) return;
      setState(() {
        profileUuid = profileId ?? '';
        signatureUuid = sigUuid ?? '';
        fullNameAdmin = profileName ?? '';
        positionAdmin = positionName ?? '';
        controllerFullNameAdmin.text = fullNameAdmin;
        controllerPositionAdmin.text = positionAdmin;
        signaturesUrl = sigBytes;
        print(
            '[SignaturePad] ✅ signaturesUrl set: ${signaturesUrl != null ? "${signaturesUrl!.lengthInBytes} bytes" : "null"}');
      });
    } catch (e, stackTrace) {
      print('[SignaturePad] ❌ StoredAuthData error: $e');
      print('[SignaturePad] 🧭 StackTrace: $stackTrace');
    }
  }

  // ------------------ SIGNATURE HANDLERS ------------------

  void _handleClearSignaturePad() {
    signatureGlobalKey.currentState?.clear();
  }

  Future<void> _handlePreviewSignaturePad() async {
    try {
      final image = await signatureGlobalKey.currentState?.toImage(
        pixelRatio: 3.0,
      );
      final bytes = await image?.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted || bytes == null) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Signature Preview')),
            body: Center(
              child: Container(
                color: Colors.grey[300],
                child: Image.memory(bytes.buffer.asUint8List()),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      // debug//print('Save signature preview error: $e');
    }
  }

  // ------------------

  Future<void> _showApprovedDialog(BuildContext context,
      {required int startIndex}) async {
    if (reviewModels.isEmpty) return;

    final screenSize = MediaQuery.of(context).size;
    const dialogWidth = 440.0;
    const topMargin = 20.0;
    const rightMargin = 20.0;

    Offset position = (screenSize.width < 600)
        ? Offset((screenSize.width - (screenSize.width * 0.95)) / 2, 60)
        : Offset(screenSize.width - dialogWidth - rightMargin, topMargin);

    int index = startIndex;
    bool submitting = false;
    bool bulkApproving = false;
    double progress = index / reviewModels.length;

    Future<bool> _approveAt(int i) async {
      if (signatureUser == null ||
          signatureUuid == null ||
          profileUuid == null) {
        Dialog_error(context, 'ไม่พบลายเซ็น/โปรไฟล์ผู้อนุมัติ');
        return false;
      }
      await _bootstrapIndex(i);
      final resp = await Post_ReviewsFlowApprove(
        requestUuid: requestUuid ?? widget.requestUuid ?? '',
        flowUuid: triggeredUuid ?? widget.triggeredUuid ?? '',
        profileUuid: profileUuid!,
        signUuid: signatureUuid!,
        comment: controllerBecause.text,
      );
      // TODO: ตรวจ resp ตามจริง
      return true;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final total = reviewModels.length;

          Widget _header() => Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ตรวจสอบและอนุมัติ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text('ถูกต้องครบถ้วน [ ${index + 1} / $total ]',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Colors.white.withOpacity(.9))),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        false, // ป้องกันกดนอกแล้วปิด
                                    builder: (context) => AlertDialog(
                                      backgroundColor:
                                          AppbackgroundColor.Sub_Abg_Colors,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      insetPadding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      titlePadding: EdgeInsets.zero,
                                      contentPadding: EdgeInsets.zero,
                                      actionsPadding: const EdgeInsets.all(8),

                                      // 🔹 ส่วนหัว Dialog
                                      title: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.shade50
                                              .withOpacity(0.5),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(16)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(Icons.book,
                                                    color: Colors.green,
                                                    size: 28),
                                                SizedBox(width: 8),
                                                Text(
                                                  'ข้อมูลเพิ่มเติม',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close,
                                                  color: Colors.redAccent,
                                                  size: 24),
                                              tooltip: 'ปิดหน้าต่าง',
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 🔹 เนื้อหาหลัก (Content)
                                      content: SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.88,
                                            minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.45,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.98),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 5),
                                                  ),
                                                ],
                                              ),
                                              child: RequestExaminer1_CMM(
                                                viewver: true, // 👈 ของคุณเดิม
                                                plugin: false,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 🔹 ปุ่มล่าง (Actions)
                                      // actions: [
                                      //   Align(
                                      //     alignment: Alignment.centerRight,
                                      //     child: TextButton.icon(
                                      //       style: TextButton.styleFrom(
                                      //         backgroundColor: Colors.red.shade50,
                                      //         padding: const EdgeInsets.symmetric(
                                      //             horizontal: 14, vertical: 8),
                                      //         shape: RoundedRectangleBorder(
                                      //           borderRadius:
                                      //               BorderRadius.circular(8),
                                      //         ),
                                      //       ),
                                      //       icon: const Icon(Icons.close,
                                      //           color: Colors.redAccent),
                                      //       label: const Text(
                                      //         'ปิดหน้าต่าง',
                                      //         style: TextStyle(
                                      //             color: Colors.redAccent,
                                      //             fontWeight: FontWeight.w600),
                                      //       ),
                                      //       onPressed: () =>
                                      //           Navigator.pop(context),
                                      //     ),
                                      //   ),
                                      // ],
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 12),
                                ),
                                icon: const Icon(Icons.book),
                                label: const Text(
                                  'ข้อมูลเพิ่มเติม',
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
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: (submitting || bulkApproving)
                          ? null
                          : () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.white),
                      tooltip: 'ปิด',
                    ),
                  ],
                ),
              );

          Widget _progressBar() => Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (submitting || bulkApproving)
                            ? progress.clamp(0, 1)
                            : progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              );

          Widget _body() => Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ผู้ยื่นคำร้อง
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_pin_circle_rounded, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('ผู้ยื่นคำร้อง: ${reviewSname ?? '-'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _progressBar(),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: -6,
                        children: [
                          Chip(
                              label: Text('ลำดับ ${index + 1}'),
                              visualDensity: VisualDensity.compact),
                          Chip(
                              label: Text('ทั้งหมด $total รายการ'),
                              visualDensity: VisualDensity.compact),
                        ],
                      ),
                    ),
                  ],
                ),
              );

          Widget _actions() => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Row(
                  children: [
                    // อนุมัติทั้งหมด
                    OutlinedButton.icon(
                      icon: bulkApproving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.done_all_rounded),
                      label: const Text('อนุมัติทั้งหมด'),
                      onPressed: (submitting || bulkApproving)
                          ? null
                          : () async {
                              setStateDialog(() {
                                bulkApproving = true;
                              });
                              try {
                                for (int i = index; i < total; i++) {
                                  final ok = await _approveAt(i);
                                  if (!ok) {
                                    Dialog_error(context,
                                        'รายการที่ ${i + 1} อนุมัติไม่สำเร็จ');
                                    break;
                                  }
                                  setStateDialog(() {
                                    index = i;
                                    progress = (i + 1) / total;
                                  });
                                  // ✅ พัก 1 วินาที ก่อนอนุมัติรายการถัดไป
                                  // await Future.delayed(
                                  //     const Duration(milliseconds: 200));   // await Future.delayed(
                                  //     const Duration(milliseconds: 200));
                                }
                                final finished = index >= total - 1;
                                if (finished) {
                                  if (!mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            AdminScafScreen(route: 'ใบอนุญาต')),
                                    (route) => false,
                                  );
                                }
                              } finally {
                                if (context.mounted)
                                  setStateDialog(() => bulkApproving = false);
                              }
                            },
                    ),
                    const Spacer(),
                    // TextButton(
                    //   onPressed: (submitting || bulkApproving)
                    //       ? null
                    //       : () => Navigator.pop(context),
                    //   child: const Text('ยกเลิก'),
                    // ),
                    const SizedBox(width: 8),
                    // ยืนยันทีละรายการ
                    ElevatedButton.icon(
                      icon: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_rounded),
                      label: const Text('ยืนยัน/ถัดไป'),
                      onPressed: (submitting || bulkApproving)
                          ? null
                          : () async {
                              setStateDialog(() => submitting = true);
                              try {
                                final ok = await _approveAt(index);
                                if (!ok) return;

                                final isLast = index >= total - 1;
                                if (isLast) {
                                  if (!mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            AdminScafScreen(route: 'ใบอนุญาต')),
                                    (route) => false,
                                  );
                                } else {
                                  setStateDialog(() {
                                    index += 1;
                                    progress = index / total;
                                  });
                                }
                              } finally {
                                if (context.mounted)
                                  setStateDialog(() => submitting = false);
                              }
                            },
                    ),
                  ],
                ),
              );

          return Stack(
            children: [
              // ลากได้
              Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onPanUpdate: (d) => setStateDialog(() => position += d.delta),
                  child: Material(
                    color: Colors.transparent,
                    elevation: 16,
                    shadowColor: Colors.black26,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: dialogWidth),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).dialogBackgroundColor,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 20,
                                  color: Colors.black26,
                                  offset: Offset(0, 10))
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _header(),
                              _body(),
                              const Divider(height: 1),
                              SizedBox(
                                height: 20,
                              ),
                              _actions(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ------------------ UI ------------------
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 16,
          ),
          child: Column(
            children: [
              // Header
              Container(
                // height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: AppbackgroundColor.TiTile_Box,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: (Responsive.isMobile(context))
                    ? Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: (Responsive.isMobile(context)) ? 80 : 100,
                              height: 40,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  MaterialPageRoute materialPageRoute =
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              AdminScafScreen(
                                                route: 'ใบอนุญาต',
                                                route_getdata: "",
                                              ));
                                  Navigator.pushAndRemoveUntil(context,
                                      materialPageRoute, (route) => false);
                                },
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: ChaoAreaScreen_Color.Colors_Text3_,
                                  ),
                                ),

                                //   (Responsive.isMobile(context))
                                // ? Center(
                                //     child: Icon(
                                //       Icons.arrow_back_ios,
                                //       color: ChaoAreaScreen_Color.Colors_Text3_,
                                //     ),
                                //   )
                                // : Translate.TranslateAndSet_TextAutoSize(
                                //     '<< ย้อนกลับ ',
                                //     ChaoAreaScreen_Color.Colors_Text3_,
                                //     TextAlign.center,
                                //     null,
                                //     FontWeight_.Fonts_T,
                                //     12,
                                //     14,
                                //     1,
                                //   ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Translate.TranslateAndSetText(
                                'รายละเอียดเอกสารสำหรับต่อสัญญา ',
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: () {
                                  int tapSer = 0;

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      final size = MediaQuery.of(context).size;

                                      final dialogWidth = size.width < 900
                                          ? size.width * 0.95
                                          : 1000.0;
                                      final dialogHeight = size.height * 0.88;

                                      return StatefulBuilder(
                                        builder: (context, setStateSB) {
                                          return Dialog(
                                            backgroundColor: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            insetPadding:
                                                const EdgeInsets.symmetric(
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
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .blueGrey.shade50
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top:
                                                            Radius.circular(16),
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
                                                                onTap: () =>
                                                                    setStateSB(() =>
                                                                        tapSer =
                                                                            0),
                                                                child:
                                                                    Container(
                                                                  width: 170,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: tapSer ==
                                                                            0
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .black54,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .list,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            22,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              6),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'ข้อมูลผู้ทำรายการ',
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () =>
                                                                    setStateSB(() =>
                                                                        tapSer =
                                                                            1),
                                                                child:
                                                                    Container(
                                                                  width: 170,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: tapSer ==
                                                                            1
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .black54,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .safety_check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            22,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              6),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'ข้อมูลข้อเท็จจริง',
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.white,
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
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.close,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 26,
                                                          ),
                                                          tooltip:
                                                              'ปิดหน้าต่าง',
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Body
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        bottom:
                                                            Radius.circular(16),
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
                                // onPressed: () {
                                //   int tapSer =
                                //       0; // จะคงอยู่ภายใน StatefulBuilder

                                //   showDialog(
                                //     context: context,
                                //     barrierDismissible: false,
                                //     builder: (context) {
                                //       return StatefulBuilder(
                                //         builder: (context, setStateSB) {
                                //           return AlertDialog(
                                //             backgroundColor: AppbackgroundColor
                                //                 .Sub_Abg_Colors,
                                //             shape: RoundedRectangleBorder(
                                //                 borderRadius:
                                //                     BorderRadius.circular(16)),
                                //             insetPadding:
                                //                 const EdgeInsets.symmetric(
                                //                     horizontal: 12,
                                //                     vertical: 10),
                                //             titlePadding: EdgeInsets.zero,
                                //             contentPadding: EdgeInsets.zero,
                                //             actionsPadding:
                                //                 const EdgeInsets.all(8),

                                //             // 🔹 ส่วนหัว
                                //             title: Container(
                                //               padding:
                                //                   const EdgeInsets.symmetric(
                                //                       horizontal: 16,
                                //                       vertical: 10),
                                //               decoration: BoxDecoration(
                                //                 color: Colors.blueGrey.shade50
                                //                     .withOpacity(0.5),
                                //                 borderRadius: const BorderRadius
                                //                         .vertical(
                                //                     top: Radius.circular(16)),
                                //               ),
                                //               child: Row(
                                //                 mainAxisAlignment:
                                //                     MainAxisAlignment
                                //                         .spaceBetween,
                                //                 children: [
                                //                   Row(
                                //                     children: [
                                //                       InkWell(
                                //                         onTap: () => setStateSB(
                                //                             () => tapSer = 0),
                                //                         child: Container(
                                //                           width: 150,
                                //                           decoration:
                                //                               BoxDecoration(
                                //                             color: (tapSer == 0)
                                //                                 ? Colors.black
                                //                                 : Colors
                                //                                     .black54,
                                //                             borderRadius:
                                //                                 const BorderRadius
                                //                                         .all(
                                //                                     Radius
                                //                                         .circular(
                                //                                             6)),
                                //                             border: Border.all(
                                //                                 color:
                                //                                     Colors.grey,
                                //                                 width: 1),
                                //                           ),
                                //                           padding:
                                //                               const EdgeInsets
                                //                                   .all(2),
                                //                           child: const Row(
                                //                             children: [
                                //                               Icon(Icons.list,
                                //                                   color: Colors
                                //                                       .white,
                                //                                   size: 25),
                                //                               SizedBox(
                                //                                   width: 4),
                                //                               Text(
                                //                                 'ข้อมูลผู้ทำรายการ',
                                //                                 style:
                                //                                     TextStyle(
                                //                                   fontSize: 16,
                                //                                   fontWeight:
                                //                                       FontWeight
                                //                                           .bold,
                                //                                   color: Colors
                                //                                       .white,
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                           ),
                                //                         ),
                                //                       ),
                                //                       const SizedBox(width: 5),
                                //                       InkWell(
                                //                         onTap: () => setStateSB(
                                //                             () => tapSer = 1),
                                //                         child: Container(
                                //                           width: 150,
                                //                           decoration:
                                //                               BoxDecoration(
                                //                             color: (tapSer == 1)
                                //                                 ? Colors.black
                                //                                 : Colors
                                //                                     .black54,
                                //                             borderRadius:
                                //                                 const BorderRadius
                                //                                         .all(
                                //                                     Radius
                                //                                         .circular(
                                //                                             6)),
                                //                             border: Border.all(
                                //                                 color:
                                //                                     Colors.grey,
                                //                                 width: 1),
                                //                           ),
                                //                           padding:
                                //                               const EdgeInsets
                                //                                   .all(2),
                                //                           child: const Row(
                                //                             children: [
                                //                               Icon(
                                //                                   Icons
                                //                                       .safety_check,
                                //                                   color: Colors
                                //                                       .white,
                                //                                   size: 25),
                                //                               SizedBox(
                                //                                   width: 4),
                                //                               Text(
                                //                                 'ข้อมูลข้อเท็จจริง', // แก้สะกด
                                //                                 style:
                                //                                     TextStyle(
                                //                                   fontSize: 16,
                                //                                   fontWeight:
                                //                                       FontWeight
                                //                                           .bold,
                                //                                   color: Colors
                                //                                       .white,
                                //                                 ),
                                //                               ),
                                //                             ],
                                //                           ),
                                //                         ),
                                //                       ),
                                //                     ],
                                //                   ),
                                //                   IconButton(
                                //                     icon: const Icon(
                                //                         Icons.close,
                                //                         color: Colors.redAccent,
                                //                         size: 26),
                                //                     tooltip: 'ปิดหน้าต่าง',
                                //                     onPressed: () =>
                                //                         Navigator.pop(context),
                                //                   ),
                                //                 ],
                                //               ),
                                //             ),

                                //             // 🔹 เนื้อหา
                                //             content: SizedBox(
                                //               child: SingleChildScrollView(
                                //                 child: ConstrainedBox(
                                //                   constraints: BoxConstraints(
                                //                     maxHeight:
                                //                         MediaQuery.of(context)
                                //                                 .size
                                //                                 .height *
                                //                             0.88,
                                //                     minWidth:
                                //                         MediaQuery.of(context)
                                //                                 .size
                                //                                 .width *
                                //                             0.45,
                                //                     minHeight:
                                //                         MediaQuery.of(context)
                                //                                 .size
                                //                                 .height *
                                //                             0.3,
                                //                     maxWidth: 1400,
                                //                   ),
                                //                   child: ClipRRect(
                                //                     borderRadius:
                                //                         BorderRadius.circular(
                                //                             12),
                                //                     child: Container(
                                //                       decoration: BoxDecoration(
                                //                         color: Colors.white
                                //                             .withOpacity(0.98),
                                //                         borderRadius:
                                //                             BorderRadius
                                //                                 .circular(12),
                                //                         boxShadow: [
                                //                           BoxShadow(
                                //                             color: Colors.black
                                //                                 .withOpacity(
                                //                                     0.05),
                                //                             blurRadius: 12,
                                //                             offset:
                                //                                 const Offset(
                                //                                     0, 5),
                                //                           ),
                                //                         ],
                                //                       ),
                                //                       child: (tapSer == 0)
                                //                           ? const RequestExaminer1_CMM(
                                //                               viewver: true)
                                //                           : const RequestExaminer2_CMM(
                                //                               viewver: true),
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             ),
                                //           );
                                //         },
                                //       );
                                //     },
                                //   );
                                // },
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
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 40,
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                ),
                                onPressed: () {
                                  int tapSer = 0;

                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      final size = MediaQuery.of(context).size;

                                      final dialogWidth = size.width < 900
                                          ? size.width * 0.95
                                          : size.width * 0.9;
                                      final dialogHeight = size.height * 0.88;

                                      return StatefulBuilder(
                                        builder: (context, setStateSB) {
                                          return Dialog(
                                            backgroundColor: AppbackgroundColor
                                                .Sub_Abg_Colors,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            insetPadding:
                                                const EdgeInsets.symmetric(
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
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 16,
                                                      vertical: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors
                                                          .blueGrey.shade50
                                                          .withOpacity(0.5),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        top:
                                                            Radius.circular(16),
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
                                                                onTap: () =>
                                                                    setStateSB(() =>
                                                                        tapSer =
                                                                            0),
                                                                child:
                                                                    Container(
                                                                  width: 170,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: tapSer ==
                                                                            0
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .black54,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .list,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            22,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              6),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'ข้อมูลผู้ทำรายการ',
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.white,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              InkWell(
                                                                onTap: () =>
                                                                    setStateSB(() =>
                                                                        tapSer =
                                                                            1),
                                                                child:
                                                                    Container(
                                                                  width: 170,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(6),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: tapSer ==
                                                                            1
                                                                        ? Colors
                                                                            .black
                                                                        : Colors
                                                                            .black54,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(6),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width: 1,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      const Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .safety_check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            22,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              6),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          'ข้อมูลข้อเท็จจริง',
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                Colors.white,
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
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.close,
                                                            color: Colors
                                                                .redAccent,
                                                            size: 26,
                                                          ),
                                                          tooltip:
                                                              'ปิดหน้าต่าง',
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                  // Body
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                        bottom:
                                                            Radius.circular(16),
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
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Translate.TranslateAndSetText(
                                'รายละเอียดเอกสารสำหรับต่อสัญญา ',
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
                                  MaterialPageRoute materialPageRoute =
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              AdminScafScreen(
                                                route: 'ใบอนุญาต',
                                                route_getdata: "",
                                              ));
                                  Navigator.pushAndRemoveUntil(context,
                                      materialPageRoute, (route) => false);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_back_ios,
                                      color: ChaoAreaScreen_Color.Colors_Text3_,
                                    ),
                                    Expanded(
                                      child: Translate
                                          .TranslateAndSet_TextAutoSize(
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

                //  Row(
                //   children: [
                //     Expanded(
                //       child: Row(
                //         children: [
                //           Padding(
                //             padding:
                //                 const EdgeInsets.symmetric(horizontal: 2.0),
                //             child: ElevatedButton.icon(
                //               onPressed: () async {
                //                 int tapSer = 0; // จะคงอยู่ภายใน StatefulBuilder

                //                 showDialog(
                //                   context: context,
                //                   barrierDismissible: false,
                //                   builder: (context) {
                //                     return StatefulBuilder(
                //                       builder: (context, setStateSB) {
                //                         return AlertDialog(
                //                           backgroundColor:
                //                               AppbackgroundColor.Sub_Abg_Colors,
                //                           shape: RoundedRectangleBorder(
                //                               borderRadius:
                //                                   BorderRadius.circular(16)),
                //                           insetPadding:
                //                               const EdgeInsets.symmetric(
                //                                   horizontal: 12, vertical: 10),
                //                           titlePadding: EdgeInsets.zero,
                //                           contentPadding: EdgeInsets.zero,
                //                           actionsPadding:
                //                               const EdgeInsets.all(8),

                //                           // 🔹 ส่วนหัว
                //                           title: Container(
                //                             padding: const EdgeInsets.symmetric(
                //                                 horizontal: 16, vertical: 10),
                //                             decoration: BoxDecoration(
                //                               color: Colors.blueGrey.shade50
                //                                   .withOpacity(0.5),
                //                               borderRadius:
                //                                   const BorderRadius.vertical(
                //                                       top: Radius.circular(16)),
                //                             ),
                //                             child: Row(
                //                               mainAxisAlignment:
                //                                   MainAxisAlignment
                //                                       .spaceBetween,
                //                               children: [
                //                                 Row(
                //                                   children: [
                //                                     InkWell(
                //                                       onTap: () => setStateSB(
                //                                           () => tapSer = 0),
                //                                       child: Container(
                //                                         width: 150,
                //                                         decoration:
                //                                             BoxDecoration(
                //                                           color: (tapSer == 0)
                //                                               ? Colors.black
                //                                               : Colors.black54,
                //                                           borderRadius:
                //                                               const BorderRadius
                //                                                       .all(
                //                                                   Radius
                //                                                       .circular(
                //                                                           6)),
                //                                           border: Border.all(
                //                                               color:
                //                                                   Colors.grey,
                //                                               width: 1),
                //                                         ),
                //                                         padding:
                //                                             const EdgeInsets
                //                                                 .all(2),
                //                                         child: const Row(
                //                                           children: [
                //                                             Icon(Icons.list,
                //                                                 color: Colors
                //                                                     .white,
                //                                                 size: 25),
                //                                             SizedBox(width: 4),
                //                                             Text(
                //                                               'ข้อมูลผู้ทำรายการ',
                //                                               style: TextStyle(
                //                                                 fontSize: 16,
                //                                                 fontWeight:
                //                                                     FontWeight
                //                                                         .bold,
                //                                                 color: Colors
                //                                                     .white,
                //                                               ),
                //                                             ),
                //                                           ],
                //                                         ),
                //                                       ),
                //                                     ),
                //                                     const SizedBox(width: 5),
                //                                     InkWell(
                //                                       onTap: () => setStateSB(
                //                                           () => tapSer = 1),
                //                                       child: Container(
                //                                         width: 150,
                //                                         decoration:
                //                                             BoxDecoration(
                //                                           color: (tapSer == 1)
                //                                               ? Colors.black
                //                                               : Colors.black54,
                //                                           borderRadius:
                //                                               const BorderRadius
                //                                                       .all(
                //                                                   Radius
                //                                                       .circular(
                //                                                           6)),
                //                                           border: Border.all(
                //                                               color:
                //                                                   Colors.grey,
                //                                               width: 1),
                //                                         ),
                //                                         padding:
                //                                             const EdgeInsets
                //                                                 .all(2),
                //                                         child: const Row(
                //                                           children: [
                //                                             Icon(
                //                                                 Icons
                //                                                     .safety_check,
                //                                                 color: Colors
                //                                                     .white,
                //                                                 size: 25),
                //                                             SizedBox(width: 4),
                //                                             Text(
                //                                               'ข้อมูลข้อเท็จจริง', // แก้สะกด
                //                                               style: TextStyle(
                //                                                 fontSize: 16,
                //                                                 fontWeight:
                //                                                     FontWeight
                //                                                         .bold,
                //                                                 color: Colors
                //                                                     .white,
                //                                               ),
                //                                             ),
                //                                           ],
                //                                         ),
                //                                       ),
                //                                     ),
                //                                   ],
                //                                 ),
                //                                 IconButton(
                //                                   icon: const Icon(Icons.close,
                //                                       color: Colors.redAccent,
                //                                       size: 26),
                //                                   tooltip: 'ปิดหน้าต่าง',
                //                                   onPressed: () =>
                //                                       Navigator.pop(context),
                //                                 ),
                //                               ],
                //                             ),
                //                           ),

                //                           // 🔹 เนื้อหา
                //                           content: SizedBox(
                //                             child: SingleChildScrollView(
                //                               child: ConstrainedBox(
                //                                 constraints: BoxConstraints(
                //                                   maxHeight:
                //                                       MediaQuery.of(context)
                //                                               .size
                //                                               .height *
                //                                           0.88,
                //                                   minWidth:
                //                                       MediaQuery.of(context)
                //                                               .size
                //                                               .width *
                //                                           0.45,
                //                                   minHeight:
                //                                       MediaQuery.of(context)
                //                                               .size
                //                                               .height *
                //                                           0.3,
                //                                   maxWidth: 1400,
                //                                 ),
                //                                 child: ClipRRect(
                //                                   borderRadius:
                //                                       BorderRadius.circular(12),
                //                                   child: Container(
                //                                     decoration: BoxDecoration(
                //                                       color: Colors.white
                //                                           .withOpacity(0.98),
                //                                       borderRadius:
                //                                           BorderRadius.circular(
                //                                               12),
                //                                       boxShadow: [
                //                                         BoxShadow(
                //                                           color: Colors.black
                //                                               .withOpacity(
                //                                                   0.05),
                //                                           blurRadius: 12,
                //                                           offset: const Offset(
                //                                               0, 5),
                //                                         ),
                //                                       ],
                //                                     ),
                //                                     child: (tapSer == 0)
                //                                         ? const RequestExaminer1_CMM(
                //                                             viewver: true)
                //                                         : const RequestExaminer2_CMM(
                //                                             viewver: true),
                //                                   ),
                //                                 ),
                //                               ),
                //                             ),
                //                           ),
                //                         );
                //                       },
                //                     );
                //                   },
                //                 );
                //               },
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: Colors.blueGrey,
                //                 shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(8),
                //                 ),
                //                 padding: const EdgeInsets.symmetric(
                //                     vertical: 12, horizontal: 12),
                //               ),
                //               icon: const Icon(Icons.book),
                //               label: const Text(
                //                 'ข้อมูลเพิ่มเติม',
                //                 style: TextStyle(
                //                   fontFamily: Font_.Fonts_T,
                //                   fontSize: 14,
                //                   fontWeight: FontWeight.bold,
                //                 ),
                //               ),
                //             ),
                //           ),
                //           if (MediaQuery.of(context).size.width >= 1200)
                //             Padding(
                //               padding: const EdgeInsets.all(8.0),
                //               child: Translate.TranslateAndSetText(
                //                 'คำขอต่อสัญญา',
                //                 ChaoAreaScreen_Color.Colors_Text1_,
                //                 TextAlign.left,
                //                 FontWeight.bold,
                //                 FontWeight_.Fonts_T,
                //                 14,
                //                 2,
                //               ),
                //             ),
                //         ],
                //       ),
                //     ),
                //     Expanded(
                //       flex: 2,
                //       child: Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Translate.TranslateAndSetText(
                //           'รายละเอียดเอกสารสำหรับต่อสัญญา ',
                //           ChaoAreaScreen_Color.Colors_Text1_,
                //           TextAlign.left,
                //           FontWeight.bold,
                //           FontWeight_.Fonts_T,
                //           14,
                //           1,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ),
              const SizedBox(height: 20),

              // Body: Preview + Right panel
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(dragDevices: {
                  ui.PointerDeviceKind.touch,
                  ui.PointerDeviceKind.mouse,
                }),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: (Responsive.isDesktop(context))
                          ? MediaQuery.of(context).size.width * 0.85
                          : MediaQuery.of(context).size.width,
                    ),
                    decoration: const BoxDecoration(
                      color: AppbackgroundColor.Sub_Abg_Colors,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // -------- LEFT: PDF Preview ----------

                        if (MediaQuery.of(context).size.width >= 1200) ...[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // AutoSizeText(
                                //   'Preview $pdfName',
                                //   minFontSize: 12,
                                //   maxFontSize: 16,
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                //   style: TextStyle(
                                //     color: PeopleChaoScreen_Color.Colors_Text2_,
                                //     fontFamily: Font_.Fonts_T,
                                //   ),
                                // ),
                                Container(
                                  width: 400,
                                  height: 550,
                                  decoration: BoxDecoration(
                                    // color: Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  child: _previewUrl != null
                                      ? UrlPreviewWidget(
                                          key: ValueKey(_previewUrl),
                                          url: _previewUrl!,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.6,
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child:
                                                    Icon(Icons.picture_as_pdf),
                                              ),
                                              Text(
                                                "PDF Download ...",
                                                style: TextStyle(
                                                  color: PeopleChaoScreen_Color
                                                      .Colors_Text2_,
                                                  fontFamily: Font_.Fonts_T,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    icon: const Icon(Icons.zoom_in),
                                    onPressed: () {
                                      final reqUuid = widget.requestUuid ??
                                          requestUuid ??
                                          '';

                                      String getUrl(String key) {
                                        final urlMap = {
                                          'GeneratePDF_1':
                                              '${MyConstant().domain_v3}/api/preview/req-vendor-license-2/$reqUuid',
                                          'GeneratePDF_2':
                                              '${MyConstant().domain_v3}/api/preview/memo-vendor-license-2/$reqUuid',
                                          'GeneratePDF_3':
                                              '${MyConstant().domain_v3}/api/preview/vendor-license-2/$reqUuid',
                                        };
                                        return urlMap[key] ?? '';
                                      }

                                      final docs = <Map<String, String>>[
                                        {
                                          "title":
                                              "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ",
                                          "key": "GeneratePDF_1"
                                        },
                                        {
                                          "title":
                                              "ใบคำร้องต่อใบอนุญาตแก่ปลัดเทศบาล",
                                          "key": "GeneratePDF_2"
                                        },
                                        {
                                          "title":
                                              "ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ",
                                          "key": "GeneratePDF_3"
                                        },
                                      ];

                                      final currentKey =
                                          functionName.toString();
                                      final currentIndex = docs.indexWhere(
                                          (e) => e['key'] == currentKey);
                                      final startIndex =
                                          currentIndex >= 0 ? currentIndex : 0;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PdfMultiPreviewPage(
                                            docs: docs,
                                            initialIndex: startIndex,
                                            getUrl: getUrl,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                )
                              ],
                            ),
                          ),
                        ],

                        // -------- RIGHT: Lists + Notes + Signature ----------
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                // เอกสาร
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // AutoSizeText(
                                    //   'เอกสารคำร้องขอต่อสัญญา/ใบอนุญาต',
                                    //   minFontSize: 12,
                                    //   maxFontSize: 16,
                                    //   maxLines: 1,
                                    //   overflow: TextOverflow.ellipsis,
                                    //   style: TextStyle(
                                    //     color: PeopleChaoScreen_Color
                                    //         .Colors_Text2_,
                                    //     fontWeight: FontWeight.w600,
                                    //     fontFamily: Font_.Fonts_T,
                                    //   ),
                                    // ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                          // decoration: BoxDecoration(
                                          //   color: Colors.white,
                                          //   borderRadius:
                                          //       const BorderRadius.all(
                                          //           Radius.circular(10)),
                                          //   border: Border.all(
                                          //       color: Colors.grey, width: 1),
                                          // ),
                                          // padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                        children: [
                                          for (final doc in dataDocCid)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: AutoSizeText(
                                                        '${doc["ser"]}.${doc["title"]}',
                                                        minFontSize: 12,
                                                        maxFontSize: 16,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          color:
                                                              PeopleChaoScreen_Color
                                                                  .Colors_Text2_,
                                                          fontFamily:
                                                              Font_.Fonts_T,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 150,
                                                    height: 35,
                                                    child: ElevatedButton(
                                                      style: ButtonStyle(
                                                        backgroundColor: functionName
                                                                    .toString() ==
                                                                doc['detail']
                                                                    .toString()
                                                            ? MaterialStateProperty
                                                                .all(
                                                                ui.Color
                                                                    .fromARGB(
                                                                        255,
                                                                        187,
                                                                        187,
                                                                        187),
                                                              )
                                                            : MaterialStateProperty
                                                                .all(
                                                                const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    155,
                                                                    170,
                                                                    72),
                                                              ),
                                                      ),
                                                      onPressed: () {
                                                        final isBig =
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                1400;
                                                        final reqUuid = widget
                                                                .requestUuid ??
                                                            requestUuid ??
                                                            '';

                                                        String getUrl(
                                                            String key) {
                                                          final urlMap = {
                                                            'GeneratePDF_1':
                                                                '${MyConstant().domain_v3}/api/preview/req-vendor-license-2/$reqUuid',
                                                            'GeneratePDF_2':
                                                                '${MyConstant().domain_v3}/api/preview/memo-vendor-license-2/$reqUuid',
                                                            'GeneratePDF_3':
                                                                '${MyConstant().domain_v3}/api/preview/vendor-license-2/$reqUuid',
                                                          };
                                                          return urlMap[key] ??
                                                              '';
                                                        }

                                                        final docs = <Map<
                                                            String, String>>[
                                                          {
                                                            "title":
                                                                "ใบคำร้องขอต่อใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ",
                                                            "key":
                                                                "GeneratePDF_1"
                                                          },
                                                          {
                                                            "title":
                                                                "ใบคำร้องต่อใบอนุญาตแก่ปลัดเทศบาล",
                                                            "key":
                                                                "GeneratePDF_2"
                                                          },
                                                          {
                                                            "title":
                                                                "ใบอนุญาตจำหน่ายสินค้าในที่หรือทางสาธารณะ",
                                                            "key":
                                                                "GeneratePDF_3"
                                                          },
                                                        ];

                                                        final currentKey =
                                                            (doc['detail'] ??
                                                                    '')
                                                                .toString();
                                                        final currentIndex =
                                                            docs.indexWhere(
                                                                (e) =>
                                                                    e['key'] ==
                                                                    currentKey);
                                                        final startIndex =
                                                            currentIndex >= 0
                                                                ? currentIndex
                                                                : 0;

                                                        if (isBig) {
                                                          setState(() {
                                                            _previewUrl = getUrl(
                                                                doc['detail'] ??
                                                                    '');
                                                            pdfName =
                                                                doc["title"] ??
                                                                    '';
                                                            functionName =
                                                                doc['detail'] ??
                                                                    '';
                                                          });
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  PdfMultiPreviewPage(
                                                                docs: docs,
                                                                initialIndex:
                                                                    startIndex,
                                                                getUrl: getUrl,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },

                                                      // PDF generation logic removed in refactor
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: Translate
                                                            .TranslateAndSet_TextAutoSize(
                                                          'แสดง',
                                                          ChaoAreaScreen_Color
                                                              .Colors_Text2_,
                                                          TextAlign.center,
                                                          null,
                                                          FontWeight_.Fonts_T,
                                                          12,
                                                          18,
                                                          1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      )),
                                    )
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // หมายเหตุ (ย่อ/ขยาย)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // หัวข้อ คลิกเพื่อย่อ/ขยาย
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            _isCommentExpanded =
                                                !_isCommentExpanded;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 10.0),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                child: AutoSizeText(
                                                  'หมายเหตุ',
                                                  minFontSize: 12,
                                                  maxFontSize: 16,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: Font_.Fonts_T,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                _isCommentExpanded
                                                    ? Icons.expand_less
                                                    : Icons.expand_more,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // เนื้อหา (ย่อ/ขยายได้)
                                      if (_isCommentExpanded) ...[
                                        for (var i = 0;
                                            i < Flow_Because.length;
                                            i++) ...[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 2.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.chat_rounded,
                                                    size: 16,
                                                    color:
                                                        Colors.indigo.shade600),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: RichText(
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              '${Flow_ApprovedBy[i]} : ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: Flow_Because[i],
                                                          style: TextStyle(
                                                            color:
                                                                Colors.black87,
                                                            fontFamily:
                                                                Font_.Fonts_T,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 4.0),
                                          child: TextFormField(
                                            readOnly: false,
                                            controller: controllerBecause,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'ใส่ข้อมูลให้ครบถ้วน';
                                              }
                                              return null;
                                            },
                                            maxLines: (Responsive.isDesktop(
                                                        context) ||
                                                    Responsive.isTablet(
                                                        context))
                                                ? 3
                                                : 1,
                                            cursorColor: Colors.green,
                                            decoration: InputDecoration(
                                              fillColor:
                                                  Colors.white.withOpacity(0.7),
                                              filled: true,
                                              focusedBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.black),
                                              ),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                                borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.grey),
                                              ),
                                              labelStyle: const TextStyle(
                                                color: ManageScreen_Color
                                                    .Colors_Text2_,
                                                fontFamily: Font_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                if (!Responsive.isDesktop(context)) ...[
                                  // กล่องลายเซ็น
                                  Column(
                                    children: [
                                      // กล่องพรีวิวลายเซ็นที่จะประทับ
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: Colors.grey, width: 1),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 140,
                                                width: double.infinity,
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 300),
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                8.0)),
                                                    child: (signatureUser ==
                                                                null &&
                                                            signaturesUrl ==
                                                                null)
                                                        ? const SizedBox(
                                                            child: Center(
                                                              child: Text(
                                                                'ไม่มีลายเซ็น',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : FittedBox(
                                                            fit: BoxFit.cover,
                                                            child: Image.memory(
                                                              signatureUser ??
                                                                  signaturesUrl!,
                                                              height: 180,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                print(
                                                                    '[SignaturePad] ❌ Image error: $error');
                                                                return const Icon(
                                                                    Icons
                                                                        .broken_image,
                                                                    size: 48,
                                                                    color: Colors
                                                                        .grey);
                                                              },
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: AppbackgroundColor
                                                      .Abg_Colors,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          // ใช้ลายเซ็นของแอดมินจาก API
                                                          signatureUser =
                                                              signaturesUrl;
                                                        });
                                                      },
                                                      child: const AutoSizeText(
                                                        'ประทับลายเซ็น',
                                                        minFontSize: 12,
                                                        maxFontSize: 16,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() =>
                                                            signatureUser =
                                                                null);
                                                      },
                                                      child: const Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: AutoSizeText(
                                                          'ยกเลิกลายเซ็น',
                                                          minFontSize: 12,
                                                          maxFontSize: 16,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // ชื่อ/ตำแหน่งผู้ตรวจ
                                      Container(
                                        // Remove fixed height to allow content to dictate size
                                        child: Column(
                                          children: List.generate(2, (index) {
                                            final label = index == 0
                                                ? 'ชื่อผู้ตรวจสอบเอกสาร'
                                                : 'ชื่อตำแหน่ง';
                                            final controller = index == 0
                                                ? controllerFullNameAdmin
                                                : controllerPositionAdmin;
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    label,
                                                    minFontSize: 12,
                                                    maxFontSize: 16,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    controller: controller,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'ใส่ข้อมูลให้ครบถ้วน';
                                                      }
                                                      return null;
                                                    },
                                                    maxLines: 1,
                                                    cursorColor: Colors.green,
                                                    decoration:
                                                        const InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          Color(0x22FFFFFF),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  // กล่องลายเซ็น
                                  Row(
                                    children: [
                                      // กล่องพรีวิวลายเซ็นที่จะประทับ
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              border: Border.all(
                                                  color: Colors.grey, width: 1),
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: 150,
                                                  width: double.infinity,
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 350),
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  8.0)),
                                                      child: (signatureUser ==
                                                              null)
                                                          ? const SizedBox()
                                                          : FittedBox(
                                                              fit: BoxFit.cover,
                                                              child:
                                                                  Image.memory(
                                                                signatureUser!,
                                                                height: 180,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppbackgroundColor
                                                        .Abg_Colors,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            // ใช้ลายเซ็นของแอดมินจาก API
                                                            signatureUser =
                                                                signaturesUrl;
                                                          });
                                                        },
                                                        child:
                                                            const AutoSizeText(
                                                          'ประทับลายเซ็น',
                                                          minFontSize: 12,
                                                          maxFontSize: 16,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() =>
                                                              signatureUser =
                                                                  null);
                                                        },
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: AutoSizeText(
                                                            'ยกเลิกลายเซ็น',
                                                            minFontSize: 12,
                                                            maxFontSize: 16,
                                                            maxLines: 1,
                                                          ),
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

                                      // ชื่อ/ตำแหน่งผู้ตรวจ
                                      Expanded(
                                        child: Column(
                                          children: List.generate(2, (index) {
                                            final label = index == 0
                                                ? 'ชื่อผู้ตรวจสอบเอกสาร'
                                                : 'ชื่อตำแหน่ง';
                                            final controller = index == 0
                                                ? controllerFullNameAdmin
                                                : controllerPositionAdmin;
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    label,
                                                    minFontSize: 12,
                                                    maxFontSize: 16,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color:
                                                          PeopleChaoScreen_Color
                                                              .Colors_Text2_,
                                                      fontFamily: Font_.Fonts_T,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: TextFormField(
                                                    readOnly: true,
                                                    controller: controller,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'ใส่ข้อมูลให้ครบถ้วน';
                                                      }
                                                      return null;
                                                    },
                                                    maxLines: 1,
                                                    cursorColor: Colors.green,
                                                    decoration:
                                                        const InputDecoration(
                                                      filled: true,
                                                      fillColor:
                                                          Color(0x22FFFFFF),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    8)),
                                                        borderSide: BorderSide(
                                                            width: 1,
                                                            color: Colors.grey),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                if (Responsive.isMobile(context)) ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: 200,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                          (signatureUser == null ||
                                                  _isSubmitting)
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      onPressed: (signatureUser == null ||
                                              _isSubmitting)
                                          ? null
                                          : () async {
                                              setState(
                                                  () => _isSubmitting = true);
                                              try {
                                                final response =
                                                    await Post_ReviewsFlowApprove(
                                                  requestUuid: requestUuid ??
                                                      widget.requestUuid ??
                                                      '',
                                                  flowUuid: triggeredUuid ??
                                                      widget.triggeredUuid ??
                                                      '',
                                                  profileUuid: profileUuid,
                                                  signUuid: signatureUuid,
                                                  comment:
                                                      controllerBecause.text,
                                                );
                                                final materialPageRoute =
                                                    MaterialPageRoute(
                                                  builder: (context) =>
                                                      AdminScafScreen(
                                                          route: 'ใบอนุญาต'),
                                                );
                                                if (!mounted) return;
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    materialPageRoute,
                                                    (route) => false);
                                              } catch (e) {
                                                if (mounted) {
                                                  setState(() =>
                                                      _isSubmitting = false);
                                                }
                                              }
                                            },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Translate
                                            .TranslateAndSet_TextAutoSize(
                                          'ยืนยัน',
                                          (signatureUser == null)
                                              ? ChaoAreaScreen_Color
                                                  .Colors_Text2_
                                              : ChaoAreaScreen_Color
                                                  .Colors_Text3_,
                                          TextAlign.center,
                                          null,
                                          FontWeight_.Fonts_T,
                                          12,
                                          18,
                                          1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ] else ...[
                                  const SizedBox(height: 20),

                                  // ปุ่ม กลับ / ยืนยัน
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.grey),
                                          ),
                                          onPressed: () async {
                                            final preferences =
                                                await SharedPreferences
                                                    .getInstance();
                                            final _route =
                                                preferences.getString('route');
                                            final materialPageRoute =
                                                MaterialPageRoute(
                                              builder: (context) =>
                                                  AdminScafScreen(
                                                      route: 'ใบอนุญาต'),
                                            );
                                            // กลับหน้าหลัก
                                            if (!mounted) return;
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                materialPageRoute,
                                                (route) => false);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Translate
                                                .TranslateAndSet_TextAutoSize(
                                              'กลับ',
                                              ChaoAreaScreen_Color
                                                  .Colors_Text2_,
                                              TextAlign.center,
                                              null,
                                              FontWeight_.Fonts_T,
                                              12,
                                              18,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              (signatureUser == null ||
                                                      _isSubmitting)
                                                  ? Colors.grey
                                                  : Colors.black,
                                            ),
                                          ),
                                          onPressed: (signatureUser == null ||
                                                  _isSubmitting)
                                              ? null
                                              : () async {
                                                  setState(() =>
                                                      _isSubmitting = true);
                                                  try {
                                                    final response =
                                                        await Post_ReviewsFlowApprove(
                                                      requestUuid: requestUuid ??
                                                          widget.requestUuid ??
                                                          '',
                                                      flowUuid: triggeredUuid ??
                                                          widget
                                                              .triggeredUuid ??
                                                          '',
                                                      profileUuid: profileUuid,
                                                      signUuid: signatureUuid,
                                                      comment: controllerBecause
                                                          .text,
                                                    );
                                                    final materialPageRoute =
                                                        MaterialPageRoute(
                                                      builder: (context) =>
                                                          AdminScafScreen(
                                                              route:
                                                                  'ใบอนุญาต'),
                                                    );
                                                    if (!mounted) return;
                                                    Navigator
                                                        .pushAndRemoveUntil(
                                                            context,
                                                            materialPageRoute,
                                                            (route) => false);
                                                  } catch (e) {
                                                    if (mounted) {
                                                      setState(() =>
                                                          _isSubmitting =
                                                              false);
                                                    }
                                                  }
                                                },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Translate
                                                .TranslateAndSet_TextAutoSize(
                                              'ยืนยัน',
                                              // 'ยืนยัน/สำเร็จ',
                                              (signatureUser == null)
                                                  ? ChaoAreaScreen_Color
                                                      .Colors_Text2_
                                                  : ChaoAreaScreen_Color
                                                      .Colors_Text3_,
                                              TextAlign.center,
                                              null,
                                              FontWeight_.Fonts_T,
                                              12,
                                              18,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 50,
                                  )
                                ],
                              ],
                            ),
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
    );
  }
}
