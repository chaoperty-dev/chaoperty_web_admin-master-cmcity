import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Responsive/responsive.dart';
import '../Style/colors.dart';
import 'Model/AutoExpTrans_ModelCMM.dart';
import 'Make_contract_CMM/payment_contract_cmm.dart';
import 'unity/API_payment.dart';
import 'unity/API_addfile.dart';
import 'unity/API_requests_reviews.dart';
import 'unity/plugin_signal.dart';
import 'request_examiner1_cmm.dart';
import 'request_examiner2_cmm.dart';
import 'unity/SecurePrefs_helper.dart';
import 'unity/show_dialog_cmm.dart';
import 'Model/ReviewUuid_Model.dart';

/// Plugin สำหรับแสดง Dialog ตรวจสอบข้อมูลผู้ทำรายการ (RequestExaminer)
/// ใช้งานโดยการส่ง modelIndex เข้ามาในตอนสร้าง instance
///
/// ตัวอย่างการใช้งาน:
/// ```dart
/// showDialog(
///   context: context,
///   barrierDismissible: false,
///   builder: (_) => RequestExaminer_plugin_CMM(
///     modelIndex: modelIndex,
///     reviewModels: reviewModels,
///   ),
/// );
/// ```
class RequestExaminer_plugin_CMM extends StatefulWidget {
  /// Index ของรายการใน reviewModels ที่ต้องการแสดง
  final int modelIndex;

  /// รายการข้อมูล ReviewModel ทั้งหมด
  final List<dynamic> reviewModels;

  const RequestExaminer_plugin_CMM({
    super.key,
    required this.modelIndex,
    required this.reviewModels,
  });

  @override
  State<RequestExaminer_plugin_CMM> createState() =>
      _RequestExaminer_plugin_CMMState();
}

class _RequestExaminer_plugin_CMMState
    extends State<RequestExaminer_plugin_CMM> {
  int _tapSer = 0;
  bool _isReady = false;

  // --- Stepper_3 & Stepper_4 state ---
  final nFormat = NumberFormat("#,##0.00", "en_US");
  final ScrollController _scrollControllerStepper3 = ScrollController();
  List<AutoExpTransModelCMM> expAutoModels = [];
  String? uuid_Request;
  dynamic data_response_Post_GC_payment = {};
  bool _isLoadingPayment = false;

  // --- Review (เอกสารแนบ) state ---
  List<ReviewDetail> _reviewDetailList = [];
  bool _isLoadingReview = false;

  // --- Payment Tab Stepper ---
  int _paymentStep = 0; // 0 = ค่าบริการ, 1 = ชำระเงิน
  String _subzoneName = '';
  String _currentStatus = '';
  String? _paymentUuid; // payment.uuid จาก review data

  static const _step2Statuses = [
    'รอกรอกข้อมูลการรับชำระ',
    'ส่งหลักฐานการชำระเงินแล้ว',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _scrollControllerStepper3.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final indexX = widget.modelIndex;
    if (indexX < 0 || indexX >= widget.reviewModels.length) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final model = widget.reviewModels[indexX];
    if (model.newRequest == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final requestUuidStr = model.newRequest?.requestUuid?.toString();
    if (requestUuidStr == null || requestUuidStr.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    // บันทึก UUID ลง SecurePrefs
    await SecurePrefs.setEncrypted(SecurePrefsType.UuidRequest, requestUuidStr);

    final status = (model.status ?? '').trim();
    final subzone = model.newRequest?.subzone ?? '';

    setState(() {
      uuid_Request = requestUuidStr;
      _isReady = true;
      _subzoneName = subzone;
      _currentStatus = status;
      // ถ้า status บ่งบอกว่าผ่าน step 1 ไปแล้ว → ข้ามไป step 2 ทันที
      if (_step2Statuses.any((s) => s == status)) {
        _paymentStep = 1;
      }
    });

    // โหลดข้อมูลค่าบริการ (prepayment) ทันที
    await _loadPrepaymentData();
    // โหลดข้อมูลเอกสารแนบ
    await _loadReviewData();
  }

  /// โหลดข้อมูลค่าบริการจาก API (เหมือน Loading_Data_Step3 ใน new_contract_cmm)
  Future<void> _loadPrepaymentData() async {
    if (uuid_Request == null || uuid_Request!.isEmpty) return;

    setState(() => _isLoadingPayment = true);

    try {
      final response = await readPrepayment(requestUuid: uuid_Request!);

      if (response != null && response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['data']?['details'] != null &&
            body['data']['details'] is List) {
          final List<dynamic> list = body['data']['details'];
          final models =
              list.map((e) => AutoExpTransModelCMM.fromJson(e)).toList();
          if (mounted) {
            setState(() {
              expAutoModels.clear();
              expAutoModels.addAll(models);
              _isLoadingPayment = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingPayment = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingPayment = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingPayment = false);
    }
  }

  /// โหลดข้อมูลเอกสารแนบ (requiredDocs)
  Future<void> _loadReviewData() async {
    if (uuid_Request == null || uuid_Request!.isEmpty) return;

    setState(() => _isLoadingReview = true);

    try {
      final response = await read_GC_ReviewsUuid(uuid_Request);
      if (response != null && response.statusCode == 200) {
        final result = json.decode(response.body);
        final reviewDetailModel = ReviewDetail.fromJson(result['data']);
        if (mounted) {
          setState(() {
            _reviewDetailList = [reviewDetailModel];
            _paymentUuid = reviewDetailModel.payment.uuid;
            _isLoadingReview = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingReview = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingReview = false);
    }
  }

  /// อัปโหลดไฟล์เอกสารแนบ
  Future<void> _uploadAttachmentDoc(int docId) async {
    if (uuid_Request == null || uuid_Request!.isEmpty) return;

    final response = await pickAndUpload(uuid_Request!, docId);
    if (response == null) {
      if (mounted) Dialog_error(context, 'ไม่มีไฟล์ถูกอัปโหลด');
      return;
    }
    // pickAndUpload returns http.Response on success
    int? statusCode;
    try {
      statusCode = (response as dynamic).statusCode as int?;
    } catch (_) {
      statusCode = null;
    }
    if (statusCode == 200 || statusCode == 201) {
      if (mounted) {
        Dialog_success(context, 'อัปโหลดสำเร็จ');
        // รอ server ประมวลผลไฟล์สักครู่ก่อนโหลดข้อมูลใหม่
        await Future.delayed(const Duration(milliseconds: 800));
        await _loadReviewData();
        // ส่งสัญญาณให้ RequestExaminer1_CMM รีโหลดด้วย
        pluginUploadSignal.value++;
      }
    } else {
      if (mounted) Dialog_error(context, 'การอัปโหลดล้มเหลว');
    }
  }

  void _moveUpStepper3() {
    _scrollControllerStepper3.animateTo(_scrollControllerStepper3.offset - 220,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  void _moveDownStepper3() {
    _scrollControllerStepper3.animateTo(_scrollControllerStepper3.offset + 220,
        curve: Curves.linear, duration: const Duration(milliseconds: 500));
  }

  Widget _buildTabContent() {
    switch (_tapSer) {
      case 0:
        return RequestExaminer1_CMM(viewver: false, plugin: true);
      case 1:
        return RequestExaminer2_CMM(viewver: false, plugin: true);
      default:
        return paymentTab();
    }
  }

  // --- Upload section expand/collapse state ---
  bool _isUploadExpanded = false;

  /// ส่วนแสดงปุ่มอัปโหลดเอกสารแนบ (ย่อ/ขยายได้)
  Widget _buildUploadSection() {
    if (_isLoadingReview) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_reviewDetailList.isEmpty ||
        _reviewDetailList.first.requiredDocs.isEmpty) {
      return const SizedBox.shrink();
    }

    final docs = _reviewDetailList.first.requiredDocs.toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (tappable to expand/collapse)
          GestureDetector(
            onTap: () => setState(() => _isUploadExpanded = !_isUploadExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(_isUploadExpanded ? 10 : 10),
                  bottom: Radius.circular(_isUploadExpanded ? 0 : 10),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.upload_file,
                      color: Colors.blueGrey.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'อัปโหลดเอกสารแนบ (${docs.length})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                  ),
                  // if (_isLoadingReview)
                  //   const SizedBox(
                  //     width: 18,
                  //     height: 18,
                  //     child: CircularProgressIndicator(strokeWidth: 2),
                  //   )
                  // else
                  //   GestureDetector(
                  //     onTap: _loadReviewData,
                  //     child: Icon(
                  //       Icons.refresh,
                  //       color: Colors.blueGrey.shade600,
                  //       size: 20,
                  //     ),
                  //   ),
                  // const SizedBox(width: 8),
                  Icon(
                    _isUploadExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blueGrey.shade600,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          if (_isUploadExpanded)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.25,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // คำนวณจำนวนคอลัมน์ตามความกว้างที่มี
                      // การ์ดแต่ละใบกว้าง 160-180px
                      final cardWidth =
                          constraints.maxWidth > 600 ? 180.0 : 160.0;
                      final crossCount = (constraints.maxWidth / cardWidth)
                          .floor()
                          .clamp(1, 6);
                      final itemWidth = constraints.maxWidth / crossCount;

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: docs.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final doc = entry.value;
                          final hasFile = doc.attachment != null &&
                              doc.attachment!.fileName.isNotEmpty;
                          return SizedBox(
                            width: itemWidth - 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: hasFile
                                    ? Colors.green.shade50
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: hasFile
                                      ? Colors.green.shade300
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$index. ${doc.document.nameTh}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize:
                                          constraints.maxWidth > 600 ? 13 : 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: Font_.Fonts_T,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (hasFile)
                                    Text(
                                      doc.attachment!.fileName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth > 600
                                            ? 11
                                            : 10,
                                        color: Colors.green.shade700,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    )
                                  else
                                    Text(
                                      'ยังไม่มีไฟล์',
                                      style: TextStyle(
                                        fontSize: constraints.maxWidth > 600
                                            ? 11
                                            : 10,
                                        color: Colors.grey.shade600,
                                        fontFamily: Font_.Fonts_T,
                                      ),
                                    ),
                                  const SizedBox(height: 6),
                                  if (doc.attachment?.statusLabel == 'ผ่าน')
                                    Container(
                                      width: double.infinity,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: Colors.green.shade400),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle,
                                              color: Colors.green.shade700,
                                              size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            'ผ่าน',
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: Font_.Fonts_T,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      height: 28,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: hasFile
                                              ? Colors.orange.shade700
                                              : Colors.blueGrey.shade700,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          textStyle:
                                              const TextStyle(fontSize: 11),
                                        ),
                                        onPressed: () => _uploadAttachmentDoc(
                                            doc.document.id),
                                        icon: Icon(
                                          hasFile
                                              ? Icons.refresh
                                              : Icons.upload,
                                          size: 14,
                                        ),
                                        label: Text(
                                          hasFile ? 'อัปโหลดใหม่' : 'อัปโหลด',
                                          style: TextStyle(
                                              fontFamily: Font_.Fonts_T,
                                              fontSize: 11),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ===== Stepper_3: ตารางแสดงรายการค่าบริการ (คัดลอกเฉพาะส่วนแสดงผล) =====
  Widget _buildStepper3(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            Container(
              decoration: const BoxDecoration(
                color: AppbackgroundColor.Sub_Abg_Colors,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              child: Column(
                children: [
                  ScrollConfiguration(
                    behavior:
                        ScrollConfiguration.of(context).copyWith(dragDevices: {
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
                                        : MediaQuery.of(context).size.width *
                                            0.825,
                                    decoration: BoxDecoration(
                                      color: AppbackgroundColor.TiTile_Colors,
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
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'งวด',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
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
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
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
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
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
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
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
                                                color: PeopleChaoScreen_Color
                                                    .Colors_Text1_,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: FontWeight_.Fonts_T,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 250,
                                        width: (!Responsive.isDesktop(context))
                                            ? 1200
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.825,
                                        decoration: const BoxDecoration(
                                          color:
                                              AppbackgroundColor.Sub_Abg_Colors,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              topRight: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0)),
                                        ),
                                        child: _isLoadingPayment
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : expAutoModels.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                        'ไม่มีข้อมูลค่าบริการ'))
                                                : ListView.builder(
                                                    controller:
                                                        _scrollControllerStepper3,
                                                    physics:
                                                        const AlwaysScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        expAutoModels.length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Material(
                                                        color:
                                                            AppbackgroundColor
                                                                .Sub_Abg_Colors,
                                                        child: Container(
                                                          child: ListTile(
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
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            AutoSizeText(
                                                                          maxLines:
                                                                              2,
                                                                          minFontSize:
                                                                              8,
                                                                          '${expAutoModels[index].unit}/${expAutoModels[index].term}',
                                                                          textAlign:
                                                                              TextAlign.start,
                                                                          style:
                                                                              const TextStyle(
                                                                            color:
                                                                                PeopleChaoScreen_Color.Colors_Text2_,
                                                                            fontFamily:
                                                                                Font_.Fonts_T,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        AutoSizeText(
                                                                      maxLines:
                                                                          2,
                                                                      minFontSize:
                                                                          8,
                                                                      (expAutoModels[index].sdate == '' ||
                                                                              expAutoModels[index].sdate == '')
                                                                          ? '${expAutoModels[index].sdate} - ${expAutoModels[index].ldate}'
                                                                          : '${DateFormat('dd-MM-yyyy').format(DateTime.parse('${expAutoModels[index].sdate!} 00:00:00'))} - ${DateFormat('dd-MM-yyyy').format(DateTime.parse('${expAutoModels[index].ldate!} 00:00:00'))}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            8.0),
                                                                    child:
                                                                        AutoSizeText(
                                                                      maxLines:
                                                                          2,
                                                                      minFontSize:
                                                                          8,
                                                                      '${expAutoModels[index].expname} ',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: PeopleChaoScreen_Color
                                                                            .Colors_Text2_,
                                                                        fontFamily:
                                                                            Font_.Fonts_T,
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
                                                                    '${expAutoModels[index].total} / งวด',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
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
                                                                    '${nFormat.format(int.parse(expAutoModels[index].term ?? '0') * double.parse(expAutoModels[index].total ?? '0'))}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .right,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: PeopleChaoScreen_Color
                                                                          .Colors_Text2_,
                                                                      fontFamily:
                                                                          Font_
                                                                              .Fonts_T,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
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
                                      _scrollControllerStepper3.animateTo(
                                        0,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(8)),
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
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (_scrollControllerStepper3.hasClients) {
                                      final position = _scrollControllerStepper3
                                          .position.maxScrollExtent;
                                      _scrollControllerStepper3.animateTo(
                                        position,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
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
                                      'Down',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10.0,
                                        fontFamily: FontWeight_.Fonts_T,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: _moveUpStepper3,
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
                                  ),
                                ),
                                InkWell(
                                  onTap: _moveDownStepper3,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ===== Stepper_4: หน้าชำระเงิน (คัดลอกเฉพาะส่วนแสดงผล) =====
  Widget _buildStepper4(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double maxAllowedWidth = screenWidth * 0.85;
    double maxH = screenHeight * 0.75;
    double minH = 700;
    if (minH > maxH) minH = maxH;

    // คำนวณยอดรวมจาก expAutoModels เพื่อส่งเป็น payment_amount
    final totalSum = expAutoModels.fold<double>(
      0.0,
      (previousValue, element) =>
          previousValue + (double.tryParse(element.total ?? '0.0') ?? 0.0),
    );
    final paymentAmountStr = totalSum.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
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
                    maxHeight: (maxH < 560) ? 640 : maxH + 20,
                  ),
                  child: BillPaymentScreen(
                    uuid_Request: uuid_Request,
                    response_Post_payment: data_response_Post_GC_payment,
                    payment_uuid: _paymentUuid ?? '',
                    payment_amount: paymentAmountStr,
                    payment_jsonx:
                        expAutoModels.map((e) => e.toJson()).toList(),
                    initialPaymentMethod: 'เงินสด',
                    popOnSuccess: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStepHeader({bool isCompleted = false}) {
    final steps = ['ค่าบริการ', 'ชำระเงิน', 'สรุป'];
    final effectiveStep = isCompleted ? steps.length : _paymentStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_subzoneName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.blueGrey),
                const SizedBox(width: 4),
                Text(
                  'แปลง: $_subzoneName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                if (_currentStatus.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: Text(
                      _currentStatus,
                      style: TextStyle(
                          fontSize: 11, color: Colors.blueGrey.shade700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                // เส้นเชื่อม
                final stepIndex = i ~/ 2;
                return Expanded(
                  child: Container(
                    height: 2,
                    color: effectiveStep > stepIndex
                        ? Colors.green.shade600
                        : Colors.grey.shade300,
                  ),
                );
              }
              final stepIndex = i ~/ 2;
              final isDone = effectiveStep > stepIndex;
              final isActive = effectiveStep == stepIndex;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? Colors.green.shade600
                          : isActive
                              ? Colors.blueGrey.shade700
                              : Colors.grey.shade300,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : Text(
                              '${stepIndex + 1}',
                              style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps[stepIndex],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? Colors.blueGrey.shade700
                          : isDone
                              ? Colors.green.shade600
                              : Colors.grey.shade500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget paymentTab() {
    // ถ้าสถานะจบขั้นตอนแล้ว → แสดงสรุปการชำระเงิน
    if (_currentStatus == 'ส่งหลักฐานการชำระเงินแล้ว') {
      return _buildPaymentSummary();
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildPaymentStepHeader(),
          const Divider(height: 1),
          const SizedBox(height: 8),
          if (_paymentStep == 0) _buildStepper3(context),
          if (_paymentStep == 1) _buildStepper4(context),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_paymentStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _paymentStep--),
                      child: const Text('กลับ'),
                    ),
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (_paymentStep == 0) {
                      setState(() => _paymentStep = 1);
                    }
                    // _paymentStep == 1: logic ชำระเงินจริงอยู่ใน BillPaymentScreen
                  },
                  child: Text(_paymentStep == 0 ? 'ถัดไป' : 'ยืนยัน'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// แสดงสรุปการชำระเงินเมื่อจบขั้นตอนแล้ว
  Widget _buildPaymentSummary() {
    final payment =
        _reviewDetailList.isNotEmpty ? _reviewDetailList.first.payment : null;
    final hasAttachment = payment?.payAttachment != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stepper 3 ขั้นตอน (ค่าบริการ → ชำระเงิน → สรุป)
            _buildPaymentStepHeader(isCompleted: true),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Header สถานะ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Colors.green.shade700, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ชำระเงินแล้ว',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ส่งหลักฐานการชำระเงินแล้ว',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontFamily: Font_.Fonts_T,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // หลักฐานการชำระเงิน
            if (hasAttachment)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'หลักฐานการชำระเงิน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800,
                        fontFamily: Font_.Fonts_T,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.image, color: Colors.blueGrey.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              payment!.payAttachment!.fileName ?? 'ไฟล์แนบ',
                              style: TextStyle(
                                fontFamily: Font_.Fonts_T,
                                color: Colors.blueGrey.shade700,
                              ),
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
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: Font_.Fonts_T,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
              fontFamily: Font_.Fonts_T,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: AppbackgroundColor.Sub_Abg_Colors,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.all(8),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50.withOpacity(0.5),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() => _tapSer = 0),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 120),
                        decoration: BoxDecoration(
                          color: (_tapSer == 0) ? Colors.black : Colors.black54,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.list, color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'ข้อมูลผู้ทำรายการ',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    InkWell(
                      onTap: () => setState(() => _tapSer = 1),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 120),
                        decoration: BoxDecoration(
                          color: (_tapSer == 1) ? Colors.black : Colors.black54,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.safety_check,
                                color: Colors.white, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'ข้อมูลข้อเท็จจริง',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(width: 5),
                    // InkWell(
                    //   onTap: () => setState(() => _tapSer = 2),
                    //   child: Container(
                    //     constraints: const BoxConstraints(minWidth: 130),
                    //     decoration: BoxDecoration(
                    //       color: (_tapSer == 2) ? Colors.black : Colors.black54,
                    //       borderRadius:
                    //           const BorderRadius.all(Radius.circular(6)),
                    //       border: Border.all(color: Colors.grey, width: 1),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 8, vertical: 4),
                    //     child: const Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Icon(Icons.safety_check,
                    //             color: Colors.white, size: 20),
                    //         SizedBox(width: 4),
                    //         Text(
                    //           'ข้อมูลการชำระเงิน',
                    //           style: TextStyle(
                    //             fontSize: 13,
                    //             fontWeight: FontWeight.bold,
                    //             color: Colors.white,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent, size: 26),
              tooltip: 'ปิดหน้าต่าง',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        width: MediaQuery.of(context).size.width * 0.9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.98),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(child: _buildTabContent()),
                if (_tapSer == 0) _buildUploadSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
